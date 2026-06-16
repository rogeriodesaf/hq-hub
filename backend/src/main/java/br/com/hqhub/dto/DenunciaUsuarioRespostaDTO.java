package br.com.hqhub.dto;

import java.time.LocalDateTime;

import br.com.hqhub.entity.StatusDenuncia;

public record DenunciaUsuarioRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuarioDenunciado,
        String motivo,
        String descricao,
        StatusDenuncia status,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
