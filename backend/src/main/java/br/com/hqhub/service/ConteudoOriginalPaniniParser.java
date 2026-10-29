package br.com.hqhub.service;

import java.util.ArrayList;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConteudoOriginalPaniniParser {

    private static final Pattern CELULA = Pattern.compile("<td\\b([^>]*)>(.*?)</td>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern TITULO_OG = Pattern.compile("<meta\\b[^>]*property=[\"']og:title[\"'][^>]*content=[\"']([^\"']+)[\"'][^>]*>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern META = Pattern.compile("<meta\\b([^>]*)>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern ATRIBUTO = Pattern.compile("([\\w:-]+)\\s*=\\s*([\"'])(.*?)\\2", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern CAMPO_JSON_TEXTO = Pattern.compile("\"%s\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern PRECO_JSON = Pattern.compile("\"price\"\\s*:\\s*\"?([0-9]+(?:\\.[0-9]+)?)", Pattern.CASE_INSENSITIVE);
    private static final Pattern IMAGEM_SCHEMA = Pattern.compile("\"image\"\\s*:\\s*\\[\\s*\"((?:\\\\.|[^\"\\\\])+)\"", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern TITULO_NUMERADO = Pattern.compile("^(.+?)\\s+(\\d+)(?:\\s*\\((\\d+)\\))?$");
    private static final Pattern REFERENCIA_LISTA_PADRAO = Pattern.compile(
            "^(.+?)\\s*\\((\\d{4})\\)\\s*((?:#\\s*)?\\d+(?:-\\d+)?(?:\\s*,\\s*(?:#\\s*)?\\d+(?:-\\d+)?)+)$");
    private static final Pattern REFERENCIA_LISTA_SEM_ANO = Pattern.compile(
            "^(.+?)\\s+((?:#\\s*)?\\d+(?:-\\d+)?(?:\\s*,\\s*(?:#\\s*)?\\d+(?:-\\d+)?)+)$");
    private static final Pattern REFERENCIA_PADRAO = Pattern.compile("^(.+?)\\s*\\((\\d{4})\\)\\s*(?:#\\s*)?([\\p{L}\\d.\\-]+)(?:\\s*\\((.*?)(?:\\))?)?$");
    private static final Pattern REFERENCIA_SEM_ANO = Pattern.compile("^(.+?)\\s+(?:#\\s*)?(\\d+(?:-\\d+)?)(?:\\s*\\((.*?)(?:\\))?)?$");
    private static final Pattern REFERENCIA_ANUAL = Pattern.compile("^(.+?\\bAnnual)\\s*[’']?(\\d{2,4})(?:\\s*\\((.*?)(?:\\))?)?$", Pattern.CASE_INSENSITIVE);
    private static final Pattern ENTIDADE_NUMERICA = Pattern.compile("&#(?:x([0-9a-fA-F]+)|(\\d+));");

    public PaginaPanini extrair(String html) {
        String conteudoOriginal = null;
        Matcher celulas = CELULA.matcher(html == null ? "" : html);
        while (celulas.find()) {
            String atributos = normalizarRotulo(decodificarHtml(celulas.group(1)));
            if (atributos.contains("conteudooriginal")) {
                conteudoOriginal = htmlParaTexto(celulas.group(2));
                break;
            }
        }

        String titulo = null;
        Matcher tituloOg = TITULO_OG.matcher(html == null ? "" : html);
        if (tituloOg.find()) {
            titulo = htmlParaTexto(tituloOg.group(1));
        }

        List<ReferenciaExtraida> referencias = new ArrayList<>();
        if (conteudoOriginal != null && !conteudoOriginal.isBlank()) {
            for (String parte : conteudoOriginal.split(";")) {
                String texto = parte.trim();
                if (!texto.isBlank()) {
                    referencias.addAll(analisarReferencias(texto));
                }
            }
        }
        Map<String, String> metas = extrairMetas(html);
        titulo = primeiroPreenchido(titulo, metas.get("og:title"));
        String descricao = metas.get("og:description");
        String urlCapa = primeiroPreenchido(extrairImagemSchema(html), metas.get("og:image"));
        String sku = extrairCampoJson(html, "sku");
        String isbn = extrairCampoJson(html, "isbn");
        String marca = extrairMarca(html);
        LocalDate disponibilidade = data(extrairCampoJson(html, "availabilityStarts"));
        BigDecimal preco = decimal(html);
        Map<String, String> detalhes = extrairDetalhes(html);
        String tituloSerie = null;
        String numero = null;
        String numeroAlternativo = null;
        Matcher tituloNumerado = TITULO_NUMERADO.matcher(titulo == null ? "" : titulo.trim());
        if (tituloNumerado.matches()) {
            tituloSerie = tituloNumerado.group(1).trim();
            numero = tituloNumerado.group(2);
            numeroAlternativo = limpar(tituloNumerado.group(3));
        }
        ProdutoPanini produto = new ProdutoPanini(
                tituloSerie,
                numero,
                numeroAlternativo,
                descricao,
                urlCapa,
                sku,
                isbn,
                preco,
                disponibilidade,
                inteiro(detalhe(detalhes, "numerodepaginas", "paginas")),
                detalhe(detalhes, "formato"),
                detalhe(detalhes, "classificacaoetaria"),
                detalhe(detalhes, "tipodeproduto", "categoria"),
                marca,
                autores(detalhe(detalhes, "autores", "autor")));
        return new PaginaPanini(titulo, conteudoOriginal, referencias, produto);
    }

    private Map<String, String> extrairMetas(String html) {
        Map<String, String> metas = new LinkedHashMap<>();
        Matcher tags = META.matcher(html == null ? "" : html);
        while (tags.find()) {
            Map<String, String> atributos = atributos(tags.group(1));
            String chave = primeiroPreenchido(atributos.get("property"), atributos.get("name"));
            String valor = atributos.get("content");
            if (chave != null && valor != null) {
                metas.putIfAbsent(chave.toLowerCase(), htmlParaTexto(valor));
            }
        }
        return metas;
    }

    private Map<String, String> atributos(String texto) {
        Map<String, String> atributos = new LinkedHashMap<>();
        Matcher matcher = ATRIBUTO.matcher(texto == null ? "" : texto);
        while (matcher.find()) {
            atributos.put(matcher.group(1).toLowerCase(), decodificarHtml(matcher.group(3)));
        }
        return atributos;
    }

    private Map<String, String> extrairDetalhes(String html) {
        Map<String, String> detalhes = new LinkedHashMap<>();
        Matcher celulas = CELULA.matcher(html == null ? "" : html);
        while (celulas.find()) {
            Map<String, String> atributos = atributos(celulas.group(1));
            String rotulo = primeiroPreenchido(atributos.get("data-th"), atributos.get("aria-label"));
            if (rotulo != null) {
                detalhes.put(normalizarRotulo(rotulo), htmlParaTexto(celulas.group(2)));
            }
        }
        return detalhes;
    }

    private String extrairCampoJson(String html, String campo) {
        Matcher matcher = Pattern.compile(CAMPO_JSON_TEXTO.pattern().formatted(Pattern.quote(campo)),
                Pattern.CASE_INSENSITIVE | Pattern.DOTALL).matcher(html == null ? "" : html);
        return matcher.find() ? decodificarJson(matcher.group(1)) : null;
    }

    private String extrairImagemSchema(String html) {
        Matcher matcher = IMAGEM_SCHEMA.matcher(html == null ? "" : html);
        return matcher.find() ? decodificarJson(matcher.group(1)) : null;
    }

    private String extrairMarca(String html) {
        Matcher matcher = Pattern.compile("\"brand\"\\s*:\\s*\\{.*?\"name\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"",
                Pattern.CASE_INSENSITIVE | Pattern.DOTALL).matcher(html == null ? "" : html);
        return matcher.find() ? decodificarJson(matcher.group(1)) : null;
    }

    private BigDecimal decimal(String html) {
        Matcher matcher = PRECO_JSON.matcher(html == null ? "" : html);
        try {
            return matcher.find() ? new BigDecimal(matcher.group(1)) : null;
        } catch (NumberFormatException excecao) {
            return null;
        }
    }

    private LocalDate data(String valor) {
        try {
            return valor == null ? null : LocalDate.parse(valor);
        } catch (java.time.format.DateTimeParseException excecao) {
            return null;
        }
    }

    private Integer inteiro(String valor) {
        if (valor == null) return null;
        Matcher matcher = Pattern.compile("\\d+").matcher(valor);
        try {
            return matcher.find() ? Integer.valueOf(matcher.group()) : null;
        } catch (NumberFormatException excecao) {
            return null;
        }
    }

    private String detalhe(Map<String, String> detalhes, String... chaves) {
        for (String chave : chaves) {
            String valor = detalhes.get(chave);
            if (valor != null && !valor.isBlank()) return valor;
        }
        return null;
    }

    private List<String> autores(String valor) {
        if (valor == null || valor.isBlank()) return List.of();
        return Pattern.compile("\\s*[,;]\\s*")
                .splitAsStream(valor.trim())
                .map(String::trim)
                .filter(nome -> !nome.isBlank())
                .distinct()
                .toList();
    }

    private String primeiroPreenchido(String... valores) {
        for (String valor : valores) {
            if (valor != null && !valor.isBlank()) return valor.trim();
        }
        return null;
    }

    private String decodificarJson(String valor) {
        if (valor == null) return null;
        String resultado = valor.replace("\\/", "/").replace("\\\"", "\"").replace("\\n", " ");
        Matcher unicode = Pattern.compile("\\\\u([0-9a-fA-F]{4})").matcher(resultado);
        StringBuffer buffer = new StringBuffer();
        while (unicode.find()) {
            unicode.appendReplacement(buffer, Matcher.quoteReplacement(
                    String.valueOf((char) Integer.parseInt(unicode.group(1), 16))));
        }
        unicode.appendTail(buffer);
        return htmlParaTexto(buffer.toString());
    }

    private List<ReferenciaExtraida> analisarReferencias(String texto) {
        Matcher listaPadrao = REFERENCIA_LISTA_PADRAO.matcher(texto);
        if (listaPadrao.matches()) {
            return criarReferenciasLista(
                    texto, listaPadrao.group(1), Integer.valueOf(listaPadrao.group(2)), listaPadrao.group(3));
        }

        Matcher listaSemAno = REFERENCIA_LISTA_SEM_ANO.matcher(texto);
        if (listaSemAno.matches()) {
            return criarReferenciasLista(texto, listaSemAno.group(1), null, listaSemAno.group(2));
        }

        Matcher anual = REFERENCIA_ANUAL.matcher(texto);
        if (anual.matches()) {
            String ano = anual.group(2);
            return List.of(new ReferenciaExtraida(texto, anual.group(1).trim(), null,
                    ano.length() == 2 ? "19" + ano : ano, limpar(anual.group(3))));
        }

        Matcher padrao = REFERENCIA_PADRAO.matcher(texto);
        if (padrao.matches()) {
            return criarReferenciasNumeradas(texto, padrao.group(1), Integer.valueOf(padrao.group(2)),
                    padrao.group(3), padrao.group(4));
        }

        Matcher semAno = REFERENCIA_SEM_ANO.matcher(texto);
        if (semAno.matches()) {
            return criarReferenciasNumeradas(texto, semAno.group(1), null, semAno.group(2), semAno.group(3));
        }
        return List.of(new ReferenciaExtraida(texto, null, null, null, null));
    }

    private List<ReferenciaExtraida> criarReferenciasNumeradas(
            String texto, String serie, Integer anoSerie, String numeroInformado, String complemento) {
        String numero = numeroInformado.trim();
        Matcher intervalo = Pattern.compile("^(\\d+)-(\\d+)$").matcher(numero);
        if (intervalo.matches()) {
            int inicio = Integer.parseInt(intervalo.group(1));
            int fim = Integer.parseInt(intervalo.group(2));
            if (fim >= inicio && fim - inicio <= 20) {
                List<ReferenciaExtraida> expandidas = new ArrayList<>();
                for (int atual = inicio; atual <= fim; atual++) {
                    expandidas.add(new ReferenciaExtraida(
                            texto + " — #" + atual,
                            serie.trim(),
                            anoSerie,
                            String.valueOf(atual),
                            limpar(complemento)));
                }
                return expandidas;
            }
        }
        return List.of(new ReferenciaExtraida(texto, serie.trim(), anoSerie, numero, limpar(complemento)));
    }

    private List<ReferenciaExtraida> criarReferenciasLista(
            String texto, String serie, Integer anoSerie, String numerosInformados) {
        List<ReferenciaExtraida> referencias = new ArrayList<>();
        for (String parte : numerosInformados.split("\\s*,\\s*")) {
            String numero = parte.replaceFirst("^#\\s*", "").trim();
            Matcher intervalo = Pattern.compile("^(\\d+)-(\\d+)$").matcher(numero);
            if (intervalo.matches()) {
                int inicio = Integer.parseInt(intervalo.group(1));
                int fim = Integer.parseInt(intervalo.group(2));
                if (fim >= inicio && fim - inicio <= 20) {
                    for (int atual = inicio; atual <= fim; atual++) {
                        referencias.add(new ReferenciaExtraida(
                                texto + " — #" + atual, serie.trim(), anoSerie, String.valueOf(atual), null));
                    }
                    continue;
                }
            }
            referencias.add(new ReferenciaExtraida(
                    texto + " — #" + numero, serie.trim(), anoSerie, numero, null));
        }
        return referencias;
    }

    private String htmlParaTexto(String valor) {
        if (valor == null) {
            return null;
        }
        return decodificarHtml(valor.replaceAll("(?is)<br\\s*/?>", " ").replaceAll("(?is)<[^>]+>", " "))
                .replace('\u00a0', ' ').replaceAll("\\s+", " ").trim();
    }

    private String decodificarHtml(String valor) {
        Matcher matcher = ENTIDADE_NUMERICA.matcher(valor);
        StringBuffer resultado = new StringBuffer();
        while (matcher.find()) {
            int codigo = Integer.parseInt(matcher.group(1) != null ? matcher.group(1) : matcher.group(2),
                    matcher.group(1) != null ? 16 : 10);
            matcher.appendReplacement(resultado, Matcher.quoteReplacement(new String(Character.toChars(codigo))));
        }
        matcher.appendTail(resultado);
        return resultado.toString()
                .replace("&nbsp;", " ").replace("&amp;", "&").replace("&quot;", "\"")
                .replace("&apos;", "'").replace("&#39;", "'").replace("&rsquo;", "’")
                .replace("&ndash;", "–").replace("&mdash;", "—");
    }

    private String normalizarRotulo(String valor) {
        return java.text.Normalizer.normalize(valor, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "").replaceAll("[^a-zA-Z]", "").toLowerCase();
    }

    private String limpar(String valor) {
        return valor == null || valor.isBlank() ? null : valor.trim();
    }

    public record PaginaPanini(
            String titulo,
            String conteudoOriginal,
            List<ReferenciaExtraida> referencias,
            ProdutoPanini produto) {
    }

    public record ProdutoPanini(
            String tituloSerieSugerido,
            String numeroSugerido,
            String numeroAlternativo,
            String descricao,
            String urlCapa,
            String sku,
            String isbn,
            BigDecimal preco,
            LocalDate dataDisponibilidade,
            Integer quantidadePaginas,
            String formato,
            String classificacaoEtaria,
            String categoria,
            String marca,
            List<String> autores) {
    }

    public record ReferenciaExtraida(String textoOriginal, String serie, Integer anoSerie, String numero,
            String complemento) {
    }
}
