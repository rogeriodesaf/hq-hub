package br.com.hqhub.service;

import java.util.List;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hqhub.dto.CadastroConversaAssistenteDTO;
import br.com.hqhub.dto.ConversaAssistenteDetalheDTO;
import br.com.hqhub.dto.ConversaAssistenteRespostaDTO;
import br.com.hqhub.dto.EnvioMensagemAssistenteDTO;
import br.com.hqhub.dto.MensagemAssistenteRespostaDTO;
import br.com.hqhub.dto.RespostaAssistenteDTO;
import br.com.hqhub.dto.RespostaConversaAssistenteDTO;
import br.com.hqhub.entity.ConversaAssistente;
import br.com.hqhub.entity.MensagemAssistente;
import br.com.hqhub.entity.RemetenteMensagemAssistente;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.AssistenteMapper;
import br.com.hqhub.repository.ConversaAssistenteRepository;
import br.com.hqhub.repository.MensagemAssistenteRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ConversaAssistenteService {

    private static final String TITULO_PADRAO = "Nova conversa";
    private static final int TAMANHO_MAXIMO_TITULO = 120;

    private final ConversaAssistenteRepository conversaAssistenteRepository;
    private final MensagemAssistenteRepository mensagemAssistenteRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final AssistenteService assistenteService;
    private final AssistenteMapper assistenteMapper;
    private final ObjectMapper objectMapper;

    public ConversaAssistenteService(
            ConversaAssistenteRepository conversaAssistenteRepository,
            MensagemAssistenteRepository mensagemAssistenteRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            AssistenteService assistenteService,
            AssistenteMapper assistenteMapper,
            ObjectMapper objectMapper) {
        this.conversaAssistenteRepository = conversaAssistenteRepository;
        this.mensagemAssistenteRepository = mensagemAssistenteRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.assistenteService = assistenteService;
        this.assistenteMapper = assistenteMapper;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public ConversaAssistenteRespostaDTO criar(CadastroConversaAssistenteDTO dto) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();
        String titulo = dto.titulo() == null || dto.titulo().isBlank()
                ? TITULO_PADRAO
                : dto.titulo().trim();

        ConversaAssistente conversa = assistenteMapper.paraConversa(titulo, usuario);
        conversaAssistenteRepository.persist(conversa);

        return assistenteMapper.paraResposta(conversa);
    }

    @Transactional
    public List<ConversaAssistenteRespostaDTO> listar() {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return conversaAssistenteRepository.listarPorUsuario(usuario.getId())
                .stream()
                .map(assistenteMapper::paraResposta)
                .toList();
    }

    @Transactional
    public ConversaAssistenteDetalheDTO buscarPorId(Long id) {
        ConversaAssistente conversa = buscarConversaDoUsuario(id);
        List<MensagemAssistenteRespostaDTO> mensagens = mensagemAssistenteRepository.listarPorConversa(conversa.getId())
                .stream()
                .map(assistenteMapper::paraResposta)
                .toList();

        return new ConversaAssistenteDetalheDTO(assistenteMapper.paraResposta(conversa), mensagens);
    }

    @Transactional
    public RespostaConversaAssistenteDTO enviarMensagem(Long conversaId, EnvioMensagemAssistenteDTO dto) {
        ConversaAssistente conversa = buscarConversaDoUsuario(conversaId);

        if (TITULO_PADRAO.equals(conversa.getTitulo())) {
            conversa.setTitulo(gerarTitulo(dto.pergunta()));
        }

        MensagemAssistente mensagemUsuario = assistenteMapper.paraMensagem(
                conversa,
                RemetenteMensagemAssistente.USUARIO,
                dto.pergunta(),
                null,
                null);
        mensagemAssistenteRepository.persist(mensagemUsuario);

        RespostaAssistenteDTO resposta = assistenteService.responder(dto.pergunta());
        MensagemAssistente mensagemAssistente = assistenteMapper.paraMensagem(
                conversa,
                RemetenteMensagemAssistente.ASSISTENTE,
                resposta.resposta(),
                resposta.origem(),
                serializarDados(resposta.dados()));
        mensagemAssistenteRepository.persist(mensagemAssistente);

        return new RespostaConversaAssistenteDTO(
                assistenteMapper.paraResposta(mensagemUsuario),
                assistenteMapper.paraResposta(mensagemAssistente));
    }

    private ConversaAssistente buscarConversaDoUsuario(Long id) {
        Usuario usuario = usuarioAutenticadoService.obterUsuario();

        return conversaAssistenteRepository.find("id = ?1 and usuario.id = ?2", id, usuario.getId())
                .firstResultOptional()
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conversa do assistente não encontrada."));
    }

    private String serializarDados(Object dados) {
        if (dados == null) {
            return null;
        }

        try {
            return objectMapper.writeValueAsString(dados);
        } catch (JsonProcessingException e) {
            throw new RegraNegocioException("Não foi possível registrar os dados da resposta do assistente.");
        }
    }

    private String gerarTitulo(String pergunta) {
        String titulo = pergunta.trim().replaceAll("\\s+", " ");
        return titulo.length() <= TAMANHO_MAXIMO_TITULO
                ? titulo
                : titulo.substring(0, TAMANHO_MAXIMO_TITULO);
    }
}
