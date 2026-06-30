package br.com.hqhub.service;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.imageio.ImageIO;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import com.cloudinary.Cloudinary;
import com.cloudinary.Transformation;
import com.cloudinary.utils.ObjectUtils;

import br.com.hqhub.dto.ImagemArmazenadaDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ArmazenamentoImagemService {

    private static final long LIMITE_CAPA_BYTES = 3L * 1024L * 1024L;
    private static final int LARGURA_CAPA = 800;
    private static final Set<String> TIPOS_PERMITIDOS = Set.of("image/jpeg", "image/png", "image/webp");

    @ConfigProperty(name = "CLOUDINARY_CLOUD_NAME", defaultValue = "")
    String cloudinaryCloudName;

    @ConfigProperty(name = "CLOUDINARY_API_KEY", defaultValue = "")
    String cloudinaryApiKey;

    @ConfigProperty(name = "CLOUDINARY_API_SECRET", defaultValue = "")
    String cloudinaryApiSecret;

    private Cloudinary cloudinary;
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    @PostConstruct
    void inicializarCloudinary() {
        if (!cloudinaryConfigurado()) {
            return;
        }

        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudinaryCloudName.trim(),
                "api_key", cloudinaryApiKey.trim(),
                "api_secret", cloudinaryApiSecret.trim(),
                "secure", true));
    }

    public ImagemArmazenadaDTO salvarCapa(FileUpload arquivo) {
        if (arquivo == null || arquivo.uploadedFile() == null) {
            throw new RegraNegocioException("Informe um arquivo de capa.");
        }

        String tipoMime = normalizarTipo(arquivo.contentType());
        validarExtensao(arquivo.fileName());
        validarArquivo(arquivo.uploadedFile(), tipoMime);
        return enviarParaCloudinary(arquivo.uploadedFile(), tipoMime);
    }

    public ImagemArmazenadaDTO salvarCapaPorUrl(String urlImagem) {
        URI uri = validarUrl(urlImagem);
        Path temporario = null;

        try {
            HttpRequest request = HttpRequest.newBuilder(uri)
                    .timeout(Duration.ofSeconds(20))
                    .header("User-Agent", "HQ-HUB/1.0")
                    .GET()
                    .build();

            HttpResponse<byte[]> resposta = httpClient.send(request, HttpResponse.BodyHandlers.ofByteArray());
            if (resposta.statusCode() < 200 || resposta.statusCode() >= 300) {
                throw new RegraNegocioException("Nao foi possivel baixar a imagem informada.");
            }

            byte[] conteudo = resposta.body();
            if (conteudo == null || conteudo.length == 0) {
                throw new RegraNegocioException("A imagem informada esta vazia.");
            }
            if (conteudo.length > LIMITE_CAPA_BYTES) {
                throw new RegraNegocioException("A imagem deve ter no maximo 3 MB.");
            }

            String tipoMime = normalizarTipo(resposta.headers().firstValue("content-type").orElse(""));
            if (!TIPOS_PERMITIDOS.contains(tipoMime)) {
                tipoMime = detectarTipoPorCabecalho(conteudo);
            }
            if (!TIPOS_PERMITIDOS.contains(tipoMime)) {
                throw new RegraNegocioException("A URL informada nao retornou uma imagem JPG, PNG ou WEBP valida.");
            }

            temporario = Files.createTempFile("hqhub-capa-", extensao(tipoMime));
            Files.write(temporario, conteudo);
            validarArquivo(temporario, tipoMime);
            return enviarParaCloudinary(temporario, tipoMime);
        } catch (RegraNegocioException e) {
            throw e;
        } catch (IOException | InterruptedException e) {
            if (e instanceof InterruptedException) {
                Thread.currentThread().interrupt();
            }
            throw new RegraNegocioException("Nao foi possivel baixar a imagem informada.");
        } finally {
            if (temporario != null) {
                try {
                    Files.deleteIfExists(temporario);
                } catch (IOException e) {
                    // Arquivo temporario; limpeza em melhor esforco.
                }
            }
        }
    }

    private void validarArquivo(Path arquivo, String tipoMime) {
        if (!cloudinaryAtivo()) {
            throw new RegraNegocioException("Cloudinary nao configurado. Configure CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY e CLOUDINARY_API_SECRET.");
        }

        try {
            long tamanho = Files.size(arquivo);
            if (tamanho == 0) {
                throw new RegraNegocioException("A imagem enviada esta vazia.");
            }
            if (tamanho > LIMITE_CAPA_BYTES) {
                throw new RegraNegocioException("A imagem deve ter no maximo 3 MB.");
            }
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel ler a imagem enviada.");
        }

        if (!TIPOS_PERMITIDOS.contains(tipoMime)) {
            throw new RegraNegocioException("Use apenas imagens JPG, PNG ou WEBP.");
        }

        validarConteudoImagem(arquivo, tipoMime);
    }

    private void validarExtensao(String nomeArquivo) {
        String nome = nomeArquivo == null ? "" : nomeArquivo.trim().toLowerCase(Locale.ROOT);
        if (!nome.endsWith(".jpg") && !nome.endsWith(".jpeg") && !nome.endsWith(".png") && !nome.endsWith(".webp")) {
            throw new RegraNegocioException("Use apenas arquivos JPG, JPEG, PNG ou WEBP.");
        }
    }

    private void validarConteudoImagem(Path arquivo, String tipoMime) {
        try {
            if ("image/webp".equals(tipoMime)) {
                byte[] cabecalho = Files.readAllBytes(arquivo);
                if (cabecalho.length < 12
                        || cabecalho[0] != 'R'
                        || cabecalho[1] != 'I'
                        || cabecalho[2] != 'F'
                        || cabecalho[3] != 'F'
                        || cabecalho[8] != 'W'
                        || cabecalho[9] != 'E'
                        || cabecalho[10] != 'B'
                        || cabecalho[11] != 'P') {
                    throw new RegraNegocioException("O arquivo WEBP enviado parece invalido.");
                }
                return;
            }

            if (ImageIO.read(arquivo.toFile()) == null) {
                throw new RegraNegocioException("Nao foi possivel ler a imagem enviada.");
            }
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel ler a imagem enviada.");
        }
    }

    private ImagemArmazenadaDTO enviarParaCloudinary(Path arquivo, String tipoMime) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> upload = cloudinary.uploader().upload(
                    arquivo.toFile(),
                    ObjectUtils.asMap(
                            "folder", "hqhub/capas",
                            "resource_type", "image",
                            "use_filename", false,
                            "unique_filename", true,
                            "overwrite", false,
                            "transformation", new Transformation<>()
                                    .width(LARGURA_CAPA)
                                    .crop("limit")
                                    .fetchFormat("webp")
                                    .quality("auto")));

            String urlImagem = stringOuVazio(upload.get("secure_url"));
            String publicId = stringOuVazio(upload.get("public_id"));

            if (urlImagem.isBlank() || publicId.isBlank()) {
                throw new RegraNegocioException("Nao foi possivel salvar a imagem enviada.");
            }

            return new ImagemArmazenadaDTO(
                    urlImagem,
                    publicId,
                    tipoMime,
                    numeroComoLong(upload.get("bytes")),
                    numeroComoInt(upload.get("width")),
                    numeroComoInt(upload.get("height")));
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel enviar a imagem para o Cloudinary.");
        }
    }

    private URI validarUrl(String urlImagem) {
        if (urlImagem == null || urlImagem.isBlank()) {
            throw new RegraNegocioException("Informe a URL da imagem.");
        }

        try {
            URI uri = URI.create(urlImagem.trim());
            String esquema = uri.getScheme();
            if (!"http".equalsIgnoreCase(esquema) && !"https".equalsIgnoreCase(esquema)) {
                throw new RegraNegocioException("Informe uma URL HTTP ou HTTPS valida.");
            }
            return uri;
        } catch (IllegalArgumentException e) {
            throw new RegraNegocioException("Informe uma URL valida.");
        }
    }

    private String detectarTipoPorCabecalho(byte[] conteudo) {
        if (conteudo.length >= 3
                && (conteudo[0] & 0xff) == 0xff
                && (conteudo[1] & 0xff) == 0xd8
                && (conteudo[2] & 0xff) == 0xff) {
            return "image/jpeg";
        }
        if (conteudo.length >= 8
                && (conteudo[0] & 0xff) == 0x89
                && conteudo[1] == 'P'
                && conteudo[2] == 'N'
                && conteudo[3] == 'G') {
            return "image/png";
        }
        if (conteudo.length >= 12
                && conteudo[0] == 'R'
                && conteudo[1] == 'I'
                && conteudo[2] == 'F'
                && conteudo[3] == 'F'
                && conteudo[8] == 'W'
                && conteudo[9] == 'E'
                && conteudo[10] == 'B'
                && conteudo[11] == 'P') {
            return "image/webp";
        }
        return "";
    }

    private boolean cloudinaryConfigurado() {
        return cloudinaryCloudName != null && !cloudinaryCloudName.isBlank()
                && cloudinaryApiKey != null && !cloudinaryApiKey.isBlank()
                && cloudinaryApiSecret != null && !cloudinaryApiSecret.isBlank();
    }

    private boolean cloudinaryAtivo() {
        return cloudinary != null;
    }

    private String normalizarTipo(String contentType) {
        if (contentType == null) {
            return "";
        }
        return contentType.split(";")[0].trim().toLowerCase(Locale.ROOT);
    }

    private String extensao(String tipoMime) {
        return switch (tipoMime) {
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            default -> ".jpg";
        };
    }

    private String stringOuVazio(Object valor) {
        return valor == null ? "" : String.valueOf(valor).trim();
    }

    private long numeroComoLong(Object valor) {
        if (valor instanceof Number numero) {
            return numero.longValue();
        }
        return 0L;
    }

    private Integer numeroComoInt(Object valor) {
        if (valor instanceof Number numero) {
            return numero.intValue();
        }
        return null;
    }
}
