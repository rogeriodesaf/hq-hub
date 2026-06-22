package br.com.hqhub.service;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UrlPublicaService {

    @ConfigProperty(name = "hqhub.url-base", defaultValue = "http://localhost:62375")
    String urlBase;

    public String normalizarApiUrl(String url) {
        if (url == null || url.isBlank()) {
            return url;
        }

        String valor = url.trim();
        if (valor.startsWith("http://") || valor.startsWith("https://")) {
            return valor;
        }

        if (valor.startsWith("/api/")) {
            return baseNormalizada() + valor;
        }

        if (valor.startsWith("api/")) {
            return baseNormalizada() + "/" + valor;
        }

        return valor;
    }

    private String baseNormalizada() {
        String base = urlBase == null ? "" : urlBase.trim();
        if (base.endsWith("/")) {
            return base.substring(0, base.length() - 1);
        }
        return base;
    }
}