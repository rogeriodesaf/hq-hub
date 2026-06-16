package br.com.hqhub.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import br.com.hqhub.dto.AnuncioRespostaDTO;
import br.com.hqhub.dto.AtualizacaoAnuncioDTO;
import br.com.hqhub.dto.CadastroAnuncioDTO;
import br.com.hqhub.dto.CadastroFotoAnuncioDTO;
import br.com.hqhub.dto.ContatoAnuncioRespostaDTO;
import br.com.hqhub.dto.FotoAnuncioRespostaDTO;
import br.com.hqhub.entity.Anuncio;
import br.com.hqhub.entity.FotoAnuncio;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.StatusAnuncio;
import br.com.hqhub.entity.TipoAnuncio;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.AnuncioMapper;
import br.com.hqhub.repository.AnuncioRepository;
import br.com.hqhub.repository.FotoAnuncioRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class AnuncioService {

    private final AnuncioRepository anuncioRepository;
    private final FotoAnuncioRepository fotoAnuncioRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AnuncioMapper anuncioMapper;

    public AnuncioService(
            AnuncioRepository anuncioRepository,
            FotoAnuncioRepository fotoAnuncioRepository,
            ItemColecaoRepository itemColecaoRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AnuncioMapper anuncioMapper) {
        this.anuncioRepository = anuncioRepository;
        this.fotoAnuncioRepository = fotoAnuncioRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.anuncioMapper = anuncioMapper;
    }

    @Transactional
    public AnuncioRespostaDTO cadastrar(CadastroAnuncioDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ItemColecao item = buscarItemDoUsuario(dto.itemColecaoId(), usuario.getId());

        validarPreco(dto.tipoAnuncio(), dto.preco());

        if (anuncioRepository.existeAnuncioAtivoParaItem(item.getId())) {
            throw new RegraNegocioException("Este item da coleção já possui um anúncio ativo ou pausado.");
        }

        Anuncio anuncio = anuncioMapper.paraEntidade(dto, usuario, item);
        anuncioRepository.persist(anuncio);
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public AnuncioRespostaDTO atualizar(Long id, AtualizacaoAnuncioDTO dto) {
        Anuncio anuncio = buscarAnuncioDoUsuario(id);
        validarPreco(dto.tipoAnuncio(), dto.preco());
        anuncioMapper.atualizarEntidade(anuncio, dto);
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public AnuncioRespostaDTO buscarPorId(Long id) {
        Anuncio anuncio = anuncioRepository.findByIdOptional(id)
                .filter(item -> item.getStatus() != StatusAnuncio.REMOVIDO)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Anúncio não encontrado."));
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public List<AnuncioRespostaDTO> listarAtivos() {
        return anuncioRepository.listarAtivos()
                .stream()
                .map(anuncioMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<AnuncioRespostaDTO> listarMeusAnuncios() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return anuncioRepository.listarDoUsuario(usuario.getId())
                .stream()
                .map(anuncioMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<AnuncioRespostaDTO> listarAtivosPorEdicao(Long edicaoId) {
        return anuncioRepository.listarAtivosPorEdicao(edicaoId)
                .stream()
                .map(anuncioMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<AnuncioRespostaDTO> listarAtivosPorUsuario(Long usuarioId) {
        return anuncioRepository.listarAtivosPorUsuario(usuarioId)
                .stream()
                .map(anuncioMapper::paraResposta)
                .toList();
    }

    @Transactional
    public AnuncioRespostaDTO pausar(Long id) {
        Anuncio anuncio = buscarAnuncioDoUsuario(id);
        anuncio.setStatus(StatusAnuncio.PAUSADO);
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public AnuncioRespostaDTO reativar(Long id) {
        Anuncio anuncio = buscarAnuncioDoUsuario(id);
        anuncio.setStatus(StatusAnuncio.ATIVO);
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public AnuncioRespostaDTO encerrar(Long id) {
        Anuncio anuncio = buscarAnuncioDoUsuario(id);
        anuncio.setStatus(StatusAnuncio.ENCERRADO);
        return anuncioMapper.paraResposta(anuncio);
    }

    @Transactional
    public void remover(Long id) {
        Anuncio anuncio = buscarAnuncioDoUsuario(id);
        anuncio.setStatus(StatusAnuncio.REMOVIDO);
    }

    @Transactional
    public FotoAnuncioRespostaDTO adicionarFoto(Long anuncioId, CadastroFotoAnuncioDTO dto) {
        Anuncio anuncio = buscarAnuncioDoUsuario(anuncioId);
        FotoAnuncio foto = anuncioMapper.paraFoto(dto, anuncio);

        if (Boolean.TRUE.equals(foto.getPrincipal())) {
            fotoAnuncioRepository.listarPorAnuncio(anuncioId).forEach(item -> item.setPrincipal(false));
        }

        fotoAnuncioRepository.persist(foto);
        return anuncioMapper.paraResposta(foto);
    }

    @Transactional
    public List<FotoAnuncioRespostaDTO> listarFotos(Long anuncioId) {
        buscarPorId(anuncioId);
        return fotoAnuncioRepository.listarPorAnuncio(anuncioId)
                .stream()
                .map(anuncioMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void removerFoto(Long anuncioId, Long fotoId) {
        buscarAnuncioDoUsuario(anuncioId);
        FotoAnuncio foto = fotoAnuncioRepository.find("id = ?1 and anuncio.id = ?2", fotoId, anuncioId)
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Foto do anúncio não encontrada."));
        fotoAnuncioRepository.delete(foto);
    }

    @Transactional
    public ContatoAnuncioRespostaDTO gerarContato(Long id) {
        Anuncio anuncio = anuncioRepository.findByIdOptional(id)
                .filter(item -> item.getStatus() == StatusAnuncio.ATIVO)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Anúncio ativo não encontrado."));

        if (!Boolean.TRUE.equals(anuncio.getExibirWhatsapp()) || anuncio.getContatoWhatsapp() == null
                || anuncio.getContatoWhatsapp().isBlank()) {
            throw new RegraNegocioException("O anunciante não disponibilizou WhatsApp para este anúncio.");
        }

        String titulo = anuncio.getItemColecao().getEdicao().getSerie().getTitulo()
                + " nº " + anuncio.getItemColecao().getEdicao().getNumero();
        String mensagem = "Olá! Vi no HQ-HUB o anúncio da HQ " + titulo + " e tenho interesse em conversar.";
        String contatoLimpo = anuncio.getContatoWhatsapp().replaceAll("\\D", "");
        String link = "https://wa.me/" + contatoLimpo + "?text=" + URLEncoder.encode(mensagem, StandardCharsets.UTF_8);

        return new ContatoAnuncioRespostaDTO(
                anuncio.getId(),
                anuncio.getContatoWhatsapp(),
                mensagem,
                link,
                AnuncioMapper.AVISO_RESPONSABILIDADE);
    }

    private Anuncio buscarAnuncioDoUsuario(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return anuncioRepository.find("id = ?1 and anunciante.id = ?2 and status <> ?3", id, usuario.getId(), StatusAnuncio.REMOVIDO)
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Anúncio não encontrado."));
    }

    private ItemColecao buscarItemDoUsuario(Long itemColecaoId, Long usuarioId) {
        return itemColecaoRepository.find("id = ?1 and usuario.id = ?2", itemColecaoId, usuarioId)
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da coleção não encontrado."));
    }

    private void validarPreco(TipoAnuncio tipoAnuncio, Object preco) {
        if ((tipoAnuncio == TipoAnuncio.VENDA || tipoAnuncio == TipoAnuncio.VENDA_E_TROCA) && preco == null) {
            return;
        }
    }
}
