package br.com.hqhub.resource;

import java.net.URI;

import br.com.hqhub.dto.CadastroDenunciaAnuncioDTO;
import br.com.hqhub.dto.CadastroDenunciaUsuarioDTO;
import br.com.hqhub.dto.DenunciaAnuncioRespostaDTO;
import br.com.hqhub.dto.DenunciaUsuarioRespostaDTO;
import br.com.hqhub.service.DenunciaService;
import io.quarkus.security.Authenticated;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/denuncias")
@Authenticated
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class DenunciaResource {

    private final DenunciaService denunciaService;

    public DenunciaResource(DenunciaService denunciaService) {
        this.denunciaService = denunciaService;
    }

    @POST
    @Path("/anuncios")
    public Response denunciarAnuncio(@Valid CadastroDenunciaAnuncioDTO dto) {
        DenunciaAnuncioRespostaDTO resposta = denunciaService.denunciarAnuncio(dto);
        return Response.created(URI.create("/denuncias/anuncios/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/anuncios")
    public Response listarMinhasDenunciasAnuncios() {
        return Response.ok(denunciaService.listarMinhasDenunciasAnuncios()).build();
    }

    @POST
    @Path("/usuarios")
    public Response denunciarUsuario(@Valid CadastroDenunciaUsuarioDTO dto) {
        DenunciaUsuarioRespostaDTO resposta = denunciaService.denunciarUsuario(dto);
        return Response.created(URI.create("/denuncias/usuarios/" + resposta.id()))
                .entity(resposta)
                .build();
    }

    @GET
    @Path("/usuarios")
    public Response listarMinhasDenunciasUsuarios() {
        return Response.ok(denunciaService.listarMinhasDenunciasUsuarios()).build();
    }
}
