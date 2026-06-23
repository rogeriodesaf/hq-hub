package br.com.hqhub.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.Transformation;
import com.cloudinary.utils.ObjectUtils;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class FeedMidiaService {

    private static final int LIMITE_IMAGENS = 3;
    private static final long LIMITE_BYTES = 2L * 1024L * 1024L;
    private static final int LARGURA_MAXIMA = 1600;
    private static final int THUMB_MAXIMA = 420;
    private static final Set<String> TIPOS_PERMITIDOS = Set.of("image/jpeg", "image/png", "image/webp");
    private static final Pattern PADRAO_PUBLIC_ID_COM_VERSAO = Pattern.compile("^(?:.+/)?v\\d+/(.+)$");

    @ConfigProperty(name = "hqhub.uploads.feed.diretorio", defaultValue = "uploads/feed")
    String diretorioFeed;

    @ConfigProperty(name = "hqhub.url-base", defaultValue = "http://localhost:62375")
    String urlBase;

    @ConfigProperty(name = "CLOUDINARY_CLOUD_NAME", defaultValue = "")
    String cloudinaryCloudName;

    @ConfigProperty(name = "CLOUDINARY_API_KEY", defaultValue = "")
    String cloudinaryApiKey;

    @ConfigProperty(name = "CLOUDINARY_API_SECRET", defaultValue = "")
    String cloudinaryApiSecret;

    private Cloudinary cloudinary;

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

    public List<ImagemFeedDTO> salvarImagens(List<FileUpload> arquivos) {
        if (arquivos == null || arquivos.isEmpty()) {
            return List.of();
        }

        if (arquivos.size() > LIMITE_IMAGENS) {
            throw new RegraNegocioException("A postagem pode ter no maximo 3 imagens.");
        }

        if (!cloudinaryAtivo()) {
            try {
                Files.createDirectories(diretorioBase());
                Files.createDirectories(diretorioThumbs());
            } catch (IOException e) {
                throw new RegraNegocioException("Nao foi possivel preparar o armazenamento de imagens.");
            }
        }

        List<ImagemFeedDTO> imagens = new ArrayList<>();
        for (int i = 0; i < arquivos.size(); i++) {
            imagens.add(salvarImagem(arquivos.get(i), i));
        }
        return imagens;
    }

    public Path buscarArquivo(String nomeArquivo) {
        if (nomeArquivo == null || nomeArquivo.contains("..") || nomeArquivo.contains("/") || nomeArquivo.contains("\\")) {
            throw new RegraNegocioException("Arquivo invalido.");
        }

        Path arquivo = diretorioBase().resolve(nomeArquivo).normalize();
        if (!Files.exists(arquivo)) {
            arquivo = diretorioThumbs().resolve(nomeArquivo).normalize();
        }
        return arquivo;
    }

    public void excluirImagemCloudinaryPorUrl(String urlImagem) {
        if (!cloudinaryAtivo() || urlImagem == null || urlImagem.isBlank()) {
            return;
        }

        String publicId = extrairPublicIdCloudinary(urlImagem);
        if (publicId == null || publicId.isBlank()) {
            return;
        }

        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.asMap(
                    "resource_type", "image",
                    "invalidate", true));
        } catch (IOException e) {
            // Melhor esforço: nao falhar atualizacao de perfil por erro na limpeza da imagem antiga.
        }
    }

    private ImagemFeedDTO salvarImagem(FileUpload arquivo, int ordem) {
        Path origem = arquivo.uploadedFile();
        String tipoMime = normalizarTipo(arquivo.contentType());
        long tamanho = tamanhoArquivo(origem);

        if (!TIPOS_PERMITIDOS.contains(tipoMime)) {
            throw new RegraNegocioException("Use apenas imagens JPG, PNG ou WEBP.");
        }

        if (tamanho > LIMITE_BYTES) {
            throw new RegraNegocioException("Cada imagem deve ter no maximo 2 MB.");
        }

        if (cloudinaryAtivo()) {
            return salvarImagemCloudinary(origem, tipoMime, ordem);
        }

        String base = UUID.randomUUID().toString();
        boolean webp = "image/webp".equals(tipoMime);
        String nomeImagem = base + (webp ? ".webp" : ".jpg");
        String nomeThumb = base + "-thumb" + (webp ? ".webp" : ".jpg");
        Path destinoImagem = diretorioBase().resolve(nomeImagem);
        Path destinoThumb = diretorioThumbs().resolve(nomeThumb);

        try {
            if (webp) {
                validarWebp(origem);
                Files.copy(origem, destinoImagem);
                Files.copy(origem, destinoThumb);
                return new ImagemFeedDTO(url(nomeImagem), urlThumb(nomeThumb), nomeImagem, tipoMime, tamanho, null, null, ordem);
            }

            BufferedImage original = ImageIO.read(origem.toFile());
            if (original == null) {
                throw new RegraNegocioException("Nao foi possivel ler a imagem enviada.");
            }

            BufferedImage imagem = redimensionar(original, LARGURA_MAXIMA);
            BufferedImage thumb = redimensionar(original, THUMB_MAXIMA);
            escreverJpeg(imagem, destinoImagem, 0.82f);
            escreverJpeg(thumb, destinoThumb, 0.72f);
            return new ImagemFeedDTO(
                    url(nomeImagem),
                    urlThumb(nomeThumb),
                    nomeImagem,
                    "image/jpeg",
                    Files.size(destinoImagem),
                    imagem.getWidth(),
                    imagem.getHeight(),
                    ordem);
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel salvar a imagem enviada.");
        }
    }

    private ImagemFeedDTO salvarImagemCloudinary(Path origem, String tipoMime, int ordem) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> upload = cloudinary.uploader().upload(
                    origem.toFile(),
                    ObjectUtils.asMap(
                            "folder", "hqhub/feed",
                            "resource_type", "image",
                            "use_filename", false,
                            "unique_filename", true,
                            "overwrite", false));

            String urlImagem = stringOuVazio(upload.get("secure_url"));
            String publicId = stringOuVazio(upload.get("public_id"));

            if (urlImagem.isBlank() || publicId.isBlank()) {
                throw new RegraNegocioException("Nao foi possivel salvar a imagem enviada.");
            }

            String formato = stringOuVazio(upload.get("format"));
            long tamanho = numeroComoLong(upload.get("bytes"));
            Integer largura = numeroComoInt(upload.get("width"));
            Integer altura = numeroComoInt(upload.get("height"));

            String urlThumb = cloudinary.url()
                    .secure(true)
                    .transformation(new Transformation<>()
                            .width(THUMB_MAXIMA)
                            .height(THUMB_MAXIMA)
                            .crop("limit")
                            .fetchFormat("auto")
                            .quality("auto"))
                    .generate(publicId);

            String tipoResposta = tipoMime;
            if (tipoResposta.isBlank() && !formato.isBlank()) {
                tipoResposta = "image/" + formato.toLowerCase(Locale.ROOT);
            }

            return new ImagemFeedDTO(
                    urlImagem,
                    urlThumb,
                    publicId,
                    tipoResposta,
                    tamanho,
                    largura,
                    altura,
                    ordem);
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel salvar a imagem enviada.");
        }
    }

    private boolean cloudinaryConfigurado() {
        return cloudinaryCloudName != null && !cloudinaryCloudName.isBlank()
                && cloudinaryApiKey != null && !cloudinaryApiKey.isBlank()
                && cloudinaryApiSecret != null && !cloudinaryApiSecret.isBlank();
    }

    private boolean cloudinaryAtivo() {
        return cloudinary != null;
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

    private String normalizarTipo(String contentType) {
        if (contentType == null) {
            return "";
        }
        return contentType.split(";")[0].trim().toLowerCase(Locale.ROOT);
    }

    private String extrairPublicIdCloudinary(String urlImagem) {
        try {
            URI uri = URI.create(urlImagem);
            String caminho = uri.getPath();
            int indiceUpload = caminho.indexOf("/upload/");
            if (indiceUpload < 0) {
                return null;
            }

            String restante = caminho.substring(indiceUpload + "/upload/".length());
            Matcher matcher = PADRAO_PUBLIC_ID_COM_VERSAO.matcher(restante);
            if (matcher.matches()) {
                restante = matcher.group(1);
            }

            int ultimaBarra = restante.lastIndexOf('/');
            int ultimoPonto = restante.lastIndexOf('.');
            if (ultimoPonto > ultimaBarra) {
                restante = restante.substring(0, ultimoPonto);
            }

            return restante.isBlank() ? null : restante;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private long tamanhoArquivo(Path arquivo) {
        try {
            return Files.size(arquivo);
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel ler a imagem enviada.");
        }
    }

    private void validarWebp(Path arquivo) throws IOException {
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
    }

    private BufferedImage redimensionar(BufferedImage original, int maximo) {
        int largura = original.getWidth();
        int altura = original.getHeight();
        double escala = Math.min(1.0, (double) maximo / Math.max(largura, altura));
        int novaLargura = Math.max(1, (int) Math.round(largura * escala));
        int novaAltura = Math.max(1, (int) Math.round(altura * escala));

        BufferedImage destino = new BufferedImage(novaLargura, novaAltura, BufferedImage.TYPE_INT_RGB);
        Graphics2D grafico = destino.createGraphics();
        grafico.setColor(Color.WHITE);
        grafico.fillRect(0, 0, novaLargura, novaAltura);
        grafico.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        grafico.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        grafico.drawImage(original, 0, 0, novaLargura, novaAltura, null);
        grafico.dispose();
        return destino;
    }

    private void escreverJpeg(BufferedImage imagem, Path destino, float qualidade) throws IOException {
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
        ImageWriteParam parametros = writer.getDefaultWriteParam();
        parametros.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
        parametros.setCompressionQuality(qualidade);

        try (ImageOutputStream output = ImageIO.createImageOutputStream(destino.toFile())) {
            writer.setOutput(output);
            writer.write(null, new IIOImage(imagem, null, null), parametros);
        } finally {
            writer.dispose();
        }
    }

    private Path diretorioBase() {
        return Path.of(diretorioFeed).toAbsolutePath().normalize();
    }

    private Path diretorioThumbs() {
        return diretorioBase().resolve("thumbs");
    }

    private String url(String nomeArquivo) {
        return urlMidia(nomeArquivo);
    }

    private String urlThumb(String nomeArquivo) {
        return urlMidia(nomeArquivo);
    }

    private String urlMidia(String nomeArquivo) {
        String base = urlBase == null ? "" : urlBase.trim();
        if (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        return base + "/api/midia/feed/" + nomeArquivo;
    }
}
