package br.com.hqhub.service;

import java.util.Arrays;
import java.util.List;

import br.com.hqhub.dto.CadastroComentarioColecaoDTO;
import br.com.hqhub.dto.ComentarioColecaoRespostaDTO;
import br.com.hqhub.dto.InteracaoItemColecaoDTO;
import br.com.hqhub.dto.InteracaoSocialColecaoDTO;
import br.com.hqhub.dto.InteracoesColecaoUsuarioDTO;
import br.com.hqhub.entity.ComentarioColecao;
import br.com.hqhub.entity.ComentarioItemColecao;
import br.com.hqhub.entity.ConfiguracaoColecao;
import br.com.hqhub.entity.CurtidaColecao;
import br.com.hqhub.entity.CurtidaItemColecao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VisibilidadeColecao;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.ComentarioColecaoRepository;
import br.com.hqhub.repository.ComentarioItemColecaoRepository;
import br.com.hqhub.repository.ConfiguracaoColecaoRepository;
import br.com.hqhub.repository.CurtidaColecaoRepository;
import br.com.hqhub.repository.CurtidaItemColecaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ColecaoSocialService {

    private final UsuarioRepository usuarioRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final ConfiguracaoColecaoRepository configuracaoColecaoRepository;
    private final AmizadeRepository amizadeRepository;
    private final CurtidaColecaoRepository curtidaColecaoRepository;
    private final ComentarioColecaoRepository comentarioColecaoRepository;
    private final CurtidaItemColecaoRepository curtidaItemRepository;
    private final ComentarioItemColecaoRepository comentarioItemRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final UsuarioMapper usuarioMapper;

    public ColecaoSocialService(
            UsuarioRepository usuarioRepository,
            ItemColecaoRepository itemColecaoRepository,
            ConfiguracaoColecaoRepository configuracaoColecaoRepository,
            AmizadeRepository amizadeRepository,
            CurtidaColecaoRepository curtidaColecaoRepository,
            ComentarioColecaoRepository comentarioColecaoRepository,
            CurtidaItemColecaoRepository curtidaItemRepository,
            ComentarioItemColecaoRepository comentarioItemRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            UsuarioMapper usuarioMapper) {
        this.usuarioRepository = usuarioRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.configuracaoColecaoRepository = configuracaoColecaoRepository;
        this.amizadeRepository = amizadeRepository;
        this.curtidaColecaoRepository = curtidaColecaoRepository;
        this.comentarioColecaoRepository = comentarioColecaoRepository;
        this.curtidaItemRepository = curtidaItemRepository;
        this.comentarioItemRepository = comentarioItemRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.usuarioMapper = usuarioMapper;
    }

    @Transactional
    public InteracoesColecaoUsuarioDTO obterInteracoes(Long usuarioId, String itemIds) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario donoColecao = buscarDonoColecao(usuarioId);
        validarPermissaoInteracao(usuario, donoColecao);

        List<Long> ids = parseItemIds(itemIds);
        List<InteracaoItemColecaoDTO> itens = ids.stream()
                .map(id -> buscarItemVisivel(id, donoColecao))
                .map(item -> paraRespostaItem(item, usuario.getId()))
                .toList();

        return new InteracoesColecaoUsuarioDTO(
                donoColecao.getId(),
                paraRespostaColecao(donoColecao.getId(), usuario.getId()),
                itens);
    }

    @Transactional
    public InteracaoSocialColecaoDTO alternarCurtidaColecao(Long usuarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario donoColecao = buscarDonoColecao(usuarioId);
        validarPermissaoInteracao(usuario, donoColecao);

        curtidaColecaoRepository.buscarPorColecaoEUsuario(donoColecao.getId(), usuario.getId())
                .ifPresentOrElse(
                        curtidaColecaoRepository::delete,
                        () -> {
                            CurtidaColecao curtida = new CurtidaColecao();
                            curtida.setDonoColecao(donoColecao);
                            curtida.setUsuario(usuario);
                            curtidaColecaoRepository.persist(curtida);
                        });

        return paraRespostaColecao(donoColecao.getId(), usuario.getId());
    }

    @Transactional
    public InteracaoSocialColecaoDTO comentarColecao(Long usuarioId, CadastroComentarioColecaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario donoColecao = buscarDonoColecao(usuarioId);
        validarPermissaoInteracao(usuario, donoColecao);

        ComentarioColecao comentario = new ComentarioColecao();
        comentario.setDonoColecao(donoColecao);
        comentario.setUsuario(usuario);
        comentario.setTexto(dto.texto().trim());
        comentarioColecaoRepository.persist(comentario);

        return paraRespostaColecao(donoColecao.getId(), usuario.getId());
    }

    @Transactional
    public InteracaoSocialColecaoDTO removerComentarioColecao(Long usuarioId, Long comentarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Usuario donoColecao = buscarDonoColecao(usuarioId);
        validarPermissaoInteracao(usuario, donoColecao);
        ComentarioColecao comentario = comentarioColecaoRepository.findByIdOptional(comentarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Comentario nao encontrado."));

        if (!comentario.getDonoColecao().getId().equals(donoColecao.getId())) {
            throw new RecursoNaoEncontradoException("Comentario nao encontrado.");
        }
        if (!comentario.getUsuario().getId().equals(usuario.getId())) {
            throw new RegraNegocioException("Voce so pode apagar comentarios criados por voce.");
        }

        comentarioColecaoRepository.delete(comentario);
        return paraRespostaColecao(donoColecao.getId(), usuario.getId());
    }

    @Transactional
    public InteracaoItemColecaoDTO alternarCurtidaItem(Long itemColecaoId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ItemColecao item = buscarItemInteragivel(itemColecaoId, usuario);

        curtidaItemRepository.buscarPorItemEUsuario(item.getId(), usuario.getId())
                .ifPresentOrElse(
                        curtidaItemRepository::delete,
                        () -> {
                            CurtidaItemColecao curtida = new CurtidaItemColecao();
                            curtida.setItemColecao(item);
                            curtida.setUsuario(usuario);
                            curtidaItemRepository.persist(curtida);
                        });

        return paraRespostaItem(item, usuario.getId());
    }

    @Transactional
    public InteracaoItemColecaoDTO comentarItem(Long itemColecaoId, CadastroComentarioColecaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ItemColecao item = buscarItemInteragivel(itemColecaoId, usuario);

        ComentarioItemColecao comentario = new ComentarioItemColecao();
        comentario.setItemColecao(item);
        comentario.setUsuario(usuario);
        comentario.setTexto(dto.texto().trim());
        comentarioItemRepository.persist(comentario);

        return paraRespostaItem(item, usuario.getId());
    }

    @Transactional
    public InteracaoItemColecaoDTO removerComentarioItem(Long itemColecaoId, Long comentarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ItemColecao item = buscarItemInteragivel(itemColecaoId, usuario);
        ComentarioItemColecao comentario = comentarioItemRepository.findByIdOptional(comentarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Comentario nao encontrado."));

        if (!comentario.getItemColecao().getId().equals(item.getId())) {
            throw new RecursoNaoEncontradoException("Comentario nao encontrado.");
        }
        if (!comentario.getUsuario().getId().equals(usuario.getId())) {
            throw new RegraNegocioException("Voce so pode apagar comentarios criados por voce.");
        }

        comentarioItemRepository.delete(comentario);
        return paraRespostaItem(item, usuario.getId());
    }

    private Usuario buscarDonoColecao(Long usuarioId) {
        return usuarioRepository.findByIdOptional(usuarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuario nao encontrado."));
    }

    private ItemColecao buscarItemInteragivel(Long itemColecaoId, Usuario usuario) {
        ItemColecao item = itemColecaoRepository.findByIdOptional(itemColecaoId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da colecao nao encontrado."));
        validarPermissaoInteracao(usuario, item.getUsuario());
        return item;
    }

    private ItemColecao buscarItemVisivel(Long itemColecaoId, Usuario donoColecao) {
        return itemColecaoRepository.find("id = ?1 and usuario.id = ?2", itemColecaoId, donoColecao.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da colecao nao encontrado."));
    }

    private void validarPermissaoInteracao(Usuario usuario, Usuario donoColecao) {
        if (usuario.getId().equals(donoColecao.getId())) {
            return;
        }

        ConfiguracaoColecao configuracao = configuracaoColecaoRepository.buscarPorUsuario(donoColecao.getId())
                .orElse(null);
        VisibilidadeColecao visibilidade = configuracao == null
                ? VisibilidadeColecao.PRIVADA
                : configuracao.getVisibilidadeColecao();

        boolean visivelParaAmigos = visibilidade == VisibilidadeColecao.AMIGOS || visibilidade == VisibilidadeColecao.PUBLICA;
        if (visivelParaAmigos && amizadeRepository.saoAmigos(usuario.getId(), donoColecao.getId())) {
            return;
        }

        throw new RegraNegocioException("Voce nao pode interagir com esta colecao.");
    }

    private List<Long> parseItemIds(String itemIds) {
        if (itemIds == null || itemIds.isBlank()) {
            return List.of();
        }
        return Arrays.stream(itemIds.split(","))
                .map(String::trim)
                .filter(valor -> !valor.isBlank())
                .map(Long::valueOf)
                .distinct()
                .limit(100)
                .toList();
    }

    private InteracaoSocialColecaoDTO paraRespostaColecao(Long donoColecaoId, Long usuarioId) {
        List<ComentarioColecaoRespostaDTO> comentarios = comentarioColecaoRepository.listarPorColecao(donoColecaoId)
                .stream()
                .map(comentario -> new ComentarioColecaoRespostaDTO(
                        comentario.getId(),
                        usuarioMapper.paraResposta(comentario.getUsuario()),
                        comentario.getTexto(),
                        comentario.getDataCriacao()))
                .toList();

        return new InteracaoSocialColecaoDTO(
                curtidaColecaoRepository.contarPorColecao(donoColecaoId),
                curtidaColecaoRepository.existePorColecaoEUsuario(donoColecaoId, usuarioId),
                comentarios);
    }

    private InteracaoItemColecaoDTO paraRespostaItem(ItemColecao item, Long usuarioId) {
        List<ComentarioColecaoRespostaDTO> comentarios = comentarioItemRepository.listarPorItem(item.getId())
                .stream()
                .map(comentario -> new ComentarioColecaoRespostaDTO(
                        comentario.getId(),
                        usuarioMapper.paraResposta(comentario.getUsuario()),
                        comentario.getTexto(),
                        comentario.getDataCriacao()))
                .toList();

        return new InteracaoItemColecaoDTO(
                item.getId(),
                curtidaItemRepository.contarPorItem(item.getId()),
                curtidaItemRepository.existePorItemEUsuario(item.getId(), usuarioId),
                comentarios);
    }
}
