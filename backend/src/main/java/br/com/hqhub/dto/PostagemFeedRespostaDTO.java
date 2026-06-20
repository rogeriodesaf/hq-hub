package br.com.hqhub.dto;

import java.time.LocalDateTime;
import java.util.List;

public record PostagemFeedRespostaDTO(
        Long id,
        UsuarioRespostaDTO usuario,
        String conteudo,
        String urlImagem,
        List<ImagemFeedDTO> imagens,
        long totalCurtidas,
        boolean curtidaPeloUsuario,
        List<ComentarioFeedRespostaDTO> comentarios,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao) {
}
