package br.com.hqhub.dto;

public record UsuarioAutenticadoDTO(
        Long id,
        String nome,
        String email,
        String perfil,
        String bio,
        String fotoPerfilUrl,
        String fotoPerfilThumbnailUrl,
        String capaPerfilUrl,
        String token,
        String tipoToken,
        long expiraEm,
        String mensagem) {
}
