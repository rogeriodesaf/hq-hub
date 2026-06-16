import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { EdicaoComicVine, PaginaResposta, VolumeComicVine } from '../../core/modelos';

@Component({
  selector: 'app-descobrir-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Busca externa</p>
        <h1>Encontre volumes e carregue edições em ordem cronológica.</h1>
      </div>
    </section>

    <section class="barra-busca">
      <input [(ngModel)]="termo" placeholder="Amazing Spider-Man, Batman, X-Men..." (keyup.enter)="buscarVolumes()" />
      <button class="botao primario" type="button" (click)="buscarVolumes()">Buscar</button>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    <section class="grade-volumes">
      @for (volume of volumes().itens; track volume.idExterno) {
        <article class="cartao-volume" [class.selecionado]="volumeSelecionado()?.idExterno === volume.idExterno">
          <img [src]="volume.urlImagem || capaReserva" [alt]="volume.titulo" loading="lazy" />
          <div>
            <p class="rotulo">{{ volume.editora || 'Editora não informada' }}</p>
            <h2>{{ volume.titulo }}</h2>
            <p>{{ volume.anoInicio || 'Ano não informado' }} · {{ volume.quantidadeEdicoes || 0 }} edições</p>
            <button class="botao compacto" type="button" (click)="selecionarVolume(volume)">
              Ver edições
            </button>
          </div>
        </article>
      }
    </section>

    @if (volumeSelecionado()) {
      <section class="secao-edicoes">
        <div class="secao-titulo">
          <div>
            <p class="rotulo">Volume selecionado</p>
            <h2>{{ volumeSelecionado()?.titulo }}</h2>
          </div>
          <div class="paginacao">
            <button class="botao icone-texto" type="button" [disabled]="paginaEdicoes() === 0" (click)="mudarPagina(-1)">
              Anterior
            </button>
            <span>Página {{ paginaEdicoes() + 1 }} de {{ edicoes()?.totalPaginas || 1 }}</span>
            <button class="botao icone-texto" type="button" [disabled]="paginaEdicoes() + 1 >= (edicoes()?.totalPaginas || 1)" (click)="mudarPagina(1)">
              Próxima
            </button>
          </div>
        </div>

        <div class="grade-edicoes">
          @for (edicao of edicoes()?.itens || []; track edicao.idExterno) {
            <article class="cartao-edicao">
              <img [src]="edicao.urlImagem || capaReserva" [alt]="edicao.titulo || 'Edição sem título'" loading="lazy" />
              <div>
                <p class="rotulo">#{{ edicao.numero || '-' }} · {{ edicao.dataCapa || 'sem data' }}</p>
                <h3>{{ edicao.titulo || edicao.nomeVolume }}</h3>
                <p>{{ limitarTexto(edicao.descricao, 170) }}</p>
                @if (edicao.creditos.length) {
                  <small>{{ listarCreditos(edicao) }}</small>
                }
              </div>
            </article>
          }
        </div>
      </section>
    }
  `,
})
export class DescobrirPage {
  private readonly api = inject(ApiService);

  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly volumes = signal<PaginaResposta<VolumeComicVine>>({
    itens: [],
    pagina: 0,
    tamanho: 12,
    totalItens: 0,
    totalPaginas: 0,
  });
  readonly edicoes = signal<PaginaResposta<EdicaoComicVine> | null>(null);
  readonly volumeSelecionado = signal<VolumeComicVine | null>(null);
  readonly paginaEdicoes = signal(0);
  readonly mensagem = signal('');

  termo = 'Amazing Spider-Man';

  buscarVolumes() {
    this.mensagem.set('');
    this.api.buscarVolumesComicVine(this.termo, 0, 12).subscribe({
      next: (resposta) => this.volumes.set(resposta),
      error: () => this.mensagem.set('Não foi possível buscar volumes na ComicVine.'),
    });
  }

  selecionarVolume(volume: VolumeComicVine) {
    this.volumeSelecionado.set(volume);
    this.paginaEdicoes.set(0);
    this.carregarEdicoes();
  }

  mudarPagina(delta: number) {
    this.paginaEdicoes.update((pagina) => Math.max(0, pagina + delta));
    this.carregarEdicoes();
  }

  carregarEdicoes() {
    const volume = this.volumeSelecionado();
    if (!volume) {
      return;
    }

    this.api.buscarEdicoesComicVine(volume.idExterno, this.paginaEdicoes(), 24).subscribe({
      next: (resposta) => this.edicoes.set(resposta),
      error: () => this.mensagem.set('Não foi possível carregar as edições deste volume.'),
    });
  }

  limitarTexto(texto: string | null, limite: number) {
    if (!texto) {
      return 'Sem descrição disponível.';
    }

    return texto.length > limite ? `${texto.slice(0, limite)}...` : texto;
  }

  listarCreditos(edicao: EdicaoComicVine) {
    return edicao.creditos
      .slice(0, 3)
      .map((credito) => [credito.nome, credito.papel].filter(Boolean).join(' · '))
      .join(' / ');
  }
}
