package br.com.hqhub.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record ColetaGuiaRespostaDTO(
        UUID id,
        String status,
        int totalPaginas,
        int paginasProcessadas,
        LocalDateTime proximaExecucao,
        long segundosAteProximaExecucao,
        String mensagem,
        List<String> avisos,
        ImportacaoCatalogoDTO resultado) {
}
