package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import br.com.hqhub.dto.AtualizacaoItemColecaoDTO;
import br.com.hqhub.dto.CadastroItemColecaoDTO;
import br.com.hqhub.dto.ItemColecaoRespostaDTO;
import br.com.hqhub.entity.Edicao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ItemColecaoMapper;
import br.com.hqhub.repository.EdicaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ItemColecaoService {

    private final ItemColecaoRepository itemColecaoRepository;
    private final EdicaoRepository edicaoRepository;
    private final ItemColecaoMapper itemColecaoMapper;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final EntityManager entityManager;

    public ItemColecaoService(
            ItemColecaoRepository itemColecaoRepository,
            EdicaoRepository edicaoRepository,
            ItemColecaoMapper itemColecaoMapper,
            UsuarioAutenticadoService usuarioAutenticadoService,
            EntityManager entityManager) {
        this.itemColecaoRepository = itemColecaoRepository;
        this.edicaoRepository = edicaoRepository;
        this.itemColecaoMapper = itemColecaoMapper;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.entityManager = entityManager;
    }

    @Transactional
    public ItemColecaoRespostaDTO cadastrar(CadastroItemColecaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        Edicao edicao = buscarEdicaoPorId(dto.edicaoId());

        if (itemColecaoRepository.existePorUsuarioEEdicao(usuario.getId(), dto.edicaoId())) {
            throw new RegraNegocioException("Esta edição já está na sua coleção.");
        }

        ItemColecao item = itemColecaoMapper.paraEntidade(dto, usuario, edicao);
        itemColecaoRepository.persist(item);

        return itemColecaoMapper.paraResposta(item);
    }

    @Transactional
    public ItemColecaoRespostaDTO atualizar(Long id, AtualizacaoItemColecaoDTO dto) {
        ItemColecao item = buscarItemDoUsuarioPorId(id);
        itemColecaoMapper.atualizarEntidade(item, dto);

        return itemColecaoMapper.paraResposta(item);
    }

    @Transactional
    public ItemColecaoRespostaDTO buscarPorId(Long id) {
        return itemColecaoMapper.paraResposta(buscarItemDoUsuarioPorId(id));
    }

    @Transactional
    public List<ItemColecaoRespostaDTO> listarTodos() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.list("usuario.id", usuario.getId())
                .stream()
                .sorted(Comparator.comparing((ItemColecao item) -> item.getEdicao().getSerie().getTitulo())
                        .thenComparing(item -> item.getEdicao().getNumero()))
                .map(itemColecaoMapper::paraResposta)
                .toList();
    }

    @Transactional
    public Optional<ItemColecaoRespostaDTO> buscarPorOrigemExterna(String fonteExterna, String idExterno) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.buscarPorUsuarioEOrigemExterna(usuario.getId(), fonteExterna, idExterno)
                .map(itemColecaoMapper::paraResposta);
    }

    @Transactional
    public void remover(Long id) {
        ItemColecao item = buscarItemDoUsuarioPorId(id);
        removerDependenciasDoItem(item.getId());
        itemColecaoRepository.delete(item);
    }

    private void removerDependenciasDoItem(Long itemColecaoId) {
        entityManager.createNativeQuery("""
                delete from denuncias_anuncios denuncia
                 using anuncios anuncio
                 where denuncia.anuncio_id = anuncio.id
                   and anuncio.item_colecao_id = :itemColecaoId
                """)
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();

        entityManager.createNativeQuery("""
                delete from fotos_anuncios foto
                 using anuncios anuncio
                 where foto.anuncio_id = anuncio.id
                   and anuncio.item_colecao_id = :itemColecaoId
                """)
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();

        entityManager.createNativeQuery("delete from anuncios where item_colecao_id = :itemColecaoId")
                .setParameter("itemColecaoId", itemColecaoId)
                .executeUpdate();
    }

    private ItemColecao buscarItemDoUsuarioPorId(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return itemColecaoRepository.find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Item da coleção não encontrado."));
    }

    private Edicao buscarEdicaoPorId(Long id) {
        return edicaoRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Edição não encontrada."));
    }
}
