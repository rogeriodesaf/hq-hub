package br.com.hqhub.service;

import java.util.List;

import org.eclipse.microprofile.rest.client.annotation.ClientHeaderParam;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.QueryParam;

@RegisterRestClient(configKey = "comic-vine-api")
public interface ComicVineApiClient {

    record ComicVineResultado<T>(
            int statusCode,
            String error,
            List<T> results) {
    }

    record SerieComicVine(
            Long id,
            String name,
            String description,
            String siteDetailUrl) {
    }

    record PersonagemComicVine(
            Long id,
            String name,
            String description,
            String siteDetailUrl) {
    }

    record CriadorComicVine(
            Long id,
            String name,
            String description,
            String siteDetailUrl) {
    }

    @GET
    @Path("/series/")
    ComicVineResultado<SerieComicVine> buscarSerie(
            @QueryParam("api_key") String apiKey,
            @QueryParam("filter") String filter,
            @QueryParam("limit") int limit,
            @QueryParam("format") String format);

    @GET
    @Path("/characters/")
    ComicVineResultado<PersonagemComicVine> buscarPersonagem(
            @QueryParam("api_key") String apiKey,
            @QueryParam("filter") String filter,
            @QueryParam("limit") int limit,
            @QueryParam("format") String format);

    @GET
    @Path("/people/")
    ComicVineResultado<CriadorComicVine> buscarCriador(
            @QueryParam("api_key") String apiKey,
            @QueryParam("filter") String filter,
            @QueryParam("limit") int limit,
            @QueryParam("format") String format);

    // Métodos de conveniência com valores padrão
    default ComicVineResultado<SerieComicVine> buscarSerie(String nome) {
        String apiKey = System.getenv("COMIC_VINE_API_KEY");
        return buscarSerie(apiKey, "name:" + nome, 10, "json");
    }

    default ComicVineResultado<PersonagemComicVine> buscarPersonagem(String nome) {
        String apiKey = System.getenv("COMIC_VINE_API_KEY");
        return buscarPersonagem(apiKey, "name:" + nome, 10, "json");
    }

    default ComicVineResultado<CriadorComicVine> buscarCriador(String nome) {
        String apiKey = System.getenv("COMIC_VINE_API_KEY");
        return buscarCriador(apiKey, "name:" + nome, 10, "json");
    }
}
