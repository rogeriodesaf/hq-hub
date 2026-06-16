package br.com.hqhub.mapper;

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

    public static final String AVISO_RESPONSABILIDADE = "O HQ-HUB não intermedeia pagamentos, entregas, trocas ou negociações. Os anúncios funcionam como classificados entre colecionadores.";

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
        anuncio.setEstado(dto.estado().toUpperCase());
        anuncio.setContatoWhatsapp(dto.contatoWhatsapp());
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
        anuncio.setEstado(dto.estado().toUpperCase());
        anuncio.setContatoWhatsapp(dto.contatoWhatsapp());
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
                usuarioMapper.paraResposta(anuncio.getAnunciante()),
                itemColecaoMapper.paraResposta(anuncio.getItemColecao()),
                anuncio.getTipoAnuncio(),
                anuncio.getPreco(),
                anuncio.getEstadoConservacao(),
                anuncio.getDescricao(),
                anuncio.getCidade(),
                anuncio.getEstado(),
                anuncio.getExibirWhatsapp(),
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
}
