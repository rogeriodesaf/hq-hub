package br.com.hqhub.dto;

import java.util.List;

public record EstanteEditoraDTO(
        Long editoraId,
        String nome,
        List<EstanteSerieDTO> series) {
}
