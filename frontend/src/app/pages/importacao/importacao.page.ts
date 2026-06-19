import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { ApiService } from '../../core/api.service';
import { ResultadoImportacaoCatalogo, Serie } from '../../core/modelos';

@Component({
  selector: 'app-importacao-page',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Importação</p>
        <h1>Importe para o catálogo os JSONs gerados pelo robô.</h1>
      </div>
    </section>

    <section class="importacao-layout">
      <article class="bloco painel-importacao">
        <div class="secao-titulo">
          <div>
            <h2>JSON do robô</h2>
            <p class="texto-suave">Carregue o arquivo gerado em rascunhos ou cole o conteúdo revisado.</p>
          </div>
        </div>

        <div class="acoes-importacao">
          <label class="botao secundario compacto seletor-arquivo">
            Selecionar JSON
            <input type="file" accept="application/json,.json" (change)="selecionarArquivo($event)" />
          </label>
          <button class="botao compacto" type="button" (click)="preencherExemploBatman()">
            Exemplo da Saga do Batman
          </button>
          <button class="botao compacto" type="button" (click)="limpar()">
            Limpar
          </button>
        </div>

        @if (nomeArquivo()) {
          <p class="texto-suave arquivo-selecionado">Arquivo selecionado: {{ nomeArquivo() }}</p>
        }

        <label class="campo-json">
          Conteúdo JSON
          <textarea
            [(ngModel)]="jsonTexto"
            name="jsonTexto"
            spellcheck="false"
            placeholder='Cole aqui o JSON gerado pelo robô, começando com { "origem": ... }'
          ></textarea>
        </label>

        @if (mensagem()) {
          <p class="mensagem-erro">{{ mensagem() }}</p>
        }

        <div class="rodape-importacao">
          <button class="botao primario" type="button" (click)="importar()" [disabled]="importando() || !jsonTexto.trim()">
            {{ importando() ? 'Importando...' : 'Importar para o catálogo' }}
          </button>
        </div>
      </article>

      <article class="bloco painel-resultado">
        <div class="secao-titulo">
          <div>
            <h2>Resultado</h2>
            <p class="texto-suave">Resumo do que entrou ou foi reaproveitado no catálogo.</p>
          </div>
        </div>

        <section class="ajuste-capa">
          <div>
            <h3>Atualizar capa no catálogo</h3>
            <p class="texto-suave">Corrija uma única capa já importada, sem reenviar o JSON inteiro.</p>
          </div>

          <label>
            Buscar série
            <input [(ngModel)]="buscaSerieCapa" name="buscaSerieCapa" placeholder="Ex.: Saga do Batman" />
          </label>

          <button class="botao compacto" type="button" (click)="buscarSeriesParaCapa()" [disabled]="buscandoSeriesCapa()">
            {{ buscandoSeriesCapa() ? 'Buscando...' : 'Buscar série' }}
          </button>

          @if (seriesCapa().length) {
            <div class="series-capa">
              @for (serie of seriesCapa(); track serie.id) {
                <button type="button" [class.ativo]="serieCapaSelecionada()?.id === serie.id" (click)="selecionarSerieCapa(serie)">
                  <strong>{{ serie.titulo }}</strong>
                  <span>{{ serie.editora?.nome || 'Sem editora' }} · V{{ serie.volume || '-' }}</span>
                </button>
              }
            </div>
          }

          <label>
            Número da edição
            <input [(ngModel)]="numeroEdicaoCapa" name="numeroEdicaoCapa" placeholder="Ex.: 1" />
          </label>

          <label>
            URL da capa correta
            <input [(ngModel)]="urlCapaManual" name="urlCapaManual" placeholder="https://..." />
          </label>

          @if (urlCapaManual.trim()) {
            <div class="previa-capa">
              <img [src]="urlCapaManual.trim()" alt="Prévia da capa informada" (error)="capaManualComErro()" />
              <span>Prévia</span>
            </div>
          }

          <button class="botao compacto" type="button" (click)="aplicarCapaManual()" [disabled]="!numeroEdicaoCapa.trim() || !urlCapaManual.trim()">
            Aplicar só no JSON carregado
          </button>

          <button
            class="botao primario compacto"
            type="button"
            (click)="atualizarCapaNoCatalogo()"
            [disabled]="!serieCapaSelecionada() || !numeroEdicaoCapa.trim() || !urlCapaManual.trim() || salvandoCapaCatalogo()"
          >
            {{ salvandoCapaCatalogo() ? 'Atualizando...' : 'Atualizar capa no catálogo' }}
          </button>
        </section>

        @if (resultado()) {
          <section class="resultado-destaque">
            <span>Série importada</span>
            <strong>{{ resultado()?.serieTitulo }}</strong>
            <a class="botao compacto" routerLink="/catalogo">Abrir no catálogo</a>
          </section>

          <div class="metricas-importacao">
            <div>
              <strong>{{ resultado()?.editorasCriadas }}</strong>
              <span>editoras criadas</span>
            </div>
            <div>
              <strong>{{ resultado()?.seriesCriadas }}</strong>
              <span>séries criadas</span>
            </div>
            <div>
              <strong>{{ resultado()?.edicoesCriadas }}</strong>
              <span>edições criadas</span>
            </div>
            <div>
              <strong>{{ resultado()?.edicoesAtualizadas }}</strong>
              <span>edições atualizadas</span>
            </div>
            <div>
              <strong>{{ resultado()?.historiasCriadas }}</strong>
              <span>histórias criadas</span>
            </div>
            <div>
              <strong>{{ resultado()?.conteudosCriados }}</strong>
              <span>conteúdos criados</span>
            </div>
            <div>
              <strong>{{ resultado()?.publicacoesCriadas }}</strong>
              <span>vínculos criados</span>
            </div>
            <div>
              <strong>{{ resultado()?.itensReaproveitados }}</strong>
              <span>itens reaproveitados</span>
            </div>
          </div>

          @if (resultado()?.avisos?.length) {
            <section class="avisos-importacao">
              <h3>Avisos</h3>
              @for (aviso of resultado()?.avisos || []; track aviso) {
                <p>{{ aviso }}</p>
              }
            </section>
          }
        } @else {
          <section class="estado-vazio compacto">
            <h2>Nenhuma importação executada</h2>
            <p>O resumo aparecerá aqui depois que o JSON for enviado ao backend.</p>
          </section>
        }
      </article>
    </section>
  `,
  styles: `
    .importacao-layout {
      display: grid;
      grid-template-columns: minmax(0, 1.4fr) minmax(320px, 0.8fr);
      gap: 18px;
      align-items: start;
    }

    .painel-importacao,
    .painel-resultado {
      display: grid;
      gap: 18px;
    }

    .acoes-importacao,
    .rodape-importacao {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      align-items: center;
    }

    .seletor-arquivo input {
      display: none;
    }

    .arquivo-selecionado {
      margin: -6px 0 0;
    }

    .campo-json {
      display: grid;
      gap: 8px;
      font-size: 0.9rem;
      color: var(--texto-suave);
    }

    .campo-json textarea {
      min-height: 420px;
      resize: vertical;
      font-family: 'JetBrains Mono', 'Cascadia Code', Consolas, monospace;
      font-size: 0.86rem;
      line-height: 1.5;
    }

    .resultado-destaque {
      display: grid;
      gap: 8px;
      padding: 14px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie-suave);
    }

    .resultado-destaque span {
      color: var(--texto-suave);
      font-size: 0.82rem;
    }

    .resultado-destaque strong {
      font-size: 1.2rem;
    }

    .ajuste-capa {
      display: grid;
      gap: 12px;
      padding: 14px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie-suave);
    }

    .ajuste-capa h3 {
      margin: 0 0 4px;
      font-size: 1rem;
    }

    .ajuste-capa p {
      margin: 0;
    }

    .ajuste-capa label {
      display: grid;
      gap: 6px;
      font-size: 0.88rem;
      color: var(--texto-suave);
    }

    .previa-capa {
      display: grid;
      grid-template-columns: 72px 1fr;
      gap: 10px;
      align-items: center;
    }

    .previa-capa img {
      width: 72px;
      aspect-ratio: 2 / 3;
      object-fit: cover;
      border-radius: 6px;
      background: var(--superficie);
      border: 1px solid var(--borda);
    }

    .previa-capa span {
      color: var(--texto-suave);
      font-size: 0.85rem;
    }

    .series-capa {
      display: grid;
      gap: 8px;
      max-height: 180px;
      overflow: auto;
    }

    .series-capa button {
      display: grid;
      gap: 2px;
      width: 100%;
      padding: 10px;
      text-align: left;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
      color: var(--texto);
      cursor: pointer;
    }

    .series-capa button.ativo {
      border-color: var(--primaria);
      background: rgba(37, 99, 235, 0.08);
    }

    .series-capa span {
      color: var(--texto-suave);
      font-size: 0.8rem;
    }

    .metricas-importacao {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
    }

    .metricas-importacao div {
      display: grid;
      gap: 4px;
      padding: 12px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
    }

    .metricas-importacao strong {
      font-size: 1.35rem;
    }

    .metricas-importacao span {
      color: var(--texto-suave);
      font-size: 0.82rem;
    }

    .avisos-importacao {
      display: grid;
      gap: 8px;
    }

    .avisos-importacao h3 {
      margin: 0;
      font-size: 1rem;
    }

    .avisos-importacao p {
      margin: 0;
      padding: 10px;
      border-radius: 8px;
      background: rgba(183, 121, 31, 0.12);
      color: #8a5b16;
    }

    @media (max-width: 900px) {
      .importacao-layout {
        grid-template-columns: 1fr;
      }

      .campo-json textarea {
        min-height: 320px;
      }
    }
  `,
})
export class ImportacaoPage {
  private readonly api = inject(ApiService);

  readonly resultado = signal<ResultadoImportacaoCatalogo | null>(null);
  readonly mensagem = signal('');
  readonly importando = signal(false);
  readonly nomeArquivo = signal('');
  readonly buscandoSeriesCapa = signal(false);
  readonly salvandoCapaCatalogo = signal(false);
  readonly seriesCapa = signal<Serie[]>([]);
  readonly serieCapaSelecionada = signal<Serie | null>(null);
  buscaSerieCapa = '';
  numeroEdicaoCapa = '';
  urlCapaManual = '';
  jsonTexto = '';

  selecionarArquivo(evento: Event) {
    const input = evento.target as HTMLInputElement;
    const arquivo = input.files?.[0];
    if (!arquivo) {
      return;
    }

    this.nomeArquivo.set(arquivo.name);
    const leitor = new FileReader();
    leitor.onload = () => {
      this.jsonTexto = String(leitor.result || '');
      this.mensagem.set('');
    };
    leitor.onerror = () => this.mensagem.set('Não foi possível ler o arquivo selecionado.');
    leitor.readAsText(arquivo, 'utf-8');
  }

  preencherExemploBatman() {
    this.jsonTexto = [
      '{',
      '  "origem": {',
      '    "url": "http://www.guiadosquadrinhos.com/edicao/saga-do-batman-a-1-serie-n-2/sa011126/159263"',
      '  },',
      '  "serieBrasileira": {',
      '    "titulo": "Saga do Batman, A",',
      '    "fase": "1ª Série",',
      '    "editora": "Panini",',
      '    "volume": 1',
      '  },',
      '  "edicoes": []',
      '}',
    ].join('\n');
    this.nomeArquivo.set('exemplo-estrutura.json');
    this.resultado.set(null);
    this.mensagem.set('Exemplo estrutural carregado. Para importar de verdade, selecione o JSON completo gerado pelo robô.');
  }

  importar() {
    this.mensagem.set('');
    this.resultado.set(null);

    let corpo: unknown;
    try {
      corpo = JSON.parse(this.jsonTexto);
    } catch {
      this.mensagem.set('O conteúdo informado não é um JSON válido.');
      return;
    }

    this.importando.set(true);
    this.api.importarCatalogo(corpo).subscribe({
      next: (resultado) => {
        this.resultado.set(resultado);
        this.importando.set(false);
      },
      error: (erro) => {
        this.importando.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Não foi possível importar o catálogo.');
      },
    });
  }

  aplicarCapaManual() {
    this.mensagem.set('');

    let corpo: { edicoes?: Array<{ numero?: string; urlCapa?: string }> };
    try {
      corpo = JSON.parse(this.jsonTexto);
    } catch {
      this.mensagem.set('Carregue um JSON válido antes de ajustar a capa.');
      return;
    }

    if (!Array.isArray(corpo.edicoes)) {
      this.mensagem.set('O JSON não possui a lista de edições.');
      return;
    }

    const numero = this.numeroEdicaoCapa.trim().toLowerCase();
    const edicao = corpo.edicoes.find((item) => String(item.numero || '').trim().toLowerCase() === numero);
    if (!edicao) {
      this.mensagem.set(`Não encontrei a edição nº ${this.numeroEdicaoCapa.trim()} neste JSON.`);
      return;
    }

    edicao.urlCapa = this.urlCapaManual.trim();
    this.jsonTexto = JSON.stringify(corpo, null, 2);
    this.mensagem.set(`Capa da edição nº ${this.numeroEdicaoCapa.trim()} atualizada no JSON.`);
  }

  capaManualComErro() {
    this.mensagem.set('A prévia da capa não carregou. Confira se a URL permite exibição fora do site de origem.');
  }

  buscarSeriesParaCapa() {
    const busca = this.buscaSerieCapa.trim();
    if (!busca) {
      this.mensagem.set('Informe o nome da série para buscar.');
      return;
    }

    this.mensagem.set('');
    this.buscandoSeriesCapa.set(true);
    this.api.listarSeries(busca, 0, 10).subscribe({
      next: (pagina) => {
        this.seriesCapa.set(pagina.itens);
        this.serieCapaSelecionada.set(pagina.itens[0] || null);
        this.buscandoSeriesCapa.set(false);
        if (!pagina.itens.length) {
          this.mensagem.set('Nenhuma série encontrada para atualizar capa.');
        }
      },
      error: (erro) => {
        this.buscandoSeriesCapa.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Não foi possível buscar séries.');
      },
    });
  }

  selecionarSerieCapa(serie: Serie) {
    this.serieCapaSelecionada.set(serie);
  }

  atualizarCapaNoCatalogo() {
    const serie = this.serieCapaSelecionada();
    if (!serie) {
      this.mensagem.set('Selecione a série antes de atualizar a capa.');
      return;
    }

    const numero = this.numeroEdicaoCapa.trim().toLowerCase();
    const urlCapa = this.urlCapaManual.trim();
    this.mensagem.set('');
    this.salvandoCapaCatalogo.set(true);

    this.api.listarEdicoes('', 0, 300, serie.id).subscribe({
      next: (pagina) => {
        const edicao = pagina.itens.find((item) => String(item.numero || '').trim().toLowerCase() === numero);
        if (!edicao) {
          this.salvandoCapaCatalogo.set(false);
          this.mensagem.set(`Não encontrei a edição nº ${this.numeroEdicaoCapa.trim()} na série selecionada.`);
          return;
        }

        this.api.atualizarCapaEdicao(edicao.id, urlCapa).subscribe({
          next: () => {
            this.salvandoCapaCatalogo.set(false);
            this.mensagem.set(`Capa da edição nº ${this.numeroEdicaoCapa.trim()} atualizada direto no catálogo.`);
          },
          error: (erro) => {
            this.salvandoCapaCatalogo.set(false);
            this.mensagem.set(erro?.error?.mensagem || 'Não foi possível atualizar a capa no catálogo.');
          },
        });
      },
      error: (erro) => {
        this.salvandoCapaCatalogo.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Não foi possível listar edições da série.');
      },
    });
  }

  limpar() {
    this.jsonTexto = '';
    this.nomeArquivo.set('');
    this.resultado.set(null);
    this.mensagem.set('');
    this.buscaSerieCapa = '';
    this.seriesCapa.set([]);
    this.serieCapaSelecionada.set(null);
    this.numeroEdicaoCapa = '';
    this.urlCapaManual = '';
  }
}
