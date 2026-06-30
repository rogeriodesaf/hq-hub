package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.jboss.resteasy.reactive.multipart.FileUpload;

import br.com.hqhub.dto.CapaEdicaoRespostaDTO;
import br.com.hqhub.dto.ImagemArmazenadaDTO;
import br.com.hqhub.dto.ImportacaoCapaJsonDTO;
import br.com.hqhub.dto.ResultadoImportacaoCapasDTO;
import br.com.hqhub.dto.ResultadoImportacaoCapasDTO.ItemImportacaoCapaDTO;
import br.com.hqhub.entity.CapaEdicao;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.OrigemCapaEdicao;
import br.com.hqhub.entity.StatusCapaEdicao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.repository.CapaEdicaoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class CapaEdicaoService {

    private final CapaEdicaoRepository capaEdicaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final ArmazenamentoImagemService armazenamentoImagemService;

    public CapaEdicaoService(
            CapaEdicaoRepository capaEdicaoRepository,
            EdicaoRepository edicaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            ArmazenamentoImagemService armazenamentoImagemService) {
        this.capaEdicaoRepository = capaEdicaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.armazenamentoImagemService = armazenamentoImagemService;
    }

    @Transactional
    public CapaEdicaoRespostaDTO enviarUpload(Long edicaoId, FileUpload arquivo) {
        ImagemArmazenadaDTO imagem = armazenamentoImagemService.salvarCapa(arquivo);
        return registrarCapa(edicaoId, imagem, OrigemCapaEdicao.UPLOAD_MANUAL, null);
    }

    @Transactional
    public CapaEdicaoRespostaDTO enviarUrl(Long edicaoId, String urlImagem) {
        ImagemArmazenadaDTO imagem = armazenamentoImagemService.salvarCapaPorUrl(urlImagem);
        return registrarCapa(edicaoId, imagem, OrigemCapaEdicao.URL_MANUAL, "URL original: " + urlImagem.trim());
    }

    @Transactional
    public ResultadoImportacaoCapasDTO importarJson(List<ImportacaoCapaJsonDTO> itens) {
        List<ImportacaoCapaJsonDTO> lista = itens == null ? List.of() : itens;
        List<ItemImportacaoCapaDTO> resultados = new ArrayList<>();
        int sucessos = 0;

        for (ImportacaoCapaJsonDTO item : lista) {
            try {
                CapaEdicaoRespostaDTO capa = importarItem(item);
                resultados.add(new ItemImportacaoCapaDTO(item.idEdicao(), item.urlImagem(), true, "Capa enviada para analise.", capa));
                sucessos++;
            } catch (RuntimeException e) {
                resultados.add(new ItemImportacaoCapaDTO(
                        item == null ? null : item.idEdicao(),
                        item == null ? null : item.urlImagem(),
                        false,
                        e.getMessage(),
                        null));
            }
        }

        return new ResultadoImportacaoCapasDTO(lista.size(), sucessos, lista.size() - sucessos, resultados);
    }

    @Transactional
    public List<CapaEdicaoRespostaDTO> listarPorEdicao(Long edicaoId) {
        buscarEdicao(edicaoId);
        return capaEdicaoRepository.listarPorEdicao(edicaoId).stream()
                .map(this::paraResposta)
                .toList();
    }

    @Transactional
    public CapaEdicaoRespostaDTO aprovar(Long capaId) {
        CapaEdicao capa = buscarCapa(capaId);
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        for (CapaEdicao aprovada : capaEdicaoRepository.listarAprovadasPorEdicao(capa.getEdicao().getId())) {
            if (!aprovada.getId().equals(capa.getId())) {
                aprovada.setStatus(StatusCapaEdicao.REJEITADA);
            }
        }

        capa.setStatus(StatusCapaEdicao.APROVADA);
        capa.setDataAprovacao(LocalDateTime.now());
        capa.setAprovadoPorUsuario(usuario);
        capa.getEdicao().setUrlCapa(capa.getUrlImagem());
        return paraResposta(capa);
    }

    @Transactional
    public CapaEdicaoRespostaDTO rejeitar(Long capaId) {
        CapaEdicao capa = buscarCapa(capaId);
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        capa.setStatus(StatusCapaEdicao.REJEITADA);
        capa.setDataAprovacao(LocalDateTime.now());
        capa.setAprovadoPorUsuario(usuario);
        return paraResposta(capa);
    }

    @Transactional
    CapaEdicaoRespostaDTO registrarCapa(Long edicaoId, ImagemArmazenadaDTO imagem, OrigemCapaEdicao origem, String observacao) {
        Edicao edicao = buscarEdicao(edicaoId);
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        CapaEdicao capa = new CapaEdicao();
        capa.setEdicao(edicao);
        capa.setUrlImagem(imagem.urlImagem());
        capa.setPublicIdCloudinary(imagem.publicIdCloudinary());
        capa.setEnviadoPorUsuario(usuario);
        capa.setOrigem(origem);
        capa.setStatus(StatusCapaEdicao.PENDENTE);
        capa.setObservacao(observacao);
        capaEdicaoRepository.persist(capa);

        return paraResposta(capa);
    }

    @Transactional
    CapaEdicaoRespostaDTO importarItem(ImportacaoCapaJsonDTO item) {
        if (item == null) {
            throw new RecursoNaoEncontradoException("Item de importacao invalido.");
        }
        ImagemArmazenadaDTO imagem = armazenamentoImagemService.salvarCapaPorUrl(item.urlImagem());
        return registrarCapa(item.idEdicao(), imagem, OrigemCapaEdicao.IMPORTACAO_JSON, "URL original: " + item.urlImagem().trim());
    }

    private Edicao buscarEdicao(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edicao nao encontrada."));
    }

    private CapaEdicao buscarCapa(Long id) {
        return capaEdicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Capa nao encontrada."));
    }

    private CapaEdicaoRespostaDTO paraResposta(CapaEdicao capa) {
        Usuario enviadoPor = capa.getEnviadoPorUsuario();
        Usuario aprovadoPor = capa.getAprovadoPorUsuario();
        return new CapaEdicaoRespostaDTO(
                capa.getId(),
                capa.getEdicao().getId(),
                capa.getUrlImagem(),
                capa.getPublicIdCloudinary(),
                enviadoPor == null ? null : enviadoPor.getId(),
                enviadoPor == null ? null : enviadoPor.getNome(),
                capa.getStatus(),
                capa.getOrigem(),
                capa.getObservacao(),
                capa.getDataEnvio(),
                capa.getDataAprovacao(),
                aprovadoPor == null ? null : aprovadoPor.getId(),
                aprovadoPor == null ? null : aprovadoPor.getNome());
    }
}
