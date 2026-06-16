package br.com.hqhub.configuracao;

import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.enums.SecuritySchemeType;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.security.SecurityScheme;

import jakarta.ws.rs.core.Application;

@OpenAPIDefinition(
        info = @Info(
                title = "HQ-HUB API",
                version = "1.0.0",
                description = "API do HQ-HUB para coleções, catálogo, comunidade, classificados e integrações externas."))
@SecurityScheme(
        securitySchemeName = "jwt",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT")
public class OpenApiConfiguracao extends Application {
}
