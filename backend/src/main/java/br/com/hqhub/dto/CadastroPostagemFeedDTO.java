package br.com.hqhub.dto;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CadastroPostagemFeedDTO(
        @NotBlank(message = "Escreva algo para publicar.")
        @Size(max = 2000, message = "A postagem deve ter no maximo 2000 caracteres.")
        String conteudo,

        @Size(max = 1000, message = "A URL da imagem deve ter no maximo 1000 caracteres.")
        String urlImagem,

        @Size(max = 3, message = "A postagem pode ter no maximo 3 imagens.")
        List<ImagemFeedDTO> imagens) {
}
