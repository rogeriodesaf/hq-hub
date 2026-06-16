package br.com.hqhub.dto;

public record UsuarioAutenticadoDTO(
        Long id,
        String nome,
        String email,
        String token,
        String tipoToken,
        long expiraEm,
        String mensagem) {
}
