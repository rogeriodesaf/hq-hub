package br.com.hqhub.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import br.com.hqhub.entity.*;
import br.com.hqhub.repository.*;

class HistoriaPublicacoesBrasilTest {
    @Test
    void historiasPresentesComStatusDesconhecidoNaoComprovamPublicacaoCompleta() {
        assertNull(consultar(StatusPublicacaoHistoria.DESCONHECIDA).publicacoes().getFirst().publicacaoCompleta());
        assertNull(consultar(StatusPublicacaoHistoria.CORTADA).publicacoes().getFirst().publicacaoCompleta());
        assertEquals(Boolean.TRUE, consultar(StatusPublicacaoHistoria.COMPLETA).publicacoes().getFirst().publicacaoCompleta());
    }

    private br.com.hqhub.dto.PublicacoesBrasileirasEdicaoOriginalDTO consultar(StatusPublicacaoHistoria status) {
        EdicaoRepository edicoes = mock(EdicaoRepository.class);
        PublicacaoHistoriaRepository publicacoes = mock(PublicacaoHistoriaRepository.class);
        ConteudoEdicaoRepository conteudos = mock(ConteudoEdicaoRepository.class);
        Edicao original = edicao(1L, "Marvel Comics", "The Amazing Spider-Man", TipoSerie.ESTRANGEIRA);
        Edicao brasileira = edicao(2L, "Abril", "Superalmanaque Marvel", TipoSerie.BRASILEIRA);
        Historia historia = new Historia(); historia.setId(5L); historia.setTitulo("O Sindicato Sinistro");
        ConteudoEdicao conteudo = new ConteudoEdicao(); conteudo.setHistoria(historia);
        PublicacaoHistoria vinculo = new PublicacaoHistoria();
        vinculo.setHistoria(historia); vinculo.setEdicaoOriginal(original); vinculo.setEdicaoPublicada(brasileira); vinculo.setStatus(status);
        when(edicoes.findByIdOptional(1L)).thenReturn(Optional.of(original));
        when(edicoes.resolverOriginalComVinculos(original)).thenReturn(original);
        when(edicoes.listarIdsOriginaisCorrespondentes(original)).thenReturn(List.of(1L, 9L));
        when(publicacoes.listarPublicacoesBrasileirasComDados(List.of(1L, 9L))).thenReturn(List.of(vinculo));
        when(conteudos.listarPorEdicaoComHistoria(1L)).thenReturn(List.of(conteudo));
        HistoriaService service = new HistoriaService(null, edicoes, conteudos, publicacoes, null, null, null, null, null, null);
        var resultado = service.listarPublicacoesBrasileirasPublicas(1L);
        assertEquals(1, resultado.totalPublicacoes());
        assertEquals("Abril", resultado.publicacoes().getFirst().editora());
        verify(publicacoes).listarPublicacoesBrasileirasComDados(List.of(1L, 9L));
        return resultado;
    }

    private Edicao edicao(Long id, String nomeEditora, String tituloSerie, TipoSerie tipo) {
        Editora editora = new Editora(); editora.setNome(nomeEditora);
        Serie serie = new Serie(); serie.setEditora(editora); serie.setTitulo(tituloSerie); serie.setTipoSerie(tipo);
        Edicao edicao = new Edicao(); edicao.setId(id); edicao.setSerie(serie); edicao.setNumero("280");
        edicao.setDataPublicacao(LocalDate.of(1986, 9, 1));
        return edicao;
    }
}
