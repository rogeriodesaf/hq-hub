"""Identidade de capas e reaproveitamento, sem depender de lojas externas."""
import json
import unittest
from unittest.mock import patch

import robo_enriquecer_capas_multiplas_fontes as robo


class PrecisaoCapasTest(unittest.TestCase):
    def test_nao_confunde_series_nem_titulos(self):
        validar = robo.titulo_compativel_com_serie_e_fase
        self.assertFalse(validar('Liga da Justiça 1ª Série 07', 'Liga da Justiça 2ª Série', '2ª Série'))
        self.assertFalse(validar('Liga da Justiça 07', 'Liga da Justiça 2ª Série', '2ª Série'))
        self.assertFalse(validar('Liga da Justiça 07', 'Liga da Justiça Sem Limites', ''))
        self.assertTrue(validar('Liga da Justiça 4ª Série 07', 'Liga da Justiça 4ª Série', '"4ª Série" "V2"'))
        self.assertFalse(validar('Liga da Justiça 07 Variante', 'Liga da Justiça', ''))

    def test_numero_exato_e_primeiro_especial(self):
        validar = robo.titulo_compativel_com_numero
        self.assertFalse(validar('Batman #23.1', '23', 'Batman'))
        self.assertFalse(validar('Batman #2', '1', 'Batman'))
        self.assertFalse(validar('Batman Outra Historia', '1', 'Batman'))
        self.assertTrue(validar('Thor Antologia', '1', 'Thor Antologia'))
        self.assertTrue(validar('Liga Da Justiça Sem Limites (2025) 08', '8', 'Liga da Justiça Sem Limites'))

    def test_papersera_nao_confunde_colecoes_barks(self):
        self.assertFalse(robo.fonte_aplicavel('Papersera', {}, {'titulo': 'Coleção Carl Barks Definitiva', 'editora': 'Panini'}))
        self.assertTrue(robo.fonte_aplicavel('Papersera', {}, {'titulo': 'Melhor da Disney, O', 'editora': 'Abril'}))

    def test_alias_mulher_maravilha_primeira_serie(self):
        self.assertEqual(robo.alias_catalogo_loja('Rika', 'Mulher-Maravilha 1ª Série'), 'Mulher Maravilha 2017')
        self.assertEqual(robo.alias_catalogo_loja('Panini', 'Mulher-Maravilha 1ª Série'), 'Mulher-Maravilha 2017')
        self.assertEqual(robo.alias_catalogo_loja('Rika', 'Mulher-Maravilha 2ª Série'), 'Mulher-Maravilha 2ª Série')

    def test_panini_url_sem_vol_e_numero_contraditorio(self):
        resultados = [{'url': 'https://panini.com.br/liga-da-justica-sem-limites-2025-08',
                       'titulo': 'Liga Da Justiça Sem Limites (2025) 08', 'urlCapa': 'https://imagem/08.jpg'}]
        with patch.object(robo, 'resultados_loja', return_value=resultados), patch.object(robo, 'extrair_produto', return_value=(None, None)):
            resposta = robo.buscar_fonte('Panini', 'panini.com.br', '', '', '', set(), 'Liga da Justiça Sem Limites', '8')
            self.assertEqual(resposta[1], 'https://imagem/08.jpg')
            resultados[0]['url'] = 'https://panini.com.br/liga-da-justica-sem-limites-vol-9'
            self.assertIsNone(robo.buscar_fonte('Panini', 'panini.com.br', '', '', '', set(), 'Liga da Justiça Sem Limites', '8')[1])

    def test_rika_preserva_numeracao_nao_contigua(self):
        produtos = [{'productName': f'Liga da Justiça 5ª Série {n}', 'link': f'https://www.rika.com.br/{n}/p',
                     'items': [{'images': [{'imageUrl': f'https://imagem/{n}.jpg'}]}]} for n in [10, 56, 57, 58]]
        with patch.object(robo, 'baixar', return_value=json.dumps(produtos)):
            resultados = robo.resultados_rika('Liga da Justiça 5ª Série')
        self.assertEqual(len(resultados), 4)
        self.assertTrue(robo.titulo_compativel_com_numero(resultados[1]['titulo'], '56'))
        self.assertFalse(robo.titulo_compativel_com_numero(resultados[1]['titulo'], '11'))


if __name__ == '__main__':
    unittest.main()
