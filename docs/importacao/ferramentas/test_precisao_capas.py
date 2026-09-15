"""Identidade de capas e reaproveitamento, sem depender de lojas externas."""
import base64
import json
import unittest
from unittest.mock import patch

import robo_enriquecer_capas_multiplas_fontes as robo


class PrecisaoCapasTest(unittest.TestCase):
    def test_extrai_capa_principal_da_dc_quando_og_image_esta_vazio(self):
        html = (
            '<title>BATMAN/THE SPIRIT #1 | DC</title>'
            '<meta property="og:image" content="">'
            '<img src="https://static.dc.com/capa.jpg?w=160" '
            'alt="BATMAN/THE SPIRIT #1">'
        )
        with patch.object(robo, 'baixar', return_value=html):
            capa, titulo = robo.extrair_produto('https://www.dc.com/comics/exemplo')
        self.assertEqual(capa, 'https://static.dc.com/capa.jpg')
        self.assertEqual(titulo, 'BATMAN/THE SPIRIT #1 | DC')

    def test_rika_infere_edicao_esgotada_adjacente(self):
        resultados = [{
            'url': 'https://www.rika.com.br/batman-rastro--115000497/p',
            'titulo': 'Batman Rastro # 1',
        }]
        derivados = robo.resultados_rika_adjacentes(resultados, '2')
        self.assertEqual(
            derivados[0]['url'],
            'https://www.rika.com.br/batman-rastro--215000498/p',
        )

    def test_extrai_produto_vtex_por_json_ld(self):
        html = (
            '<title>Loja</title><script type="application/ld+json">'
            '{"@type":"Product","name":"Batman Rastro # 2",'
            '"image":"https://imagem/rastro-02.jpg"}</script>'
        )
        with patch.object(robo, 'baixar', return_value=html):
            capa, titulo = robo.extrair_produto('https://loja/produto')
        self.assertEqual(capa, 'https://imagem/rastro-02.jpg')
        self.assertEqual(titulo, 'Batman Rastro # 2')

    def test_bing_desfaz_redirecionamento_e_filtra_dominio(self):
        destino = 'https://www.comix.com.br/batman-o-retorno-em-quadrinhos.html'
        codificado = base64.urlsafe_b64encode(destino.encode()).decode().rstrip('=')
        html = (
            '<li class="b_algo"><h2>Batman - O Retorno em Quadrinhos</h2>'
            f'<a href="https://www.bing.com/ck/a?u=a1{codificado}&amp;ntb=1">resultado</a></li>'
        )
        with patch.object(robo, 'baixar', return_value=html):
            resultados = robo.resultados_bing('Batman O Retorno', 'comix.com.br')
        self.assertEqual(resultados[0]['url'], destino)

    def test_batman_nao_e_interpretado_como_marcador_de_numero(self):
        url = 'https://excelsiorcomics.com.br/produto/batman-6a-serie-super-herois-premium-1/'
        self.assertTrue(robo.produto_compativel_com_numero(url, '1'))

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

    def test_panini_encontra_especial_com_subtitulo_omitido(self):
        externo = [{
            'url': 'https://panini.com.br/batman-dylan-dog-dc-bonelli',
            'titulo': 'Batman/Dylan Dog (DC/Bonelli)',
        }]
        miniatura = (
            'https://d14d9vp3wdof84.cloudfront.net/image/589816272436/'
            'image_qcv28fbhi156d8pqiosf39d97h/-S265-FWEBP'
        )
        with patch.object(robo, 'resultados_loja', return_value=[]), \
                patch.object(robo, 'resultados_bing', return_value=externo), \
                patch.object(robo, 'extrair_produto', return_value=(miniatura, externo[0]['titulo'])):
            resposta = robo.buscar_fonte(
                'Panini', 'panini.com.br', '', '', '', set(),
                'Batman/Dylan Dog: A Sombra do Morcego', '1',
            )
        self.assertEqual(resposta[1], miniatura)
        self.assertEqual(
            robo.titulo_validacao_panini('Batman/Dylan Dog: A Sombra do Morcego'),
            'Batman/Dylan Dog',
        )

    def test_panini_promove_miniatura_cloudfront(self):
        miniatura = 'https://d14d9vp3wdof84.cloudfront.net/image/1/capa/-S265-FWEBP'
        self.assertEqual(
            robo.capa_maior_panini(miniatura),
            'https://d14d9vp3wdof84.cloudfront.net/image/1/capa/-S897-FWEBP',
        )


if __name__ == '__main__':
    unittest.main()
