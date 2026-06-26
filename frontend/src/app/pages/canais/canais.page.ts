import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';

interface CanalHq {
  nome: string;
  url: string;
  imagemUrl: string | null;
}

@Component({
  selector: 'app-canais-page',
  imports: [CommonModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Canais parceiros</p>
        <h1>Conteudo sobre colecionismo, HQs e cultura geek.</h1>
      </div>
    </section>

    <section class="bloco canais-hq">
      <div class="grade-canais pagina-canais">
        @for (canal of canais; track canal.url) {
          <a [href]="canal.url" target="_blank" rel="noreferrer">
            @if (canal.imagemUrl) {
              <img [src]="canal.imagemUrl" [alt]="canal.nome" loading="lazy" />
            } @else {
              <span>{{ iniciaisCanal(canal.nome) }}</span>
            }
            <strong>{{ canal.nome }}</strong>
            <small>YouTube</small>
          </a>
        }
      </div>
    </section>
  `,
})
export class CanaisPage {
  readonly canais: CanalHq[] = [
    {
      nome: 'Nona Dimensao',
      url: 'https://www.youtube.com/@Nonadimens%C3%A3o',
      imagemUrl: 'https://yt3.googleusercontent.com/pqXz1nOsUDz1xMM2HaHoSkowspJWne2P9SD7EX2KlqznFE3QRmk2vlI6rfuaePR4auysLQCs-Q=s160-c-k-c0x00ffffff-no-rj',
    },
    {
      nome: 'Colecionador por Hobby',
      url: 'https://www.youtube.com/@colecionadorporhobby',
      imagemUrl: 'https://yt3.googleusercontent.com/hTxlzDp_W7wCQ4HstjrRVjVkAhihQtpFUTDcAlX42fN9YrwACz6bsJLvixjmTVT05CTPT1OU_w=s160-c-k-c0x00ffffff-no-rj',
    },
    {
      nome: 'Na Minha Estante HQs',
      url: 'https://www.youtube.com/@NaMinhaEstanteHQs',
      imagemUrl: 'https://yt3.googleusercontent.com/8BlqluYCyllUk7qsbLO3KzLAlR-giPXMRUAxwBy46Dr6-aTBjNAx9wLOOiGSR8UtRkQBFANu=s160-c-k-c0x00ffffff-no-rj',
    },
    {
      nome: 'Chiclete com Lombada',
      url: 'https://www.youtube.com/@Chicletecomlombada',
      imagemUrl: 'https://yt3.googleusercontent.com/cbmwaFwmF3DB2zs8Wc2VbpH1trnlzz4hkh0GtprHVF2DxPsqezYj5F8bpwalH79epyloTpRDlA=s160-c-k-c0x00ffffff-no-rj',
    },
    {
      nome: 'Ola Mundo Geek',
      url: 'https://www.youtube.com/@Ol%C3%A1MundoGeek',
      imagemUrl: 'https://yt3.googleusercontent.com/zK6K2vSmDIm9vaLZ4ljK_ro7ubPHMrFfSK3NE1aTlt1WxZCRCnxI-AfRY8YpQTjvNn-Ix-OLOQ=s160-c-k-c0x00ffffff-no-rj',
    },
    {
      nome: 'Contraponto HQs',
      url: 'https://www.youtube.com/@contrapontohqs',
      imagemUrl: 'https://yt3.googleusercontent.com/O2qyig_ZyWlProg-wc_P1r4IPoFhbO-myKNiAFoOSZSoFvuoGfpwPC__kLTSp-GHi3YNnmh1=s160-c-k-c0x00ffffff-no-rj',
    },
  ];

  iniciaisCanal(nome: string) {
    return nome
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((parte) => parte[0]?.toUpperCase())
      .join('');
  }
}
