package br.com.hqhub.service;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import br.com.hqhub.dto.AtualizacaoVideosRelacionadosDTO;
import br.com.hqhub.dto.AtividadeEstanteDTO;
import br.com.hqhub.dto.AtualizacaoCanalParceiroDTO;
import br.com.hqhub.dto.CadastroComentarioFeedDTO;
import br.com.hqhub.dto.CadastroPostagemFeedDTO;
import br.com.hqhub.dto.AtualizacaoPostagemFeedDTO;
import br.com.hqhub.dto.CadastroVideoRelacionadoDTO;
import br.com.hqhub.dto.CanalParceiroDTO;
import br.com.hqhub.dto.CatalogoFeedDTO;
import br.com.hqhub.dto.ColecaoFeedDTO;
import br.com.hqhub.dto.ComentarioFeedRespostaDTO;
import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.dto.EdicaoAtividadeEstanteDTO;
import br.com.hqhub.dto.PostagemFeedRespostaDTO;
import br.com.hqhub.dto.PostagemPublicaDTO;
import br.com.hqhub.dto.VideoRelacionadoDTO;
import br.com.hqhub.entity.ComentarioFeed;
import br.com.hqhub.entity.CurtidaComentarioFeed;
import br.com.hqhub.entity.CurtidaPostagemFeed;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.EdicaoAtividadeEstante;
import br.com.hqhub.entity.ImagemPostagemFeed;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.PostagemFeed;
import br.com.hqhub.entity.PerfilUsuario;
import br.com.hqhub.entity.Serie;
import br.com.hqhub.entity.StatusColecaoSerie;
import br.com.hqhub.entity.TipoPostagemFeed;
import br.com.hqhub.entity.VisibilidadeColecao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VideoRelacionadoFeed;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.AmizadeRepository;
import br.com.hqhub.repository.ColecaoSerieRepository;
import br.com.hqhub.repository.ComentarioFeedRepository;
import br.com.hqhub.repository.CurtidaComentarioFeedRepository;
import br.com.hqhub.repository.CurtidaPostagemFeedRepository;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.EdicaoAtividadeEstanteRepository;
import br.com.hqhub.repository.ImagemPostagemFeedRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.PostagemFeedRepository;
import br.com.hqhub.repository.ConfiguracaoColecaoRepository;
import br.com.hqhub.repository.VideoRelacionadoFeedRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class FeedSocialService {

    private final PostagemFeedRepository postagemRepository;
    private final ComentarioFeedRepository comentarioRepository;
    private final CurtidaComentarioFeedRepository curtidaComentarioRepository;
    private final CurtidaPostagemFeedRepository curtidaRepository;
    private final ImagemPostagemFeedRepository imagemRepository;
    private final VideoRelacionadoFeedRepository videoRelacionadoRepository;
    private final AmizadeRepository amizadeRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final ColecaoSerieRepository colecaoSerieRepository;
    private final EdicaoRepository edicaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final UsuarioMapper usuarioMapper;
    private final UrlPublicaService urlPublicaService;
    private final EdicaoAtividadeEstanteRepository edicaoAtividadeRepository;
    private final ConfiguracaoColecaoRepository configuracaoColecaoRepository;

    public FeedSocialService(
            PostagemFeedRepository postagemRepository,
            ComentarioFeedRepository comentarioRepository,
            CurtidaComentarioFeedRepository curtidaComentarioRepository,
            CurtidaPostagemFeedRepository curtidaRepository,
            ImagemPostagemFeedRepository imagemRepository,
            VideoRelacionadoFeedRepository videoRelacionadoRepository,
            AmizadeRepository amizadeRepository,
            ItemColecaoRepository itemColecaoRepository,
            ColecaoSerieRepository colecaoSerieRepository,
            EdicaoRepository edicaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            UsuarioMapper usuarioMapper,
            UrlPublicaService urlPublicaService,
            EdicaoAtividadeEstanteRepository edicaoAtividadeRepository,
            ConfiguracaoColecaoRepository configuracaoColecaoRepository) {
        this.postagemRepository = postagemRepository;
        this.comentarioRepository = comentarioRepository;
        this.curtidaComentarioRepository = curtidaComentarioRepository;
        this.curtidaRepository = curtidaRepository;
        this.imagemRepository = imagemRepository;
        this.videoRelacionadoRepository = videoRelacionadoRepository;
        this.amizadeRepository = amizadeRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.colecaoSerieRepository = colecaoSerieRepository;
        this.edicaoRepository = edicaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.usuarioMapper = usuarioMapper;
        this.urlPublicaService = urlPublicaService;
        this.edicaoAtividadeRepository = edicaoAtividadeRepository;
        this.configuracaoColecaoRepository = configuracaoColecaoRepository;
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
    public List<PostagemFeedRespostaDTO> listarPostagensPorUsuario(Long usuarioId, int pagina, int tamanho) {
        Usuario usuarioAutenticado = usuarioAutenticadoService.obterUsuario();
        int paginaTratada = Math.max(pagina, 0);
        int tamanhoTratado = Math.min(Math.max(tamanho, 1), 50);
        return postagemRepository.listarPorUsuario(usuarioId, usuarioAutenticado.getId(), paginaTratada, tamanhoTratado)
                .stream()
                .map(postagem -> paraResposta(postagem, usuarioAutenticado.getId()))
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
        salvarVideosRelacionados(postagem, dto.relatedVideos());
        salvarCanalParceiro(postagem, dto.partnerChannel());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO atualizarPostagem(Long postagemId, AtualizacaoPostagemFeedDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemEditavel(postagemId, usuario);
        postagem.setConteudo(dto.conteudo().trim());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO alternarFixacao(Long postagemId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemEditavel(postagemId, usuario);
        postagem.setFixada(!postagem.isFixada());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO atualizarVideosRelacionados(
            Long postagemId,
            AtualizacaoVideosRelacionadosDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemEditavel(postagemId, usuario);

        videoRelacionadoRepository.removerPorPostagem(postagemId);
        salvarVideosRelacionados(postagem, dto.relatedVideos());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO atualizarCanalParceiro(
            Long postagemId,
            AtualizacaoCanalParceiroDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemEditavel(postagemId, usuario);
        salvarCanalParceiro(postagem, dto.partnerChannel());
        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemFeedRespostaDTO removerCanalParceiro(Long postagemId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemEditavel(postagemId, usuario);
        postagem.setCanalParceiroNome(null);
        postagem.setCanalParceiroUrl(null);
        postagem.setCanalParceiroThumbnail(null);
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

    @Transactional
    public PostagemFeedRespostaDTO alternarCurtidaComentario(Long postagemId, Long comentarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemVisivel(postagemId, usuario);
        ComentarioFeed comentario = buscarComentarioDaPostagem(postagem, comentarioId);

        curtidaComentarioRepository.buscarPorComentarioEUsuario(comentario.getId(), usuario.getId())
                .ifPresentOrElse(
                        curtidaComentarioRepository::delete,
                        () -> {
                            CurtidaComentarioFeed curtida = new CurtidaComentarioFeed();
                            curtida.setComentario(comentario);
                            curtida.setUsuario(usuario);
                            curtidaComentarioRepository.persist(curtida);
                        });

        return paraResposta(postagem, usuario.getId());
    }

    @Transactional
    public PostagemPublicaDTO obterPostagemPublica(Long postagemId) {
        PostagemFeed postagem = postagemRepository.findByIdOptional(postagemId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Postagem nao encontrada."));
        if (postagem.getTipoPostagem() == TipoPostagemFeed.ATIVIDADE_ESTANTE
                && visibilidadeAtividades(postagem.getUsuario().getId()) != VisibilidadeColecao.PUBLICA) {
            throw new RecursoNaoEncontradoException("Postagem nao encontrada.");
        }

        List<ImagemFeedDTO> imagens = imagemRepository.listarPorPostagem(postagem.getId())
                .stream()
                .map(this::paraImagemResposta)
                .toList();
        List<ComentarioFeed> comentariosEntidades = comentarioRepository.listarPorPostagem(postagem.getId());
        Map<Long, Long> totaisCurtidasComentarios = curtidaComentarioRepository.contarPorComentarios(
                comentariosEntidades.stream().map(ComentarioFeed::getId).toList());
        List<PostagemPublicaDTO.Comentario> comentarios = comentariosEntidades
                .stream()
                .map(comentario -> new PostagemPublicaDTO.Comentario(
                        comentario.getId(),
                        paraAutorPublico(comentario.getUsuario()),
                        comentario.getTexto(),
                        comentario.getDataCriacao(),
                        totaisCurtidasComentarios.getOrDefault(comentario.getId(), 0L)))
                .toList();

        return new PostagemPublicaDTO(
                postagem.getId(),
                paraAutorPublico(postagem.getUsuario()),
                postagem.getConteudo(),
                primeiraImagem(postagem, imagens),
                imagens,
                paraColecaoFeed(postagem.getItemColecao()),
                paraCatalogoFeed(postagem.getSerieCatalogo(), postagem.getUrlImagem()),
                listarVideosRelacionados(postagem.getId()),
                paraCanalParceiro(postagem),
                curtidaRepository.contarPorPostagem(postagem.getId()),
                comentarios,
                postagem.getDataCriacao(),
                postagem.getDataAtualizacao());
    }

    @Transactional
    public void removerPostagem(Long postagemId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = postagemRepository.findByIdOptional(postagemId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Postagem nao encontrada."));

        if (!postagem.getUsuario().getId().equals(usuario.getId())) {
            throw new RegraNegocioException("Voce so pode apagar postagens criadas por voce.");
        }

        comentarioRepository.delete("postagem.id", postagem.getId());
        curtidaRepository.delete("postagem.id", postagem.getId());
        imagemRepository.delete("postagem.id", postagem.getId());
        videoRelacionadoRepository.removerPorPostagem(postagem.getId());
        postagemRepository.delete(postagem);
    }

    @Transactional
    public PostagemFeedRespostaDTO removerComentario(Long postagemId, Long comentarioId) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        PostagemFeed postagem = buscarPostagemVisivel(postagemId, usuario);
        ComentarioFeed comentario = comentarioRepository.findByIdOptional(comentarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Comentario nao encontrado."));

        if (!comentario.getPostagem().getId().equals(postagem.getId())) {
            throw new RecursoNaoEncontradoException("Comentario nao encontrado.");
        }
        if (!comentario.getUsuario().getId().equals(usuario.getId())) {
            throw new RegraNegocioException("Voce so pode apagar comentarios criados por voce.");
        }

        comentarioRepository.delete(comentario);
        return paraResposta(postagem, usuario.getId());
    }

    private ComentarioFeed buscarComentarioDaPostagem(PostagemFeed postagem, Long comentarioId) {
        ComentarioFeed comentario = comentarioRepository.findByIdOptional(comentarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Comentario nao encontrado."));
        if (!comentario.getPostagem().getId().equals(postagem.getId())) {
            throw new RecursoNaoEncontradoException("Comentario nao encontrado.");
        }
        return comentario;
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
        if (postagem.isSistema()) {
            return true;
        }
        Long autorId = postagem.getUsuario().getId();
        if (autorId.equals(usuario.getId())) {
            return true;
        }
        if (postagem.getTipoPostagem() != TipoPostagemFeed.ATIVIDADE_ESTANTE) {
            return amizadeRepository.saoAmigos(usuario.getId(), autorId);
        }
        VisibilidadeColecao visibilidade = visibilidadeAtividades(autorId);
        return visibilidade == VisibilidadeColecao.PUBLICA
                || (visibilidade == VisibilidadeColecao.AMIGOS
                        && amizadeRepository.saoAmigos(usuario.getId(), autorId));
    }

    private PostagemFeedRespostaDTO paraResposta(PostagemFeed postagem, Long usuarioId) {
        List<ComentarioFeed> comentariosEntidades = comentarioRepository.listarPorPostagem(postagem.getId());
        List<Long> comentarioIds = comentariosEntidades.stream().map(ComentarioFeed::getId).toList();
        Map<Long, Long> totaisCurtidasComentarios = curtidaComentarioRepository.contarPorComentarios(comentarioIds);
        Set<Long> comentariosCurtidos = curtidaComentarioRepository.listarComentariosCurtidosPorUsuario(
                comentarioIds, usuarioId);
        List<ComentarioFeedRespostaDTO> comentarios = comentariosEntidades
                .stream()
                .map(comentario -> new ComentarioFeedRespostaDTO(
                        comentario.getId(),
                        usuarioMapper.paraResposta(comentario.getUsuario()),
                        comentario.getTexto(),
                        comentario.getDataCriacao(),
                        totaisCurtidasComentarios.getOrDefault(comentario.getId(), 0L),
                        comentariosCurtidos.contains(comentario.getId())))
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
                paraAtividadeEstante(postagem),
                imagens,
                paraColecaoFeed(postagem.getItemColecao()),
                paraCatalogoFeed(postagem.getSerieCatalogo(), postagem.getUrlImagem()),
                listarVideosRelacionados(postagem.getId()),
                paraCanalParceiro(postagem),
                postagem.isFixada(),
                curtidaRepository.contarPorPostagem(postagem.getId()),
                curtidaRepository.existePorPostagemEUsuario(postagem.getId(), usuarioId),
                comentarios,
                postagem.getDataCriacao(),
                postagem.getDataAtualizacao());
    }

    private AtividadeEstanteDTO paraAtividadeEstante(PostagemFeed postagem) {
        if (postagem.getTipoPostagem() != TipoPostagemFeed.ATIVIDADE_ESTANTE) {
            return null;
        }
        List<EdicaoAtividadeEstante> itens = edicaoAtividadeRepository.listarPorPostagem(postagem.getId());
        List<EdicaoAtividadeEstanteDTO> edicoes = itens.stream()
                .limit(3)
                .map(item -> new EdicaoAtividadeEstanteDTO(
                        item.getEdicao() == null ? null : item.getEdicao().getId(),
                        item.getTituloSnapshot(),
                        capaAtividade(item)))
                .toList();
        return new AtividadeEstanteDTO(postagem.getTipoAtividade(), itens.size(), edicoes);
    }

    private String capaAtividade(EdicaoAtividadeEstante item) {
        if (item.getEdicao() != null) {
            return edicaoRepository.capaPublicaPorEdicao(item.getEdicao().getId())
                    .map(urlPublicaService::normalizarApiUrl)
                    .orElseGet(() -> urlPublicaService.normalizarApiUrl(item.getUrlCapaSnapshot()));
        }
        return urlPublicaService.normalizarApiUrl(item.getUrlCapaSnapshot());
    }

    private VisibilidadeColecao visibilidadeAtividades(Long usuarioId) {
        return configuracaoColecaoRepository.buscarPorUsuario(usuarioId)
                .map(configuracao -> configuracao.getVisibilidadeAtividades())
                .orElse(VisibilidadeColecao.AMIGOS);
    }

    private ColecaoFeedDTO paraColecaoFeed(ItemColecao item) {
        if (item == null) {
            return null;
        }

        Edicao edicao = item.getEdicao();
        Serie serie = edicao.getSerie();
        Long usuarioId = item.getUsuario().getId();
        long quantidadeEdicoes = itemColecaoRepository.contarPorUsuarioESerie(usuarioId, serie.getId());
        boolean concluida = colecaoSerieRepository.buscarPorUsuarioESerie(usuarioId, serie.getId())
                .map(colecao -> colecao.getStatus() == StatusColecaoSerie.CONCLUIDA)
                .orElse(false);

        return new ColecaoFeedDTO(
                item.getId(),
                serie.getId(),
                serie.getTitulo(),
                serie.getEditora().getNome(),
                Math.toIntExact(quantidadeEdicoes),
                edicaoRepository.capaPublicaPorEdicao(edicao.getId())
                        .map(urlPublicaService::normalizarApiUrl)
                        .orElse(null),
                concluida);
    }

    private CatalogoFeedDTO paraCatalogoFeed(Serie serie, String urlCapaImportada) {
        if (serie == null) {
            return null;
        }

        long quantidadeEdicoes = edicaoRepository.contarPorSerie(serie.getId());
        boolean capaImportadaInvalida = urlCapaImportada == null
                || urlCapaImportada.isBlank()
                || urlCapaImportada.toLowerCase(Locale.ROOT).contains("guiadosquadrinhos.com");
        String urlCapa = capaImportadaInvalida
                ? edicaoRepository.primeiraCapaPorSerie(serie.getId())
                        .map(urlPublicaService::normalizarApiUrl)
                        .orElse(null)
                : urlPublicaService.normalizarApiUrl(urlCapaImportada);

        return new CatalogoFeedDTO(
                serie.getId(),
                serie.getTitulo(),
                serie.getEditora().getNome(),
                Math.toIntExact(quantidadeEdicoes),
                urlCapa);
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
            urlPublicaService.normalizarApiUrl(imagem.getUrlImagem()),
            urlPublicaService.normalizarApiUrl(imagem.getUrlThumbnail()),
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
        return urlPublicaService.normalizarApiUrl(postagem.getUrlImagem());
    }

    private void salvarVideosRelacionados(PostagemFeed postagem, List<CadastroVideoRelacionadoDTO> videos) {
        if (videos == null || videos.isEmpty()) {
            return;
        }
        if (videos.size() > 3) {
            throw new RegraNegocioException("A postagem pode ter no máximo 3 vídeos relacionados.");
        }

        Set<String> idsYoutube = new HashSet<>();
        for (int ordem = 0; ordem < videos.size(); ordem++) {
            CadastroVideoRelacionadoDTO dto = videos.get(ordem);
            String url = dto.url().trim();
            String videoId = extrairIdYoutube(url);
            if (videoId == null) {
                throw new RegraNegocioException("Informe uma URL válida de vídeo do YouTube.");
            }
            if (!idsYoutube.add(videoId)) {
                throw new RegraNegocioException("O mesmo vídeo foi informado mais de uma vez.");
            }

            VideoRelacionadoFeed video = new VideoRelacionadoFeed();
            video.setPostagem(postagem);
            video.setTitulo(dto.title().trim());
            video.setUrl(url);
            video.setThumbnail(thumbnailYoutube(dto.thumbnail(), videoId));
            video.setNomeCanal(textoOuNull(dto.channelName()));
            video.setDuracaoSegundos(dto.durationSeconds());
            video.setVisualizacoes(dto.viewCount());
            video.setOrdem(ordem);
            videoRelacionadoRepository.persist(video);
        }
    }

    private List<VideoRelacionadoDTO> listarVideosRelacionados(Long postagemId) {
        return videoRelacionadoRepository.listarPorPostagem(postagemId)
                .stream()
                .map(video -> new VideoRelacionadoDTO(
                        video.getId(),
                        video.getTitulo(),
                        video.getUrl(),
                        video.getThumbnail(),
                        video.getNomeCanal(),
                        video.getDuracaoSegundos(),
                        video.getVisualizacoes()))
                .toList();
    }

    private void salvarCanalParceiro(PostagemFeed postagem, CanalParceiroDTO canal) {
        if (canal == null) {
            return;
        }
        String url = canal.url().trim();
        validarUrlHttp(url, "Link do canal parceiro inválido.");
        String thumbnail = textoOuNull(canal.thumbnail());
        if (thumbnail != null) {
            validarUrlHttp(thumbnail, "Imagem do canal parceiro inválida.");
        }
        postagem.setCanalParceiroNome(textoOuNull(canal.name()) == null ? "Canal parceiro" : canal.name().trim());
        postagem.setCanalParceiroUrl(url);
        postagem.setCanalParceiroThumbnail(thumbnail);
    }

    private CanalParceiroDTO paraCanalParceiro(PostagemFeed postagem) {
        if (postagem.getCanalParceiroUrl() == null || postagem.getCanalParceiroUrl().isBlank()) {
            return null;
        }
        return new CanalParceiroDTO(
                postagem.getCanalParceiroNome(),
                postagem.getCanalParceiroUrl(),
                postagem.getCanalParceiroThumbnail());
    }

    private PostagemFeed buscarPostagemEditavel(Long postagemId, Usuario usuario) {
        PostagemFeed postagem = postagemRepository.findByIdOptional(postagemId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Postagem nao encontrada."));
        boolean administrador = usuario.getPerfil() == PerfilUsuario.ADMINISTRADOR;
        if (!postagem.getUsuario().getId().equals(usuario.getId()) && !administrador) {
            throw new RegraNegocioException("Você não pode alterar os conteúdos relacionados desta postagem.");
        }
        if (postagem.getTipoPostagem() == TipoPostagemFeed.ATIVIDADE_ESTANTE) {
            throw new RegraNegocioException("Atividades automáticas da estante não podem ser editadas.");
        }
        return postagem;
    }

    private String thumbnailYoutube(String thumbnail, String videoId) {
        String informada = textoOuNull(thumbnail);
        if (informada != null) {
            validarUrlHttp(informada, "Thumbnail inválida.");
            return informada;
        }
        return "https://i.ytimg.com/vi/" + videoId + "/hqdefault.jpg";
    }

    private String extrairIdYoutube(String url) {
        try {
            URI uri = URI.create(url);
            validarUrlHttp(url, "URL inválida.");
            String host = uri.getHost().toLowerCase(Locale.ROOT);
            String candidato = null;

            if (host.equals("youtu.be")) {
                candidato = primeiroTrechoCaminho(uri.getPath());
            } else if (host.equals("youtube.com") || host.endsWith(".youtube.com")
                    || host.equals("youtube-nocookie.com") || host.endsWith(".youtube-nocookie.com")) {
                String caminho = uri.getPath() == null ? "" : uri.getPath();
                if (caminho.equals("/watch")) {
                    candidato = parametroConsulta(uri.getRawQuery(), "v");
                } else if (caminho.startsWith("/shorts/") || caminho.startsWith("/embed/")
                        || caminho.startsWith("/live/")) {
                    candidato = primeiroTrechoCaminho(caminho.substring(caminho.indexOf('/', 1)));
                }
            }
            return candidato != null && candidato.matches("[A-Za-z0-9_-]{6,20}") ? candidato : null;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private void validarUrlHttp(String url, String mensagem) {
        URI uri;
        try {
            uri = URI.create(url);
        } catch (IllegalArgumentException e) {
            throw new RegraNegocioException(mensagem);
        }
        String esquema = uri.getScheme();
        if (uri.getHost() == null || esquema == null
                || !(esquema.equalsIgnoreCase("https") || esquema.equalsIgnoreCase("http"))) {
            throw new RegraNegocioException(mensagem);
        }
    }

    private String primeiroTrechoCaminho(String caminho) {
        if (caminho == null) {
            return null;
        }
        return java.util.Arrays.stream(caminho.split("/"))
                .filter(trecho -> !trecho.isBlank())
                .findFirst()
                .orElse(null);
    }

    private String parametroConsulta(String consulta, String nome) {
        if (consulta == null) {
            return null;
        }
        for (String parametro : consulta.split("&")) {
            String[] partes = parametro.split("=", 2);
            if (partes.length == 2 && partes[0].equals(nome)) {
                return URLDecoder.decode(partes[1], StandardCharsets.UTF_8);
            }
        }
        return null;
    }

    private PostagemPublicaDTO.Autor paraAutorPublico(Usuario usuario) {
        return new PostagemPublicaDTO.Autor(
                usuario.getId(),
                usuario.getNome(),
                usuario.getBio(),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilUrl()),
                urlPublicaService.normalizarApiUrl(usuario.getFotoPerfilThumbnailUrl()));
    }
}
