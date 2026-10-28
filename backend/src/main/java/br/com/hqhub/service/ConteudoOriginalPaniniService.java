package br.com.hqhub.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.text.Normalizer;
import java.time.Duration;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import br.com.hqhub.dto.CadastroConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO.CandidatoEdicaoOriginalPaniniDTO;
import br.com.hqhub.dto.PreviaConteudoOriginalPaniniDTO.ReferenciaConteudoOriginalPaniniDTO;
import br.com.hqhub.dto.ResultadoCadastroConteudoOriginalPaniniDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import br.com.hqhub.entity.TipoSerie;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ConteudoOriginalPaniniService {

    private static final String FONTE_PANINI = "PANINI";
    private final EdicaoRepository edicaoRepository;
    private final PublicacaoRelacionadaRepository publicacaoRelacionadaRepository;
    private final ConteudoOriginalPaniniParser parser;
    private final HttpClient httpClient;

    public ConteudoOriginalPaniniService(
            EdicaoRepository edicaoRepository,
            PublicacaoRelacionadaRepository publicacaoRelacionadaRepository,
            ConteudoOriginalPaniniParser parser) {
        this.edicaoRepository = edicaoRepository;
        this.publicacaoRelacionadaRepository = publicacaoRelacionadaRepository;
        this.parser = parser;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(12))
                .followRedirects(HttpClient.Redirect.NEVER)
                .build();
    }

    @Transactional
    public PreviaConteudoOriginalPaniniDTO analisar(String url) {
        URI uri = validarUrlPanini(url);
        String html = carregarPagina(uri);
        ConteudoOriginalPaniniParser.PaginaPanini pagina = parser.extrair(html);
        if (pagina.conteudoOriginal() == null || pagina.conteudoOriginal().isBlank()) {
            throw new RegraNegocioException("A página informada não possui o campo Conteúdo original.");
        }

        List<ReferenciaConteudoOriginalPaniniDTO> referencias = pagina.referencias().stream()
                .map(referencia -> {
                    List<CandidatoEdicaoOriginalPaniniDTO> candidatos = buscarCandidatos(referencia);
                    String status = referencia.serie() == null ? "NAO_INTERPRETADA"
                            : candidatos.isEmpty() ? "NAO_ENCONTRADA"
                            : candidatos.size() == 1 ? "ENCONTRADA" : "AMBIGUA";
                    return new ReferenciaConteudoOriginalPaniniDTO(
                            pagina.referencias().indexOf(referencia),
                            referencia.textoOriginal(),
                            referencia.serie(),
                            referencia.anoSerie(),
                            referencia.numero(),
                            referencia.complemento(),
                            status,
                            candidatos);
                })
                .toList();

        return new PreviaConteudoOriginalPaniniDTO(uri.toString(), pagina.titulo(), pagina.conteudoOriginal(), referencias);
    }

    @Transactional
    public ResultadoCadastroConteudoOriginalPaniniDTO cadastrar(CadastroConteudoOriginalPaniniDTO dto) {
        URI uri = validarUrlPanini(dto.urlPanini());
        Edicao brasileira = buscarEdicao(dto.edicaoBrasileiraId());
        if (brasileira.getSerie().getTipoSerie() != TipoSerie.BRASILEIRA) {
            throw new RegraNegocioException("A edição de destino precisa pertencer ao catálogo brasileiro.");
        }

        int cadastrados = 0;
        int jaExistentes = 0;
        Set<Long> idsProcessados = new LinkedHashSet<>();
        for (CadastroConteudoOriginalPaniniDTO.VinculoConteudoOriginalPaniniDTO vinculo : dto.vinculos()) {
            if (!idsProcessados.add(vinculo.edicaoOriginalId())) {
                continue;
            }
            Edicao original = buscarEdicao(vinculo.edicaoOriginalId());
            if (original.getSerie().getTipoSerie() != TipoSerie.ESTRANGEIRA) {
                throw new RegraNegocioException("A edição original de ID " + original.getId() + " não é estrangeira.");
            }
            if (publicacaoRelacionadaRepository.existePorOrigemDestinoTipo(
                    original.getId(), brasileira.getId(), TipoPublicacaoRelacionada.PUBLICADA_NO_BRASIL)) {
                jaExistentes++;
                continue;
            }

            PublicacaoRelacionada publicacao = new PublicacaoRelacionada();
            publicacao.setEdicaoOrigem(original);
            publicacao.setEdicaoDestino(brasileira);
            publicacao.setTipo(TipoPublicacaoRelacionada.PUBLICADA_NO_BRASIL);
            publicacao.setFonteExterna(FONTE_PANINI);
            publicacao.setUrlOrigem(uri.toString());
            publicacao.setObservacoes("Referência declarada pela Panini: " + vinculo.referenciaOriginal().trim());
            publicacaoRelacionadaRepository.persist(publicacao);
            cadastrados++;
        }
        return new ResultadoCadastroConteudoOriginalPaniniDTO(cadastrados, jaExistentes);
    }

    private List<CandidatoEdicaoOriginalPaniniDTO> buscarCandidatos(
            ConteudoOriginalPaniniParser.ReferenciaExtraida referencia) {
        if (referencia.serie() == null || referencia.numero() == null) {
            return List.of();
        }
        String busca = referencia.serie() + " " + referencia.numero();
        return edicaoRepository.buscarPaginado(null, busca, 0, 50, TipoSerie.ESTRANGEIRA).stream()
                .filter(edicao -> normalizar(edicao.getSerie().getTitulo()).equals(normalizar(referencia.serie())))
                .filter(edicao -> normalizar(edicao.getNumero()).equals(normalizar(referencia.numero())))
                .filter(edicao -> referencia.anoSerie() == null
                        || referencia.anoSerie().equals(edicao.getSerie().getAnoInicio()))
                .limit(5)
                .map(edicao -> new CandidatoEdicaoOriginalPaniniDTO(
                        edicao.getId(), edicao.getSerie().getTitulo(), edicao.getNumero(),
                        edicao.getSerie().getAnoInicio(), edicao.getSerie().getEditora().getNome(), edicao.getUrlCapa()))
                .toList();
    }

    private String carregarPagina(URI uri) {
        URI atual = uri;
        try {
            for (int redirecionamentos = 0; redirecionamentos <= 3; redirecionamentos++) {
                HttpRequest requisicao = HttpRequest.newBuilder(atual)
                        .timeout(Duration.ofSeconds(20))
                        .header("User-Agent", "Mozilla/5.0 (compatible; ColecionaHQ/1.0)")
                        .header("Accept", "text/html,application/xhtml+xml")
                        .GET()
                        .build();
                HttpResponse<String> resposta = httpClient.send(requisicao,
                        HttpResponse.BodyHandlers.ofString(java.nio.charset.StandardCharsets.UTF_8));
                if (resposta.statusCode() >= 300 && resposta.statusCode() < 400) {
                    String destino = resposta.headers().firstValue("location")
                            .orElseThrow(() -> new RegraNegocioException("Redirecionamento inválido retornado pela Panini."));
                    atual = validarUrlPanini(atual.resolve(destino).toString());
                    continue;
                }
                if (resposta.statusCode() < 200 || resposta.statusCode() >= 300) {
                    throw new RegraNegocioException("A Panini respondeu com status " + resposta.statusCode() + ".");
                }
                return resposta.body();
            }
            throw new RegraNegocioException("A página da Panini redirecionou muitas vezes.");
        } catch (InterruptedException excecao) {
            Thread.currentThread().interrupt();
            throw new RegraNegocioException("A consulta à Panini foi interrompida.");
        } catch (java.io.IOException excecao) {
            throw new RegraNegocioException("Não foi possível consultar a página da Panini.");
        }
    }

    private URI validarUrlPanini(String url) {
        try {
            URI uri = URI.create(url == null ? "" : url.trim());
            String host = uri.getHost() == null ? "" : uri.getHost().toLowerCase(Locale.ROOT);
            boolean hostPermitido = host.equals("panini.com.br") || host.equals("www.panini.com.br");
            if (!"https".equalsIgnoreCase(uri.getScheme()) || !hostPermitido || uri.getUserInfo() != null
                    || (uri.getPort() != -1 && uri.getPort() != 443)) {
                throw new RegraNegocioException("Informe uma URL HTTPS válida do domínio panini.com.br.");
            }
            return uri;
        } catch (IllegalArgumentException excecao) {
            throw new RegraNegocioException("Informe uma URL HTTPS válida do domínio panini.com.br.");
        }
    }

    private Edicao buscarEdicao(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada: " + id));
    }

    private String normalizar(String valor) {
        return Normalizer.normalize(valor == null ? "" : valor, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replaceAll("[^a-zA-Z0-9]", "")
                .toLowerCase(Locale.ROOT);
    }
}
