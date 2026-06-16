package br.com.hqhub.mapper;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import br.com.hqhub.dto.AnuncioRespostaDTO;
import br.com.hqhub.dto.AtualizacaoAnuncioDTO;
import br.com.hqhub.dto.CadastroAnuncioDTO;
import br.com.hqhub.dto.CadastroFotoAnuncioDTO;
import br.com.hqhub.dto.FotoAnuncioRespostaDTO;
import br.com.hqhub.entity.Anuncio;
import br.com.hqhub.entity.FotoAnuncio;
import br.com.hqhub.entity.ItemColecao;
import br.com.hqhub.entity.StatusAnuncio;
import br.com.hqhub.entity.Usuario;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class AnuncioMapper {

    public static final String AVISO_RESPONSABILIDADE = "O HQ-HUB não intermedeia pagamentos, entregas, trocas ou negociações. Os anúncios funcionam como classificados entre colecionadores. Toda negociação deve ser combinada diretamente entre os usuários, por canais externos, como WhatsApp. O sistema apenas organiza e divulga os anúncios.";

    private final UsuarioMapper usuarioMapper;
    private final ItemColecaoMapper itemColecaoMapper;

    public AnuncioMapper(UsuarioMapper usuarioMapper, ItemColecaoMapper itemColecaoMapper) {
        this.usuarioMapper = usuarioMapper;
        this.itemColecaoMapper = itemColecaoMapper;
    }

    public Anuncio paraEntidade(CadastroAnuncioDTO dto, Usuario anunciante, ItemColecao itemColecao) {
        Anuncio anuncio = new Anuncio();
        anuncio.setAnunciante(anunciante);
        anuncio.setItemColecao(itemColecao);
        anuncio.setTipoAnuncio(dto.tipoAnuncio());
        anuncio.setPreco(dto.preco());
        anuncio.setEstadoConservacao(dto.estadoConservacao());
        anuncio.setDescricao(dto.descricao());
        anuncio.setCidade(dto.cidade());
        anuncio.setEstado(normalizarEstado(dto.estado()));
        anuncio.setContatoWhatsapp(normalizarWhatsapp(dto.contatoWhatsapp()));
        anuncio.setExibirWhatsapp(Boolean.TRUE.equals(dto.exibirWhatsapp()));
        anuncio.setStatus(StatusAnuncio.ATIVO);
        return anuncio;
    }

    public void atualizarEntidade(Anuncio anuncio, AtualizacaoAnuncioDTO dto) {
        anuncio.setTipoAnuncio(dto.tipoAnuncio());
        anuncio.setPreco(dto.preco());
        anuncio.setEstadoConservacao(dto.estadoConservacao());
        anuncio.setDescricao(dto.descricao());
        anuncio.setCidade(dto.cidade());
        anuncio.setEstado(normalizarEstado(dto.estado()));
        anuncio.setContatoWhatsapp(normalizarWhatsapp(dto.contatoWhatsapp()));
        anuncio.setExibirWhatsapp(Boolean.TRUE.equals(dto.exibirWhatsapp()));
    }

    public FotoAnuncio paraFoto(CadastroFotoAnuncioDTO dto, Anuncio anuncio) {
        FotoAnuncio foto = new FotoAnuncio();
        foto.setAnuncio(anuncio);
        foto.setUrlImagem(dto.urlImagem());
        foto.setPrincipal(Boolean.TRUE.equals(dto.principal()));
        return foto;
    }

    public AnuncioRespostaDTO paraResposta(Anuncio anuncio) {
        return new AnuncioRespostaDTO(
                anuncio.getId(),
                anuncio.getItemColecao().getEdicao().getId(),
                tituloEdicao(anuncio),
                anuncio.getAnunciante().getNome(),
                usuarioMapper.paraResposta(anuncio.getAnunciante()),
                itemColecaoMapper.paraResposta(anuncio.getItemColecao()),
                anuncio.getTipoAnuncio(),
                anuncio.getPreco(),
                anuncio.getEstadoConservacao(),
                anuncio.getDescricao(),
                anuncio.getCidade(),
                anuncio.getEstado(),
                anuncio.getExibirWhatsapp(),
                contatoWhatsapp(anuncio),
                linkContatoWhatsapp(anuncio),
                anuncio.getStatus(),
                AVISO_RESPONSABILIDADE,
                anuncio.getDataCriacao(),
                anuncio.getDataAtualizacao());
    }

    public FotoAnuncioRespostaDTO paraResposta(FotoAnuncio foto) {
        return new FotoAnuncioRespostaDTO(
                foto.getId(),
                foto.getUrlImagem(),
                foto.getPrincipal(),
                foto.getDataCriacao());
    }

    private String normalizarEstado(String estado) {
        return estado == null || estado.isBlank() ? null : estado.trim().toUpperCase();
    }

    private String normalizarWhatsapp(String contatoWhatsapp) {
        if (contatoWhatsapp == null || contatoWhatsapp.isBlank()) {
            return null;
        }

        String contatoLimpo = contatoWhatsapp.replaceAll("\\D", "");
        return contatoLimpo.isBlank() ? null : contatoLimpo;
    }

    private String contatoWhatsapp(Anuncio anuncio) {
        if (!Boolean.TRUE.equals(anuncio.getExibirWhatsapp())) {
            return null;
        }

        return anuncio.getContatoWhatsapp();
    }

    private String linkContatoWhatsapp(Anuncio anuncio) {
        String contato = contatoWhatsapp(anuncio);
        if (contato == null || contato.isBlank()) {
            return null;
        }

        String mensagem = "Olá, vi no HQ-HUB que você está anunciando a HQ "
                + tituloEdicao(anuncio)
                + ". Ela ainda está disponível?";

        return "https://wa.me/" + contato + "?text=" + URLEncoder.encode(mensagem, StandardCharsets.UTF_8);
    }

    private String tituloEdicao(Anuncio anuncio) {
        return anuncio.getItemColecao().getEdicao().getSerie().getTitulo()
                + " #" + anuncio.getItemColecao().getEdicao().getNumero();
    }
}
