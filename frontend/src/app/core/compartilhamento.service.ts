import { DOCUMENT } from '@angular/common';
import { Injectable, inject } from '@angular/core';

import { environment } from '../../environments/environment';

export interface DadosCompartilhamento {
  title: string;
  text: string;
  url: string;
}

export type ResultadoCompartilhamento = 'compartilhado' | 'copiado' | 'cancelado';

@Injectable({ providedIn: 'root' })
export class CompartilhamentoService {
  private readonly documento = inject(DOCUMENT);

  urlEdicao(edicaoId: number): string {
    return `${environment.compartilhamentoUrl}/edicoes/${edicaoId}?v=4`;
  }

  urlSerie(serieId: number): string {
    return `${environment.compartilhamentoUrl}/series/${serieId}?v=2`;
  }

  urlPostagem(postagemId: number): string {
    return `${environment.compartilhamentoUrl}/hq/${postagemId}?v=17`;
  }

  urlAnuncio(anuncioId: number): string {
    return `${environment.compartilhamentoUrl}/anuncios/${anuncioId}?v=${Date.now()}`;
  }

  async compartilhar(dados: DadosCompartilhamento, copiarMensagemCompleta = false): Promise<ResultadoCompartilhamento> {
    const navegador = this.documento.defaultView?.navigator;
    if (navegador?.share) {
      try {
        await navegador.share(dados);
        return 'compartilhado';
      } catch (erro) {
        if (erro instanceof DOMException && erro.name === 'AbortError') return 'cancelado';
        // Alguns navegadores expõem navigator.share, mas bloqueiam a folha
        // nativa. Nesse caso, o usuário ainda recebe o link pela área de cópia.
        await this.copiar(copiarMensagemCompleta ? `${dados.text}\n${dados.url}` : dados.url);
        return 'copiado';
      }
    }

    await this.copiar(copiarMensagemCompleta ? `${dados.text}\n${dados.url}` : dados.url);
    return 'copiado';
  }

  private async copiar(texto: string) {
    const navegador = this.documento.defaultView?.navigator;
    if (navegador?.clipboard?.writeText) {
      await navegador.clipboard.writeText(texto);
      return;
    }

    const area = this.documento.createElement('textarea');
    area.value = texto;
    area.setAttribute('readonly', '');
    area.style.position = 'fixed';
    area.style.left = '-9999px';
    this.documento.body.appendChild(area);
    area.select();
    this.documento.execCommand('copy');
    area.remove();
  }
}
