import { DOCUMENT } from '@angular/common';
import { Injectable, inject } from '@angular/core';

export interface DadosCompartilhamento {
  title: string;
  text: string;
  url: string;
}

export type ResultadoCompartilhamento = 'compartilhado' | 'copiado' | 'cancelado';

@Injectable({ providedIn: 'root' })
export class CompartilhamentoService {
  private readonly documento = inject(DOCUMENT);

  async compartilhar(dados: DadosCompartilhamento): Promise<ResultadoCompartilhamento> {
    const navegador = this.documento.defaultView?.navigator;
    if (navegador?.share) {
      try {
        await navegador.share(dados);
        return 'compartilhado';
      } catch (erro) {
        if (erro instanceof DOMException && erro.name === 'AbortError') return 'cancelado';
        throw erro;
      }
    }

    await this.copiar(dados.url);
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
