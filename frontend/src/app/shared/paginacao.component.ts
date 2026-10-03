import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-paginacao',
  standalone: true,
  imports: [CommonModule],
  template: `
    <nav class="paginacao-inteligente" [attr.aria-label]="rotulo">
      <button
        class="controle-paginacao"
        type="button"
        [disabled]="indisponivel || paginaAtual === 0"
        (click)="irPara(0)"
        aria-label="Ir para a primeira página"
        title="Primeira página"
      ><span aria-hidden="true">«</span><em>Primeira</em></button>

      <button
        class="controle-paginacao"
        type="button"
        [disabled]="indisponivel || paginaAtual === 0"
        (click)="irPara(paginaAtual - 1)"
        aria-label="Ir para a página anterior"
        title="Página anterior"
      ><span aria-hidden="true">‹</span><em>Anterior</em></button>

      <div class="paginas-numeradas" aria-label="Escolher página">
        @for (pagina of paginasVisiveis; track $index) {
          @if (pagina === null) {
            <span class="reticencias" aria-hidden="true">…</span>
          } @else {
            <button
              type="button"
              [class.atual]="pagina === paginaAtual"
              [disabled]="indisponivel"
              [attr.aria-current]="pagina === paginaAtual ? 'page' : null"
              [attr.aria-label]="'Ir para a página ' + (pagina + 1)"
              (click)="irPara(pagina)"
            >{{ pagina + 1 }}</button>
          }
        }
      </div>

      <label class="seletor-pagina-mobile">
        <span>Página</span>
        <select [value]="paginaAtual" [disabled]="indisponivel" (change)="selecionarPagina($event)" aria-label="Escolher página">
          @for (pagina of todasAsPaginas; track pagina) {
            <option [value]="pagina">{{ pagina + 1 }} de {{ totalPaginas }}</option>
          }
        </select>
      </label>

      <button
        class="controle-paginacao"
        type="button"
        [disabled]="indisponivel || paginaAtual >= totalPaginas - 1"
        (click)="irPara(paginaAtual + 1)"
        aria-label="Ir para a próxima página"
        title="Próxima página"
      ><em>Próxima</em><span aria-hidden="true">›</span></button>

      <button
        class="controle-paginacao"
        type="button"
        [disabled]="indisponivel || paginaAtual >= totalPaginas - 1"
        (click)="irPara(totalPaginas - 1)"
        aria-label="Ir para a última página"
        title="Última página"
      ><em>Última</em><span aria-hidden="true">»</span></button>

      <span class="resumo-paginacao" aria-live="polite">Página {{ paginaAtual + 1 }} de {{ totalPaginas }}</span>
    </nav>
  `,
  styles: `
    :host { display: block; width: 100%; }
    .paginacao-inteligente { display: flex; align-items: center; justify-content: center; flex-wrap: wrap; gap: 8px; width: 100%; padding: 8px 0; }
    button, select { font: inherit; }
    button { min-width: 40px; min-height: 40px; border: 1px solid var(--borda); border-radius: 10px; color: var(--texto); background: var(--superficie); cursor: pointer; font-weight: 800; }
    button:hover:not(:disabled), button:focus-visible { border-color: var(--marca); background: var(--marca-suave); }
    button:focus-visible, select:focus-visible { outline: 3px solid color-mix(in srgb, var(--marca) 35%, transparent); outline-offset: 2px; }
    button:disabled { cursor: default; opacity: .42; }
    .controle-paginacao { display: inline-flex; align-items: center; justify-content: center; gap: 5px; padding: 0 12px; }
    .controle-paginacao span { font-size: 1.25rem; line-height: 1; }
    .controle-paginacao em { font-size: .82rem; font-style: normal; }
    .paginas-numeradas { display: flex; align-items: center; gap: 5px; }
    .paginas-numeradas button.atual { border-color: var(--marca); color: #15191f; background: var(--marca); cursor: default; }
    .reticencias { display: grid; min-width: 24px; place-items: center; color: var(--texto-suave); font-weight: 900; }
    .seletor-pagina-mobile { display: none; }
    .resumo-paginacao { flex: 1 0 100%; color: var(--texto-suave); font-size: .8rem; text-align: center; }

    @media (max-width: 620px) {
      .paginacao-inteligente { display: grid; grid-template-columns: 44px 44px minmax(104px, 1fr) 44px 44px; gap: 6px; }
      .paginas-numeradas, .controle-paginacao em, .resumo-paginacao { display: none; }
      .controle-paginacao { width: 44px; min-width: 44px; min-height: 44px; padding: 0; border-radius: 11px; }
      .controle-paginacao span { font-size: 1.5rem; }
      .seletor-pagina-mobile { display: grid; gap: 2px; min-width: 0; color: var(--texto-suave); font-size: .68rem; font-weight: 800; text-align: center; }
      .seletor-pagina-mobile select { width: 100%; min-width: 0; min-height: 44px; padding: 0 8px; border: 1px solid var(--borda); border-radius: 11px; color: var(--texto); background: var(--superficie); font-weight: 850; text-align: center; }
    }

    @media (max-width: 360px) {
      .paginacao-inteligente { grid-template-columns: 42px 42px minmax(88px, 1fr) 42px 42px; gap: 4px; }
      .controle-paginacao { width: 42px; min-width: 42px; }
    }
  `,
})
export class PaginacaoComponent {
  @Input() paginaAtual = 0;
  @Input() totalPaginas = 1;
  @Input() carregando = false;
  @Input() rotulo = 'Navegação entre páginas';
  @Output() paginaChange = new EventEmitter<number>();

  get indisponivel() {
    return this.carregando || this.totalPaginas <= 1;
  }

  get todasAsPaginas() {
    return Array.from({ length: Math.max(0, this.totalPaginas) }, (_, pagina) => pagina);
  }

  get paginasVisiveis(): Array<number | null> {
    const total = Math.max(0, this.totalPaginas);
    if (total <= 7) return Array.from({ length: total }, (_, pagina) => pagina);
    if (this.paginaAtual <= 3) return [0, 1, 2, 3, 4, null, total - 1];
    if (this.paginaAtual >= total - 4) return [0, null, total - 5, total - 4, total - 3, total - 2, total - 1];
    return [0, null, this.paginaAtual - 1, this.paginaAtual, this.paginaAtual + 1, null, total - 1];
  }

  irPara(pagina: number) {
    if (this.carregando || pagina < 0 || pagina >= this.totalPaginas || pagina === this.paginaAtual) return;
    this.paginaChange.emit(pagina);
  }

  selecionarPagina(evento: Event) {
    this.irPara(Number((evento.target as HTMLSelectElement).value));
  }
}
