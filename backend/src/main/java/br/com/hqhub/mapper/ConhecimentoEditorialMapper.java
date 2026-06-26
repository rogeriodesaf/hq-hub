package br.com.hqhub.mapper;

import br.com.hqhub.dto.CadastroConhecimentoEditorialDTO;
import br.com.hqhub.dto.ConhecimentoEditorialDTO;
import br.com.hqhub.entity.ConhecimentoEditorial;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConhecimentoEditorialMapper {

    public ConhecimentoEditorialDTO paraDTO(ConhecimentoEditorial entity) {
        if (entity == null) {
            return null;
        }

        return new ConhecimentoEditorialDTO(
                entity.id,
                entity.tipo,
                entity.titulo,
                entity.conteudo,
                entity.fonte,
                entity.urlFonte,
                entity.confianca,
                entity.dataCriacao,
                entity.dataAtualizacao,
                entity.origemDados,
                entity.tags,
                entity.relacionadas);
    }

    public ConhecimentoEditorial paraEntity(CadastroConhecimentoEditorialDTO dto) {
        if (dto == null) {
            return null;
        }

        ConhecimentoEditorial entity = new ConhecimentoEditorial(
                dto.tipo(),
                dto.titulo(),
                dto.conteudo(),
                dto.fonte(),
                dto.urlFonte(),
                dto.origemDados());

        entity.confianca = dto.confianca() != null ? dto.confianca() : "COMUNITARIA";
        entity.tags = dto.tags();

        return entity;
    }
}
