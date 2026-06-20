package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.CadastroComentarioFeedDTO;
import br.com.hqhub.dto.CadastroPostagemFeedDTO;
import br.com.hqhub.dto.ComentarioFeedRespostaDTO;
import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.dto.PostagemFeedRespostaDTO;
import br.com.hqhub.entity.ComentarioFeed;
import br.com.hqhub.entity.CurtidaPostagemFeed;
import br.com.hqhub.entity.ImagemPostagemFeed;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.ComentarioFeedRepository;
import br.com.hqhub.repository.CurtidaPostagemFeedRepository;
import br.com.hqhub.repository.ImagemPostagemFeedRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class FeedSocialService {

    private final PostagemFeedRepository postagemRepository;
    private final ComentarioFeedRepository comentarioRepository;
    private final CurtidaPostagemFeedRepository curtidaRepository;
    private final ImagemPostagemFeedRepository imagemRepository;
    private final AmizadeRepository amizadeRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final UsuarioMapper usuarioMapper;

    public FeedSocialService(
            PostagemFeedRepository postagemRepository,
            ComentarioFeedRepository comentarioRepository,
            CurtidaPostagemFeedRepository curtidaRepository,
            ImagemPostagemFeedRepository imagemRepository,
            AmizadeRepository amizadeRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            UsuarioMapper usuarioMapper) {
        this.postagemRepository = postagemRepository;
        this.comentarioRepository = comentarioRepository;
        this.curtidaRepository = curtidaRepository;
        this.imagemRepository = imagemRepository;
        this.amizadeRepository = amizadeRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.usuarioMapper = usuarioMapper;
    }

    @Transactional
    public List<PostagemFeedRespostaDTO> listarFeed(int pagina, int tamanho) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 50);

        return postagemRepository.listarFeed(usuario.getId(), paginaTratada, tamanhoTratado)
                .stream()
                .map(postagem -> paraResposta(postagem, usuario.getId()))
                .toList();
    }

    @Transactional
    public PostagemFeedRespostaDTO publicar(CadastroPostagemFeedDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = new PostagemFeed();
        postagem.setUsuario(usuario);
        postagem.setConteudo(dto.conteudo().trim());
        postagem.setUrlImagem(textoOuNull(dto.urlImagem()));
        postagemRepository.persist(postagem);
        salvarImagens(postagem, dto.imagens());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO alternarCurtida(Long postagemId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemVisivel(postagemId, usuario);

        curtidaRepository.buscarPorPostagemEUsuario(postagem.getId(), usuario.getId())
                .ifPresentOrElse(
                        curtidaRepository::delete,
                        () -> {
                            CurtidaPostagemFeed curtida = new CurtidaPostagemFeed();
                            curtida.setPostagem(postagem);
                            curtida.setUsuario(usuario);
                            curtidaRepository.persist(curtida);
                        });

        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO comentar(Long postagemId, CadastroComentarioFeedDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemVisivel(postagemId, usuario);

        ComentarioFeed comentario = new ComentarioFeed();
        comentario.setPostagem(postagem);
        comentario.setUsuario(usuario);
        comentario.setTexto(dto.texto().trim());
        comentarioRepository.persist(comentario);

        return paraResposta(postagem, usuario.getId());
    }

    private PostagemFeed buscarPostagemVisivel(Long postagemId, Usuario usuario) {
        PostagemFeed postagem = postagemRepository.findByIdOptional(postagemId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Postagem nao encontrada."));

        if (!podeVerPostagem(postagem, usuario)) {
            throw new RegraNegocioException("Voce nao pode interagir com esta postagem.");
        }

        return postagem;
    }

    private boolean podeVerPostagem(PostagemFeed postagem, Usuario usuario) {
        Long autorId = postagem.getUsuario().getId();
        return autorId.equals(usuario.getId()) || amizadeRepository.saoAmigos(usuario.getId(), autorId);
    }

    private PostagemFeedRespostaDTO paraResposta(PostagemFeed postagem, Long usuarioId) {
        List<ComentarioFeedRespostaDTO> comentarios = comentarioRepository.listarPorPostagem(postagem.getId())
                .stream()
                .map(comentario -> new ComentarioFeedRespostaDTO(
                        comentario.getId(),
                        usuarioMapper.paraResposta(comentario.getUsuario()),
                        comentario.getTexto(),
                        comentario.getDataCriacao()))
                .toList();

        List<ImagemFeedDTO> imagens = imagemRepository.listarPorPostagem(postagem.getId())
                .stream()
                .map(this::paraImagemResposta)
                .toList();

        return new PostagemFeedRespostaDTO(
                postagem.getId(),
                usuarioMapper.paraResposta(postagem.getUsuario()),
                postagem.getConteudo(),
                primeiraImagem(postagem, imagens),
                imagens,
                curtidaRepository.contarPorPostagem(postagem.getId()),
                curtidaRepository.existePorPostagemEUsuario(postagem.getId(), usuarioId),
                comentarios,
                postagem.getDataCriacao(),
                postagem.getDataAtualizacao());
    }

    private String textoOuNull(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim();
    }

    private void salvarImagens(PostagemFeed postagem, List<ImagemFeedDTO> imagens) {
        if (imagens == null || imagens.isEmpty()) {
            return;
        }

        if (imagens.size() > 3) {
            throw new RegraNegocioException("A postagem pode ter no maximo 3 imagens.");
        }

        for (int i = 0; i < imagens.size(); i++) {
            ImagemFeedDTO dto = imagens.get(i);
            ImagemPostagemFeed imagem = new ImagemPostagemFeed();
            imagem.setPostagem(postagem);
            imagem.setUrlImagem(dto.urlImagem());
            imagem.setUrlThumbnail(dto.urlThumbnail());
            imagem.setNomeArquivo(dto.nomeArquivo());
            imagem.setTipoMime(dto.tipoMime());
            imagem.setTamanhoBytes(dto.tamanhoBytes());
            imagem.setLargura(dto.largura());
            imagem.setAltura(dto.altura());
            imagem.setOrdem(dto.ordem() == null ? i : dto.ordem());
            imagemRepository.persist(imagem);
        }
    }

    private ImagemFeedDTO paraImagemResposta(ImagemPostagemFeed imagem) {
        return new ImagemFeedDTO(
                imagem.getUrlImagem(),
                imagem.getUrlThumbnail(),
                imagem.getNomeArquivo(),
                imagem.getTipoMime(),
                imagem.getTamanhoBytes(),
                imagem.getLargura(),
                imagem.getAltura(),
                imagem.getOrdem());
    }

    private String primeiraImagem(PostagemFeed postagem, List<ImagemFeedDTO> imagens) {
        if (!imagens.isEmpty()) {
            return imagens.get(0).urlImagem();
        }
        return postagem.getUrlImagem();
    }
}
