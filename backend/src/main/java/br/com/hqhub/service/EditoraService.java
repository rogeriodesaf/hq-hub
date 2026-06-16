package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.AtualizacaoEditoraDTO;
import br.com.hqhub.dto.CadastroEditoraDTO;
import br.com.hqhub.dto.EditoraRespostaDTO;
import br.com.hqhub.entity.Editora;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.EditoraMapper;
import br.com.hqhub.repository.EditoraRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class EditoraService {

    private final EditoraRepository editoraRepository;
    private final EditoraMapper editoraMapper;

    public EditoraService(EditoraRepository editoraRepository, EditoraMapper editoraMapper) {
        this.editoraRepository = editoraRepository;
        this.editoraMapper = editoraMapper;
    }

    @Transactional
    public EditoraRespostaDTO cadastrar(CadastroEditoraDTO dto) {
        if (editoraRepository.existePorNome(dto.nome())) {
            throw new RegraNegocioException("Já existe uma editora cadastrada com este nome.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (editoraRepository.existePorOrigemExterna(dto.fonteExterna(), dto.idExterno())) {
            throw new RegraNegocioException("Já existe uma editora cadastrada com esta origem externa.");
        }

        Editora editora = editoraMapper.paraEntidade(dto);
        editoraRepository.persist(editora);

        return editoraMapper.paraResposta(editora);
    }

    @Transactional
    public EditoraRespostaDTO atualizar(Long id, AtualizacaoEditoraDTO dto) {
        Editora editora = buscarEntidadePorId(id);

        if (editoraRepository.existePorNomeEmOutraEditora(dto.nome(), id)) {
            throw new RegraNegocioException("Já existe uma editora cadastrada com este nome.");
        }

        validarOrigemExterna(dto.fonteExterna(), dto.idExterno());

        if (editoraRepository.existePorOrigemExternaEmOutraEditora(dto.fonteExterna(), dto.idExterno(), id)) {
            throw new RegraNegocioException("Já existe uma editora cadastrada com esta origem externa.");
        }

        editoraMapper.atualizarEntidade(editora, dto);

        return editoraMapper.paraResposta(editora);
    }

    public EditoraRespostaDTO buscarPorId(Long id) {
        return editoraMapper.paraResposta(buscarEntidadePorId(id));
    }

    public List<EditoraRespostaDTO> listarTodos() {
        return editoraRepository.list("nome")
                .stream()
                .map(editoraMapper::paraResposta)
                .toList();
    }

    @Transactional
    public void remover(Long id) {
        Editora editora = buscarEntidadePorId(id);
        editoraRepository.delete(editora);
    }

    private Editora buscarEntidadePorId(Long id) {
        return editoraRepository.findByIdOptional(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Editora não encontrada."));
    }

    private void validarOrigemExterna(String fonteExterna, String idExterno) {
        if ((fonteExterna == null) != (idExterno == null)) {
            throw new RegraNegocioException("Fonte externa e id externo devem ser informados juntos.");
        }
    }
}
