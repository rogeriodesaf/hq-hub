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
    { nome: 'Nona Dimensao', url: 'https://www.youtube.com/@Nonadimens%C3%A3o', imagemUrl: null },
    { nome: 'Colecionador por Hobby', url: 'https://www.youtube.com/@colecionadorporhobby', imagemUrl: null },
    { nome: 'Na Minha Estante HQs', url: 'https://www.youtube.com/@NaMinhaEstanteHQs', imagemUrl: null },
    { nome: 'Chiclete com Lombada', url: 'https://www.youtube.com/@Chicletecomlombada', imagemUrl: null },
    { nome: 'Ola Mundo Geek', url: 'https://www.youtube.com/@Ol%C3%A1MundoGeek', imagemUrl: null },
    { nome: 'Contraponto HQs', url: 'https://www.youtube.com/@contrapontohqs', imagemUrl: null },
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
