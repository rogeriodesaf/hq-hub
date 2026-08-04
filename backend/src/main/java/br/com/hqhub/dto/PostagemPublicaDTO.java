package br.com.hqhub.dto;

import java.time.LocalDateTime;
import java.util.List;

public record PostagemPublicaDTO(
        Long id,
        Autor autor,
        String conteudo,
        String urlImagem,
        List<ImagemFeedDTO> imagens,
        ColecaoFeedDTO colecaoDestaque,
        CatalogoFeedDTO catalogoDestaque,
        List<VideoRelacionadoDTO> relatedVideos,
        CanalParceiroDTO partnerChannel,
        long totalCurtidas,
        List<Comentario> comentarios,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {

    public record Autor(
            Long id,
            String nome,
            String bio,
            String fotoPerfilUrl,
            String fotoPerfilThumbnailUrl) {
    }

    public record Comentario(
            Long id,
            Autor autor,
            String texto,
            LocalDateTime dataCriacao,
            long totalCurtidas) {
    }
}
