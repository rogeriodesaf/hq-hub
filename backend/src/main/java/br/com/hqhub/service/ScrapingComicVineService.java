package br.com.hqhub.service;

import java.util.List;
import java.util.Optional;

import org.eclipse.microprofile.rest.client.inject.RestClient;

import br.com.hqhub.dto.CadastroConhecimentoEditorialDTO;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ScrapingComicVineService {

    private final ConhecimentoEditorialService conhecimentoService;
    private final ComicVineApiClient comicVineClient;

    public ScrapingComicVineService(ConhecimentoEditorialService conhecimentoService,
            @RestClient ComicVineApiClient comicVineClient) {
        this.conhecimentoService = conhecimentoService;
        this.comicVineClient = comicVineClient;
    }

    @Transactional
    public void importarSerie(String serieNome) {
        // Busca a série no Comic Vine
        var resultado = comicVineClient.buscarSerie(serieNome);

        if (resultado != null && resultado.results() != null && !resultado.results().isEmpty()) {
            var serie = resultado.results().get(0);

            // Cadastra como conhecimento editorial
            var cadastro = new CadastroConhecimentoEditorialDTO(
                    "SAGA",
                    serie.name(),
                    serie.description() != null ? serie.description() : "Sem descrição disponível",
                    "Comic Vine - " + serie.name(),
                    serie.siteDetailUrl(),
                    "COMUNITARIA",
                    "COMIC_VINE",
                    "serie,quadrinhos");

            conhecimentoService.cadastrar(cadastro);
        }
    }

    @Transactional
    public void importarPersonagem(String personagemNome) {
        var resultado = comicVineClient.buscarPersonagem(personagemNome);

        if (resultado != null && resultado.results() != null && !resultado.results().isEmpty()) {
            var personagem = resultado.results().get(0);

            var cadastro = new CadastroConhecimentoEditorialDTO(
                    "HEROI",
                    personagem.name(),
                    personagem.description() != null ? personagem.description() : "Sem descrição",
                    "Comic Vine - " + personagem.name(),
                    personagem.siteDetailUrl(),
                    "COMUNITARIA",
                    "COMIC_VINE",
                    "heroi,personagem,quadrinhos");

            conhecimentoService.cadastrar(cadastro);
        }
    }

    @Transactional
    public void importarCriador(String criadorNome) {
        var resultado = comicVineClient.buscarCriador(criadorNome);

        if (resultado != null && resultado.results() != null && !resultado.results().isEmpty()) {
            var criador = resultado.results().get(0);

            var cadastro = new CadastroConhecimentoEditorialDTO(
                    "AUTOR",
                    criador.name(),
                    criador.description() != null ? criador.description() : "Sem descrição",
                    "Comic Vine - " + criador.name(),
                    criador.siteDetailUrl(),
                    "COMUNITARIA",
                    "COMIC_VINE",
                    "autor,criador,quadrinhos");

            conhecimentoService.cadastrar(cadastro);
        }
    }

    public Optional<String> buscarCuriosidade(String termo) {
        var resultado = comicVineClient.buscarSerie(termo);

        if (resultado != null && resultado.results() != null && !resultado.results().isEmpty()) {
            var serie = resultado.results().get(0);
            return Optional.ofNullable(serie.description());
        }

        return Optional.empty();
    }
}
