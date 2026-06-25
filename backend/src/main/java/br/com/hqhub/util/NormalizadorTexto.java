package br.com.hqhub.util;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

public final class NormalizadorTexto {

    private static final Charset WINDOWS_1252 = Charset.forName("Windows-1252");

    private NormalizadorTexto() {
    }

    public static String corrigirMojibake(String texto) {
        if (texto == null || texto.isBlank()) {
            return texto;
        }

        String corrigido = texto;
        for (int i = 0; i < 3 && pareceMojibake(corrigido); i++) {
            String tentativa = new String(corrigido.getBytes(WINDOWS_1252), StandardCharsets.UTF_8);
            if (tentativa.equals(corrigido)) {
                break;
            }
            corrigido = tentativa;
        }
        return corrigido;
    }

    public static boolean pareceMojibake(String texto) {
        if (texto == null || texto.isBlank()) {
            return false;
        }

        return texto.contains("Ã")
                || texto.contains("Â ")
                || texto.contains("Â ")
                || texto.contains("Â·")
                || texto.contains("Âº")
                || texto.contains("Âª")
                || texto.contains("â€")
                || texto.contains("â€“")
                || texto.contains("â€”")
                || texto.contains("â€¦")
                || texto.contains("�");
    }
}
