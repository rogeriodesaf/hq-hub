package br.com.hqhub.service;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ProdutoMythosParser {
    private static final Pattern META = Pattern.compile("<meta\\b([^>]*)>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern ATRIBUTO = Pattern.compile("([\\w:-]+)\\s*=\\s*([\\\"'])(.*?)\\2", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern JSON_STRING = Pattern.compile("\\\"%s\\\"\\s*:\\s*\\\"((?:\\\\.|[^\\\"\\\\])*)\\\"", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern JSON_PRICE = Pattern.compile("\\\"price\\\"\\s*:\\s*\\\"?([0-9]+(?:\\.[0-9]+)?)", Pattern.CASE_INSENSITIVE);
    private static final Pattern TITLE = Pattern.compile("^(.+?)\\s+(?:VOL\\.?\\s*)?(\\d+)(?:\\s*)$", Pattern.CASE_INSENSITIVE);
    private static final Pattern PAGES = Pattern.compile("(?i)(\\d+)\\s+p[aá]ginas");
    private static final Pattern FORMAT = Pattern.compile("(?i)Formato\\s*:\\s*([^?\\n]+)");

    public Produto extrair(String html) {
        String conteudo = html == null ? "" : html;
        Map<String, String> metas = metas(conteudo);
        String titulo = primeiro(extrairJson(conteudo, "name"), metas.get("og:title"));
        String descricao = limpar(metas.get("og:description"));
        String capa = primeiro(extrairJson(conteudo, "image"), metas.get("og:image"));
        String sku = extrairJson(conteudo, "sku");
        String codigoBarras = primeiro(extrairJson(conteudo, "gtin"), valorFicha(conteudo, "Código de barras"));
        String marca = extrairMarca(conteudo);
        BigDecimal preco = preco(conteudo);
        String texto = limparTags(descricao + " " + conteudo);
        Integer paginas = inteiro(PAGES, texto);
        String formato = primeiro(grupo(FORMAT, texto), null);
        String tituloNormalizado = primeiro(limpar(titulo), "Produto Mythos");
        Matcher tituloNumerado = TITLE.matcher(tituloNormalizado);
        String serie = tituloNumerado.matches() ? limpar(tituloNumerado.group(1)) : tituloNormalizado;
        String numero = tituloNumerado.matches() ? tituloNumerado.group(2) : null;
        return new Produto(titulo, serie, numero, descricao, capa, sku, codigoBarras, preco, paginas, formato, marca);
    }

    private Map<String, String> metas(String html) {
        Map<String, String> resultado = new LinkedHashMap<>();
        Matcher tags = META.matcher(html);
        while (tags.find()) {
            Map<String, String> atributos = atributos(tags.group(1));
            String chave = primeiro(atributos.get("property"), atributos.get("name"));
            if (chave != null && atributos.get("content") != null) resultado.putIfAbsent(chave.toLowerCase(Locale.ROOT), limpar(atributos.get("content")));
        }
        return resultado;
    }

    private Map<String, String> atributos(String texto) {
        Map<String, String> resultado = new LinkedHashMap<>();
        Matcher matcher = ATRIBUTO.matcher(texto == null ? "" : texto);
        while (matcher.find()) resultado.put(matcher.group(1).toLowerCase(Locale.ROOT), decodificar(matcher.group(3)));
        return resultado;
    }

    private String extrairJson(String html, String campo) {
        Matcher matcher = Pattern.compile(JSON_STRING.pattern().formatted(Pattern.quote(campo)), Pattern.CASE_INSENSITIVE | Pattern.DOTALL).matcher(html);
        return matcher.find() ? decodificar(matcher.group(1)) : null;
    }

    private String extrairMarca(String html) {
        Matcher matcher = Pattern.compile("\\\"brand\\\"\\s*:\\s*\\{.*?\\\"name\\\"\\s*:\\s*\\\"((?:\\\\.|[^\\\"\\\\])*)\\\"", Pattern.CASE_INSENSITIVE | Pattern.DOTALL).matcher(html);
        return matcher.find() ? decodificar(matcher.group(1)) : null;
    }

    private BigDecimal preco(String html) {
        Matcher matcher = JSON_PRICE.matcher(html);
        try { return matcher.find() ? new BigDecimal(matcher.group(1)) : null; } catch (NumberFormatException excecao) { return null; }
    }

    private String valorFicha(String html, String rotulo) {
        Pattern dataTh = Pattern.compile("(?is)data-th=[\"']" + Pattern.quote(rotulo) + "[\"'][^>]*>\\s*([^<]+)");
        String valor = grupo(dataTh, html);
        if (valor != null) return valor;
        Pattern texto = Pattern.compile("(?is)" + Pattern.quote(rotulo) + "\\s*</[^>]+>\\s*<[^>]+>\\s*([^<]+)");
        return grupo(texto, html);
    }

    private Integer inteiro(Pattern pattern, String texto) {
        String valor = grupo(pattern, texto);
        try { return valor == null ? null : Integer.valueOf(valor); } catch (NumberFormatException excecao) { return null; }
    }

    private String grupo(Pattern pattern, String texto) { Matcher matcher = pattern.matcher(texto == null ? "" : texto); return matcher.find() ? limpar(matcher.group(1)) : null; }
    private String primeiro(String... valores) { for (String valor : valores) if (valor != null && !valor.isBlank()) return valor.trim(); return null; }
    private String limpar(String valor) { return valor == null ? null : limparTags(valor).replaceAll("\\s+", " ").trim(); }
    private String limparTags(String valor) { return valor == null ? "" : valor.replaceAll("(?is)<[^>]+>", " ").replace("&nbsp;", " ").replace("&amp;", "&").replace("&quot;", "\"").replace("&#39;", "'"); }
    private String decodificar(String valor) { return limpar(valor == null ? null : valor.replace("\\/", "/").replace("\\\"", "\"")); }

    public record Produto(String titulo, String serie, String numero, String descricao, String urlCapa, String sku,
            String codigoBarras, BigDecimal preco, Integer quantidadePaginas, String formato, String marca) {}
}
