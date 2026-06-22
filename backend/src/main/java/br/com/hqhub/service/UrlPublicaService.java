package br.com.hqhub.service;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class UrlPublicaService {

    @ConfigProperty(name = "hqhub.url-base", defaultValue = "")
    String urlBase;

    public String normalizarApiUrl(String url) {
        if (url == null || url.isBlank()) {
            return url;
        }

        String valor = url.trim();
        if (valor.startsWith("http://") || valor.startsWith("https://")) {
            return valor;
        }

        String base = baseNormalizada();

        if (valor.startsWith("/api/")) {
            return base.isEmpty() ? valor : base + valor;
        }

        if (valor.startsWith("api/")) {
            return base.isEmpty() ? "/" + valor : base + "/" + valor;
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