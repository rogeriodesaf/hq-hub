package br.com.hqhub.service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ConteudoOriginalPaniniParser {

    private static final Pattern CELULA = Pattern.compile("<td\\b([^>]*)>(.*?)</td>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern TITULO_OG = Pattern.compile("<meta\\b[^>]*property=[\"']og:title[\"'][^>]*content=[\"']([^\"']+)[\"'][^>]*>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern REFERENCIA_PADRAO = Pattern.compile("^(.+?)\\s*\\((\\d{4})\\)\\s*(?:#\\s*)?([\\p{L}\\d.\\-]+)(?:\\s*\\((.*?)(?:\\))?)?$");
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
        return new PaginaPanini(titulo, conteudoOriginal, referencias);
    }

    private List<ReferenciaExtraida> analisarReferencias(String texto) {
        Matcher anual = REFERENCIA_ANUAL.matcher(texto);
        if (anual.matches()) {
            String ano = anual.group(2);
            return List.of(new ReferenciaExtraida(texto, anual.group(1).trim(), null,
                    ano.length() == 2 ? "19" + ano : ano, limpar(anual.group(3))));
        }

        Matcher padrao = REFERENCIA_PADRAO.matcher(texto);
        if (padrao.matches()) {
            String numero = padrao.group(3).trim();
            Matcher intervalo = Pattern.compile("^(\\d+)-(\\d+)$").matcher(numero);
            if (intervalo.matches()) {
                int inicio = Integer.parseInt(intervalo.group(1));
                int fim = Integer.parseInt(intervalo.group(2));
                if (fim >= inicio && fim - inicio <= 20) {
                    List<ReferenciaExtraida> expandidas = new ArrayList<>();
                    for (int atual = inicio; atual <= fim; atual++) {
                        expandidas.add(new ReferenciaExtraida(
                                texto + " — #" + atual,
                                padrao.group(1).trim(),
                                Integer.valueOf(padrao.group(2)),
                                String.valueOf(atual),
                                limpar(padrao.group(4))));
                    }
                    return expandidas;
                }
            }
            return List.of(new ReferenciaExtraida(texto, padrao.group(1).trim(), Integer.valueOf(padrao.group(2)),
                    numero, limpar(padrao.group(4))));
        }
        return List.of(new ReferenciaExtraida(texto, null, null, null, null));
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

    public record PaginaPanini(String titulo, String conteudoOriginal, List<ReferenciaExtraida> referencias) {
    }

    public record ReferenciaExtraida(String textoOriginal, String serie, Integer anoSerie, String numero,
            String complemento) {
    }
}
