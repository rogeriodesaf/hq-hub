"""Limite de tempo da busca Panini sem acesso à rede."""
import unittest
from unittest.mock import patch

import robo_atualizar_capas_panini_catalogo as robo


class TimeoutCapasPaniniTest(unittest.TestCase):
    def test_limita_timeout_da_requisicao(self):
        with patch.object(robo, "urlopen", side_effect=TimeoutError("sem resposta")) as abrir, \
                patch.object(robo, "sleep"), patch.object(robo, "monotonic", side_effect=[0, 0, 2]):
            with self.assertRaisesRegex(TimeoutError, "Tempo limite"):
                robo.buscar_html("https://panini.com.br/teste", 3, 2)
        self.assertEqual(abrir.call_args.kwargs["timeout"], 2)
        self.assertEqual(abrir.call_count, 1)


if __name__ == "__main__":
    unittest.main()
