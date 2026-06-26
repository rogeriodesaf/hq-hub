package br.com.hqhub.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import br.com.hqhub.dto.CadastroConhecimentoEditorialDTO;
import br.com.hqhub.dto.ConhecimentoEditorialDTO;
import br.com.hqhub.dto.ResultadoBuscaConhecimentoDTO;
import br.com.hqhub.entity.ConhecimentoEditorial;
import br.com.hqhub.repository.ConhecimentoEditorialRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class ConhecimentoEditorialService {

    private final ConhecimentoEditorialRepository repository;

    public ConhecimentoEditorialService(ConhecimentoEditorialRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public ConhecimentoEditorialDTO cadastrar(CadastroConhecimentoEditorialDTO dto) {
        ConhecimentoEditorial conhecimento = new ConhecimentoEditorial(
                dto.tipo(),
                dto.titulo(),
                dto.conteudo(),
                dto.fonte(),
                dto.urlFonte(),
                dto.origemDados());

        conhecimento.confianca = dto.confianca() != null ? dto.confianca() : "COMUNITARIA";
        conhecimento.tags = dto.tags();

        repository.persist(conhecimento);
        return paraDTO(conhecimento);
    }

    public ConhecimentoEditorialDTO buscarPorId(Long id) {
        return repository.findByIdOptional(id)
                .map(this::paraDTO)
                .orElse(null);
    }

    public List<ResultadoBuscaConhecimentoDTO> buscarRelevante(String pergunta) {
        String perguntaNormalizada = pergunta.toLowerCase().trim();

        // Buscar por múltiplas estratégias
        List<ConhecimentoEditorial> resultado = repository.listAll();

        return resultado.stream()
                .map(k -> new ResultadoBuscaConhecimentoDTO(
                        k.id,
                        k.tipo,
                        k.titulo,
                        k.conteudo,
                        k.fonte,
                        k.urlFonte,
                        k.confianca,
                        calcularRelevancia(perguntaNormalizada, k)))
                .filter(r -> r.relevancia() > 0)
                .sorted((a, b) -> Double.compare(b.relevancia(), a.relevancia()))
                .limit(5)
                .collect(Collectors.toList());
    }

    public List<ResultadoBuscaConhecimentoDTO> buscarPorTipo(String tipo) {
        return repository.buscarPorTipo(tipo).stream()
                .map(k -> new ResultadoBuscaConhecimentoDTO(
                        k.id,
                        k.tipo,
                        k.titulo,
                        k.conteudo,
                        k.fonte,
                        k.urlFonte,
                        k.confianca,
                        1.0))
                .collect(Collectors.toList());
    }

    private double calcularRelevancia(String pergunta, ConhecimentoEditorial conhecimento) {
        double score = 0;

        // Correspondência no título (peso alto)
        if (conhecimento.titulo.toLowerCase().contains(pergunta)) {
            score += 10;
        }

        // Correspondência no conteúdo (peso médio)
        if (conhecimento.conteudo.toLowerCase().contains(pergunta)) {
            score += 5;
        }

        // Correspondência em tags (peso médio)
        if (conhecimento.tags != null && conhecimento.tags.toLowerCase().contains(pergunta)) {
            score += 5;
        }

        // Bônus por confiança
        switch (conhecimento.confianca) {
            case "VERIFICADA":
                score *= 1.5;
                break;
            case "OFICIAL":
                score *= 1.3;
                break;
            case "COMUNITARIA":
                score *= 0.8;
                break;
        }

        // Penalidade por origem (scraping menos confiável)
        if ("SCRAPING".equals(conhecimento.origemDados)) {
            score *= 0.9;
        }

        return score;
    }

    @Transactional
    public ConhecimentoEditorialDTO atualizar(Long id, CadastroConhecimentoEditorialDTO dto) {
        return repository.findByIdOptional(id)
                .map(k -> {
                    k.tipo = dto.tipo();
                    k.titulo = dto.titulo();
                    k.conteudo = dto.conteudo();
                    k.fonte = dto.fonte();
                    k.urlFonte = dto.urlFonte();
                    k.confianca = dto.confianca() != null ? dto.confianca() : k.confianca;
                    k.tags = dto.tags();
                    k.dataAtualizacao = LocalDateTime.now();
                    repository.persist(k);
                    return paraDTO(k);
                })
                .orElse(null);
    }

    @Transactional
    public void deletar(Long id) {
        repository.deleteById(id);
    }

    private ConhecimentoEditorialDTO paraDTO(ConhecimentoEditorial k) {
        return new ConhecimentoEditorialDTO(
                k.id,
                k.tipo,
                k.titulo,
                k.conteudo,
                k.fonte,
                k.urlFonte,
                k.confianca,
                k.dataCriacao,
                k.dataAtualizacao,
                k.origemDados,
                k.tags,
                k.relacionadas);
    }
}
