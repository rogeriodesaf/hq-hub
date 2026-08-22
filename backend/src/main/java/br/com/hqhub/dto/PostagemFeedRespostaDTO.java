package br.com.hqhub.dto;

import java.time.LocalDateTime;
import java.util.List;

public record PostagemFeedRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        String conteudo,
        String urlImagem,
        AtividadeEstanteDTO atividadeEstante,
        List<ImagemFeedDTO> imagens,
        ColecaoFeedDTO colecaoDestaque,
        CatalogoFeedDTO catalogoDestaque,
        List<VideoRelacionadoDTO> relatedVideos,
        CanalParceiroDTO partnerChannel,
        boolean fixada,
        long totalCurtidas,
        boolean curtidaPeloUsuario,
        List<ComentarioFeedRespostaDTO> comentarios,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
