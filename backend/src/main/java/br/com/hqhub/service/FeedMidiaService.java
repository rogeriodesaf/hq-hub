package br.com.hqhub.service;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import br.com.hqhub.dto.ImagemFeedDTO;
import br.com.hqhub.exception.RegraNegocioException;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class FeedMidiaService {

    private static final int LIMITE_IMAGENS = 3;
    private static final long LIMITE_BYTES = 2L * 1024L * 1024L;
    private static final int LARGURA_MAXIMA = 1600;
    private static final int THUMB_MAXIMA = 420;
    private static final Set<String> TIPOS_PERMITIDOS = Set.of("image/jpeg", "image/png", "image/webp");

    @ConfigProperty(name = "hqhub.uploads.feed.diretorio", defaultValue = "uploads/feed")
    String diretorioFeed;

    public List<ImagemFeedDTO> salvarImagens(List<FileUpload> arquivos) {
        if (arquivos == null || arquivos.isEmpty()) {
            return List.of();
        }

        if (arquivos.size() > LIMITE_IMAGENS) {
            throw new RegraNegocioException("A postagem pode ter no maximo 3 imagens.");
        }

        try {
            Files.createDirectories(diretorioBase());
            Files.createDirectories(diretorioThumbs());
        } catch (IOException e) {
            throw new RegraNegocioException("Nao foi possivel preparar o armazenamento de imagens.");
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

    private String normalizarTipo(String contentType) {
        if (contentType == null) {
            return "";
        }
        return contentType.split(";")[0].trim().toLowerCase(Locale.ROOT);
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
        return "/api/midia/feed/" + nomeArquivo;
    }

    private String urlThumb(String nomeArquivo) {
        return "/api/midia/feed/" + nomeArquivo;
    }
}
