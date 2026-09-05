"""Regressoes da concorrencia e do cache, sem depender de lojas externas."""
import json
from concurrent.futures import CancelledError, ThreadPoolExecutor
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory
from threading import Event
from types import SimpleNamespace
import unittest
from unittest.mock import patch, MagicMock
from contextlib import redirect_stdout

import robo_enriquecer_capas_multiplas_fontes as robo


class PerformanceCapasTest(unittest.TestCase):
    def tearDown(self):
        robo.baixar_cached.cache_clear()
        robo.CONTEXTO_BUSCA.cancelamento = None

    def test_nao_espera_fonte_posterior_e_preserva_prioridade(self):
        iniciou = Event()
        liberar = Event()

        def buscar(nome, *args):
            if nome == 'oficial':
                self.assertTrue(iniciou.wait(2))
                return nome, 'capa-oficial', 'produto', None
            iniciou.set()
            liberar.wait(2)
            return nome, 'capa-loja', 'produto', None

        with ThreadPoolExecutor(2) as pool, patch.object(robo, 'buscar_fonte', buscar):
            try:
                resposta = robo.consultar_fontes(
                    pool, [('oficial', '', ''), ('loja', '', '')],
                    '', '', set(), 'Batman', '1', {},
                )
                self.assertEqual(resposta[1], 'capa-oficial')
                self.assertFalse(liberar.is_set())
            finally:
                liberar.set()

    def test_fallback_apos_erro_e_contexto_limpo(self):
        def buscar(nome, *args):
            if nome == 'oficial':
                raise OSError('indisponivel')
            return nome, 'capa-loja', 'produto', None

        item = {}
        with ThreadPoolExecutor(1) as pool, patch.object(robo, 'buscar_fonte', buscar):
            resposta = robo.consultar_fontes(
                pool, [('oficial', '', ''), ('loja', '', '')],
                '', '', set(), 'Batman', '1', item,
            )
            self.assertEqual(resposta[1], 'capa-loja')
            self.assertIn('indisponivel', item['erros'][0])
            self.assertIsNone(pool.submit(
                lambda: robo.CONTEXTO_BUSCA.cancelamento
            ).result())

    def test_cache_e_cancelamento_antes_da_rede(self):
        resposta = MagicMock()
        resposta.__enter__.return_value.read.return_value = b'<html>capa</html>'
        with patch.object(robo, 'urlopen', return_value=resposta) as abrir:
            self.assertEqual(robo.baixar('https://loja/produto'), robo.baixar('https://loja/produto'))
            self.assertEqual(abrir.call_count, 1)
            evento = Event()
            evento.set()
            robo.CONTEXTO_BUSCA.cancelamento = evento
            with self.assertRaises(CancelledError):
                robo.baixar('https://loja/outra')
            self.assertEqual(abrir.call_count, 1)

    def test_cache_nao_guarda_falhas(self):
        with patch.object(robo, 'urlopen', side_effect=OSError('offline')) as abrir, patch.object(robo, 'sleep'):
            for _ in range(2):
                with self.assertRaises(OSError):
                    robo.baixar('https://loja/produto')
            self.assertEqual(abrir.call_count, 4)

    def test_lote_preserva_capa_existente_e_evita_repeticao(self):
        def buscar(nome, dominio, modelo, consulta, busca, usadas, titulo, numero):
            self.assertIsInstance(usadas, frozenset)
            capa = 'existente' if nome == 'primeira' else 'nova-' + numero
            return nome, None if capa in usadas else capa, 'produto', None

        with TemporaryDirectory() as pasta:
            entrada = Path(pasta) / 'entrada.json'
            saida = Path(pasta) / 'saida.json'
            entrada.write_text(json.dumps({
                'serieBrasileira': {'titulo': 'Batman', 'editora': 'Abril'},
                'edicoes': [{'numero': '1', 'urlCapa': 'existente'}, {'numero': '2'}, {'numero': '3'}],
            }), encoding='utf-8')
            args = SimpleNamespace(pasta=pasta, entrada=str(entrada), saida=str(saida),
                                   substituir=False, intervalo_segundos=0)
            fontes = {'primeira': ('', ''), 'segunda': ('', '')}
            with patch.object(robo, 'FONTES', fontes), patch.object(robo, 'buscar_fonte', buscar), redirect_stdout(StringIO()):
                robo.enriquecer(args)
            dados = json.loads(saida.read_text(encoding='utf-8'))
            self.assertEqual([e['urlCapa'] for e in dados['edicoes']], ['existente', 'nova-2', 'nova-3'])
            self.assertEqual(dados['origem']['capasAutomaticas']['capasEncontradas'], 2)


if __name__ == '__main__':
    unittest.main()
