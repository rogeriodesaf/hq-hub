package br.com.hqhub.service;

import java.util.Comparator;
import java.util.List;

import br.com.hqhub.dto.AtualizacaoConfiguracaoColecaoDTO;
import br.com.hqhub.dto.ColecaoCompartilhadaRespostaDTO;
import br.com.hqhub.dto.ConfiguracaoColecaoRespostaDTO;
import br.com.hqhub.dto.ItemColecaoRespostaDTO;
import br.com.hqhub.entity.ConfiguracaoColecao;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.entity.VisibilidadeColecao;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.ConfiguracaoColecaoMapper;
import br.com.hqhub.mapper.ItemColecaoMapper;
import br.com.hqhub.mapper.UsuarioMapper;
import br.com.hqhub.repository.ConfiguracaoColecaoRepository;
import br.com.hqhub.repository.ItemColecaoRepository;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ConfiguracaoColecaoService {

    private final ConfiguracaoColecaoRepository configuracaoColecaoRepository;
    private final ItemColecaoRepository itemColecaoRepository;
    private final UsuarioRepository usuarioRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AmizadeService amizadeService;
    private final ConfiguracaoColecaoMapper configuracaoColecaoMapper;
    private final ItemColecaoMapper itemColecaoMapper;
    private final UsuarioMapper usuarioMapper;

    public ConfiguracaoColecaoService(
            ConfiguracaoColecaoRepository configuracaoColecaoRepository,
            ItemColecaoRepository itemColecaoRepository,
            UsuarioRepository usuarioRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AmizadeService amizadeService,
            ConfiguracaoColecaoMapper configuracaoColecaoMapper,
            ItemColecaoMapper itemColecaoMapper,
            UsuarioMapper usuarioMapper) {
        this.configuracaoColecaoRepository = configuracaoColecaoRepository;
        this.itemColecaoRepository = itemColecaoRepository;
        this.usuarioRepository = usuarioRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.amizadeService = amizadeService;
        this.configuracaoColecaoMapper = configuracaoColecaoMapper;
        this.itemColecaoMapper = itemColecaoMapper;
        this.usuarioMapper = usuarioMapper;
    }

    @Transactional
    public ConfiguracaoColecaoRespostaDTO obterMinhaConfiguracao() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        return configuracaoColecaoMapper.paraResposta(obterOuCriar(usuario));
    }

    @Transactional
    public ConfiguracaoColecaoRespostaDTO atualizar(AtualizacaoConfiguracaoColecaoDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        ConfiguracaoColecao configuracao = obterOuCriar(usuario);
        configuracao.setVisibilidadeColecao(dto.visibilidadeColecao());
        return configuracaoColecaoMapper.paraResposta(configuracao);
    }

    @Transactional
    public ColecaoCompartilhadaRespostaDTO visualizarColecao(Long usuarioId) {
        Usuario usuarioAutenticado = usuarioAutenticadoService.obterUsuario();
        Usuario donoColecao = usuarioRepository.findByIdOptional(usuarioId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado."));

        ConfiguracaoColecao configuracao = obterOuCriar(donoColecao);
        validarPermissaoVisualizacao(usuarioAutenticado, donoColecao, configuracao);

        List<ItemColecaoRespostaDTO> itens = itemColecaoRepository.list("usuario.id", donoColecao.getId())
                .stream()
                .sorted(Comparator.comparing((ItemColecao item) -> item.getEdicao().getSerie().getTitulo())
                        .thenComparing(item -> item.getEdicao().getNumero()))
                .map(itemColecaoMapper::paraResposta)
                .toList();

        return new ColecaoCompartilhadaRespostaDTO(
                usuarioMapper.paraResposta(donoColecao),
                configuracao.getVisibilidadeColecao(),
                itens);
    }

    private ConfiguracaoColecao obterOuCriar(Usuario usuario) {
        return configuracaoColecaoRepository.buscarPorUsuario(usuario.getId())
                .orElseGet(() -> {
                    ConfiguracaoColecao configuracao = configuracaoColecaoMapper.paraEntidade(usuario);
                    configuracaoColecaoRepository.persist(configuracao);
                    return configuracao;
                });
    }

    private void validarPermissaoVisualizacao(Usuario usuarioAutenticado, Usuario donoColecao, ConfiguracaoColecao configuracao) {
        if (usuarioAutenticado.getId().equals(donoColecao.getId())) {
            return;
        }

        if (configuracao.getVisibilidadeColecao() == VisibilidadeColecao.PUBLICA) {
            return;
        }

        if (configuracao.getVisibilidadeColecao() == VisibilidadeColecao.AMIGOS
                && amizadeService.saoAmigos(usuarioAutenticado.getId(), donoColecao.getId())) {
            return;
        }

        throw new RegraNegocioException("Esta coleção não está disponível para visualização.");
    }
}
