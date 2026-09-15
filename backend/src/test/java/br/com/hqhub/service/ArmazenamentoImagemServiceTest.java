package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.nio.charset.StandardCharsets;

import org.junit.jupiter.api.Test;

class ArmazenamentoImagemServiceTest {

    @Test
    void deveDetectarAvifPelaMarcaPrincipal() {
        byte[] cabecalho = cabecalhoFtyp("avif", "mif1");

        assertEquals("image/avif", ArmazenamentoImagemService.detectarTipoPorCabecalho(cabecalho));
    }

    @Test
    void deveDetectarAvifPelaMarcaCompativel() {
        byte[] cabecalho = cabecalhoFtyp("mif1", "avif");

        assertEquals("image/avif", ArmazenamentoImagemService.detectarTipoPorCabecalho(cabecalho));
    }

    @Test
    void naoDeveAceitarFtypSemMarcaAvif() {
        byte[] cabecalho = cabecalhoFtyp("mif1", "heic");

        assertEquals("", ArmazenamentoImagemService.detectarTipoPorCabecalho(cabecalho));
    }

    private byte[] cabecalhoFtyp(String marcaPrincipal, String marcaCompativel) {
        byte[] cabecalho = new byte[20];
        cabecalho[3] = 20;
        copiarMarca(cabecalho, 4, "ftyp");
        copiarMarca(cabecalho, 8, marcaPrincipal);
        copiarMarca(cabecalho, 16, marcaCompativel);
        return cabecalho;
    }

    private void copiarMarca(byte[] destino, int inicio, String marca) {
        byte[] bytes = marca.getBytes(StandardCharsets.US_ASCII);
        System.arraycopy(bytes, 0, destino, inicio, 4);
    }
}
