package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import br.com.hqhub.dto.CadastroContribuicaoCatalogoDTO;
import br.com.hqhub.dto.ContribuicaoCatalogoRespostaDTO;
import br.com.hqhub.dto.RevisaoContribuicaoCatalogoDTO;
import br.com.hqhub.entity.ContribuicaoCatalogo;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.PublicacaoRelacionada;
import br.com.hqhub.entity.StatusContribuicaoCatalogo;
import br.com.hqhub.entity.TipoContribuicaoCatalogo;
import br.com.hqhub.entity.TipoLinkEdicao;
import br.com.hqhub.entity.TipoPublicacaoRelacionada;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ContribuicaoCatalogoMapper;
import br.com.hqhub.repository.ContribuicaoCatalogoRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.LinkEdicaoRepository;
import br.com.hqhub.repository.PublicacaoRelacionadaRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ContribuicaoCatalogoService {

    private final ContribuicaoCatalogoRepository contribuicaoCatalogoRepository;
    private final EdicaoRepository edicaoRepository;
    private final PublicacaoRelacionadaRepository publicacaoRelacionadaRepository;
    private final LinkEdicaoRepository linkEdicaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AmizadeService amizadeService;
    private final ContribuicaoCatalogoMapper contribuicaoCatalogoMapper;

    public ContribuicaoCatalogoService(
            ContribuicaoCatalogoRepository contribuicaoCatalogoRepository,
            EdicaoRepository edicaoRepository,
            PublicacaoRelacionadaRepository publicacaoRelacionadaRepository,
            LinkEdicaoRepository linkEdicaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AmizadeService amizadeService,
            ContribuicaoCatalogoMapper contribuicaoCatalogoMapper) {
        this.contribuicaoCatalogoRepository = contribuicaoCatalogoRepository;
        this.edicaoRepository = edicaoRepository;
        this.publicacaoRelacionadaRepository = publicacaoRelacionadaRepository;
        this.linkEdicaoRepository = linkEdicaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.amizadeService = amizadeService;
        this.contribuicaoCatalogoMapper = contribuicaoCatalogoMapper;
    }

    @Transactional
    public ContribuicaoCatalogoRespostaDTO cadastrar(CadastroContribuicaoCatalogoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());
        validarContribuicao(dto);

        ContribuicaoCatalogo contribuicao = contribuicaoCatalogoMapper.paraEntidade(dto, usuario, edicao);
        contribuicaoCatalogoRepository.persist(contribuicao);

        return contribuicaoCatalogoMapper.paraResposta(contribuicao);
    }

    public List<ContribuicaoCatalogoRespostaDTO> listarMinhas() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return contribuicaoCatalogoRepository.listarPorUsuario(usuario.getId())
                .stream()
                .map(contribuicaoCatalogoMapper::paraResposta)
                .toList();
    }

    public List<ContribuicaoCatalogoRespostaDTO> listarPendentes() {
        return contribuicaoCatalogoRepository.listarPendentes()
                .stream()
                .map(contribuicaoCatalogoMapper::paraResposta)
                .toList();
    }

    public long contarPendentes() {
        return contribuicaoCatalogoRepository.contarPendentes();
    }

    public long contarAlteracoesEstanteAmigos(Long desdeMillis) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        List<Long> amigosIds = new ArrayList<>(amizadeService.listarIdsAmigos());
        amigosIds.remove(usuario.getId());

        LocalDateTime desde = desdeMillis == null || desdeMillis <= 0
                ? null
                : java.time.Instant.ofEpochMilli(desdeMillis)
                        .atZone(java.time.ZoneId.systemDefault())
                        .toLocalDateTime();

        return contribuicaoCatalogoRepository.contarAlteracoesEstantePorUsuarios(amigosIds, desde);
    }

    public List<ContribuicaoCatalogoRespostaDTO> listarAlteracoesEstanteAmigos(Long desdeMillis) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        List<Long> amigosIds = new ArrayList<>(amizadeService.listarIdsAmigos());
        amigosIds.remove(usuario.getId());

        LocalDateTime desde = desdeMillis == null || desdeMillis <= 0
                ? null
                : java.time.Instant.ofEpochMilli(desdeMillis)
                        .atZone(java.time.ZoneId.systemDefault())
                        .toLocalDateTime();

        return contribuicaoCatalogoRepository.listarAlteracoesEstantePorUsuarios(amigosIds, desde)
                .stream()
                .map(contribuicaoCatalogoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public ContribuicaoCatalogoRespostaDTO aprovar(Long id, RevisaoContribuicaoCatalogoDTO dto) {
        ContribuicaoCatalogo contribuicao = buscarPendentePorId(id);
        aplicarContribuicao(contribuicao);
        revisar(contribuicao, StatusContribuicaoCatalogo.APLICADA, dto.mensagemRevisao());
        return contribuicaoCatalogoMapper.paraResposta(contribuicao);
    }

    @Transactional
    public ContribuicaoCatalogoRespostaDTO recusar(Long id, RevisaoContribuicaoCatalogoDTO dto) {
        ContribuicaoCatalogo contribuicao = buscarPendentePorId(id);
        revisar(contribuicao, StatusContribuicaoCatalogo.RECUSADA, dto.mensagemRevisao());
        return contribuicaoCatalogoMapper.paraResposta(contribuicao);
    }

    private void validarContribuicao(CadastroContribuicaoCatalogoDTO dto) {
        if (dto.tipo() == TipoContribuicaoCatalogo.CAPA_EDICAO && estaVazio(dto.urlCapaSugerida())) {
            throw new RegraNegocioException("URL da capa sugerida é obrigatória para contribuição de capa.");
        }

        if (dto.tipo() == TipoContribuicaoCatalogo.PUBLICACAO_BRASILEIRA) {
            if (dto.edicaoDestinoId() == null || dto.tipoPublicacaoRelacionada() == null) {
                throw new RegraNegocioException("Edição de destino e tipo de publicação são obrigatórios.");
            }
            if (dto.edicaoId().equals(dto.edicaoDestinoId())) {
                throw new RegraNegocioException("Edição de origem e edição de destino devem ser diferentes.");
            }
            buscarEdicaoPorId(dto.edicaoDestinoId());
        }

        if (dto.tipo() == TipoContribuicaoCatalogo.LINK_GUIA_DOS_QUADRINHOS && estaVazio(dto.urlFonte())) {
            throw new RegraNegocioException("URL do Guia dos Quadrinhos é obrigatória para esta contribuição.");
        }
    }

    private void aplicarContribuicao(ContribuicaoCatalogo contribuicao) {
        if (contribuicao.getTipo() == TipoContribuicaoCatalogo.CAPA_EDICAO) {
            contribuicao.getEdicao().setUrlCapa(contribuicao.getUrlCapaSugerida());
            return;
        }

        if (contribuicao.getTipo() == TipoContribuicaoCatalogo.PUBLICACAO_BRASILEIRA) {
            aplicarPublicacaoBrasileira(contribuicao);
            return;
        }

        if (contribuicao.getTipo() == TipoContribuicaoCatalogo.LINK_GUIA_DOS_QUADRINHOS) {
            aplicarLinkGuia(contribuicao);
        }
    }

    private void aplicarPublicacaoBrasileira(ContribuicaoCatalogo contribuicao) {
        Long origemId = contribuicao.getEdicao().getId();
        Long destinoId = contribuicao.getEdicaoDestinoId();
        TipoPublicacaoRelacionada tipo = contribuicao.getTipoPublicacaoRelacionada();

        if (publicacaoRelacionadaRepository.existePorOrigemDestinoTipo(origemId, destinoId, tipo)) {
            return;
        }

        PublicacaoRelacionada publicacao = new PublicacaoRelacionada();
        publicacao.setEdicaoOrigem(contribuicao.getEdicao());
        publicacao.setEdicaoDestino(buscarEdicaoPorId(destinoId));
        publicacao.setTipo(tipo);
        publicacao.setFonteExterna(contribuicao.getFonteExterna());
        publicacao.setUrlOrigem(contribuicao.getUrlFonte());
        publicacao.setObservacoes(contribuicao.getObservacoes());
        publicacaoRelacionadaRepository.persist(publicacao);
    }

    private void aplicarLinkGuia(ContribuicaoCatalogo contribuicao) {
        Long edicaoId = contribuicao.getEdicao().getId();
        String url = contribuicao.getUrlFonte();

        if (linkEdicaoRepository.existePorEdicaoEUrl(edicaoId, url)) {
            return;
        }

        br.com.hqhub.entity.LinkEdicao link = new br.com.hqhub.entity.LinkEdicao();
        link.setEdicao(contribuicao.getEdicao());
        link.setTipo(TipoLinkEdicao.GUIA_DOS_QUADRINHOS);
        link.setTitulo("Guia dos Quadrinhos");
        link.setUrl(url);
        link.setObservacoes(contribuicao.getObservacoes());
        linkEdicaoRepository.persist(link);
    }

    private void revisar(ContribuicaoCatalogo contribuicao, StatusContribuicaoCatalogo status, String mensagem) {
        contribuicao.setStatus(status);
        contribuicao.setMensagemRevisao(mensagem);
        contribuicao.setDataRevisao(LocalDateTime.now());
    }

    private ContribuicaoCatalogo buscarPendentePorId(Long id) {
        return contribuicaoCatalogoRepository.find("id = ?1 and status = ?2", id, StatusContribuicaoCatalogo.PENDENTE)
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Contribuição pendente não encontrada."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }

    private boolean estaVazio(String valor) {
        return valor == null || valor.isBlank();
    }
}
