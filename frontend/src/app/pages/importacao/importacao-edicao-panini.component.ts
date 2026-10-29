import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';

import { ApiService } from '../../core/api.service';
import {
  CandidatoEdicaoOriginalPanini,
  Edicao,
  PreviaConteudoOriginalPanini,
  Serie,
} from '../../core/modelos';

@Component({
  selector: 'app-importacao-edicao-panini',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="fluxo-panini-edicao">
      <ol class="etapas-panini" aria-label="Etapas da importação">
        <li [class.ativa]="etapa() === 'inicio' || etapa() === 'revisao'" [class.concluida]="etapa() === 'vinculos' || etapa() === 'concluido'">1. Produto e coleção</li>
        <li [class.ativa]="etapa() === 'vinculos'" [class.concluida]="etapa() === 'concluido'">2. Conteúdo original</li>
        <li [class.ativa]="etapa() === 'concluido'">3. Conclusão</li>
      </ol>

      @if (etapa() === 'inicio' || etapa() === 'revisao') {
        <aside class="dica-importacao-colaborador">
          <strong>Cadastro independente do Guia dos Quadrinhos</strong>
          <p>A página oficial da Panini fornece os dados do produto. Você escolhe a coleção já cadastrada antes de criar a edição.</p>
        </aside>
        <div class="importacao-panini-url">
          <label>
            URL oficial do produto na Panini
            <input [(ngModel)]="urlProduto" name="urlProdutoPaniniImportacao" type="url" placeholder="https://panini.com.br/..." (keyup.enter)="analisarProduto()" />
          </label>
          <button class="botao secundario" type="button" (click)="analisarProduto()" [disabled]="analisando() || !urlProduto.trim()">
            {{ analisando() ? 'Lendo produto...' : 'Preparar cadastro' }}
          </button>
        </div>

        @if (previa(); as produtoPrevia) {
          <form class="grade-formulario cadastro-panini-previa" (ngSubmit)="cadastrarEdicao()">
            @if (produtoPrevia.produto?.urlCapa) {
              <figure class="campo-largo">
                <img [src]="produtoPrevia.produto!.urlCapa" [alt]="'Capa de ' + (produtoPrevia.tituloProduto || formulario.tituloEdicao)" loading="lazy" />
                <figcaption>Capa oficial encontrada na Panini; uma cópia será armazenada no Coleciona HQ.</figcaption>
              </figure>
            }

            <fieldset class="campo-largo seletor-colecao-panini">
              <legend>Coleção de destino</legend>
              <p class="texto-suave">Confirme título, editora e volume. O vínculo será feito pelo ID da coleção.</p>
              @if (!criarNovaColecao()) {
                <div class="importacao-panini-url">
                  <label>
                    Pesquisar coleção cadastrada
                    <input [(ngModel)]="buscaColecao" name="buscaColecaoPaniniImportacao" placeholder="Ex.: Saga dos X-Men" (keyup.enter)="buscarColecoes(); $event.preventDefault()" />
                  </label>
                  <button class="botao secundario" type="button" (click)="buscarColecoes()" [disabled]="buscandoColecoes() || !buscaColecao.trim()">
                    {{ buscandoColecoes() ? 'Pesquisando...' : 'Pesquisar' }}
                  </button>
                </div>
                @if (colecaoSelecionada(); as colecao) {
                  <div class="colecao-panini-selecionada">
                    <span>Coleção selecionada</span>
                    <strong>{{ colecao.titulo }}</strong>
                    <small>{{ colecao.editora?.nome || 'Sem editora' }} · V{{ colecao.volume || '—' }} · ID {{ colecao.id }}</small>
                  </div>
                }
                @if (colecoes().length) {
                  <div class="resultados-colecao-panini" role="radiogroup" aria-label="Coleções encontradas">
                    @for (colecao of colecoes(); track colecao.id) {
                      <label [class.selecionada]="colecaoSelecionada()?.id === colecao.id">
                        <input type="radio" name="colecaoDestinoPaniniImportacao" [checked]="colecaoSelecionada()?.id === colecao.id" (change)="colecaoSelecionada.set(colecao)" />
                        <span><strong>{{ colecao.titulo }}</strong><small>{{ colecao.editora?.nome || 'Sem editora' }} · V{{ colecao.volume || '—' }} · ID {{ colecao.id }}</small></span>
                      </label>
                    }
                  </div>
                } @else if (colecoesConsultadas() && !buscandoColecoes()) {
                  <p class="texto-suave">Nenhuma coleção brasileira encontrada com esse termo.</p>
                }
                <button class="botao-link" type="button" (click)="usarNovaColecao(true)">A coleção ainda não existe — criar uma nova</button>
              } @else {
                <div class="aviso-criacao-colecao"><strong>Nova coleção da Panini</strong><p>Use somente quando ela realmente não existir no catálogo.</p></div>
                <div class="grade-formulario grade-colecao-panini">
                  <label>Título da coleção<input [(ngModel)]="formulario.tituloSerie" name="tituloNovaColecaoPanini" required /></label>
                  <label>Volume<input [(ngModel)]="formulario.volumeSerie" name="volumeNovaColecaoPanini" type="number" min="1" placeholder="Ex.: 2" /></label>
                  <label>Editora<input value="Panini" disabled /></label>
                </div>
                <button class="botao-link" type="button" (click)="usarNovaColecao(false)">Voltar e selecionar uma coleção existente</button>
              }
            </fieldset>

            <label>Número da edição<input [(ngModel)]="formulario.numero" name="numeroEdicaoPaniniImportacao" required />
              @if (produtoPrevia.produto?.numeroAlternativo) { <small>A Panini também exibe o ordinal {{ produtoPrevia.produto!.numeroAlternativo }}.</small> }
            </label>
            <label class="campo-largo">Título do produto<input [(ngModel)]="formulario.tituloEdicao" name="tituloEdicaoPaniniImportacao" /></label>
            <label>Data de publicação<input [(ngModel)]="formulario.dataPublicacao" name="dataEdicaoPaniniImportacao" type="date" /></label>
            <label>ISBN<input [(ngModel)]="formulario.codigoBarras" name="isbnEdicaoPaniniImportacao" /></label>
            <label>Páginas<input [(ngModel)]="formulario.quantidadePaginas" name="paginasEdicaoPaniniImportacao" type="number" min="1" /></label>
            <label>Preço de capa<input [(ngModel)]="formulario.precoCapa" name="precoEdicaoPaniniImportacao" type="number" min="0" step="0.01" /></label>
            <label>Formato<input [(ngModel)]="formulario.formato" name="formatoEdicaoPaniniImportacao" /></label>
            <label class="campo-largo">Descrição<textarea [(ngModel)]="formulario.descricao" name="descricaoEdicaoPaniniImportacao" rows="5"></textarea></label>
            <aside class="campo-largo importacao-panini-fonte">
              <strong>Dados oficiais capturados</strong>
              <span>SKU {{ produtoPrevia.produto?.sku || '—' }} · {{ produtoPrevia.produto?.marca || 'Marca não informada' }}</span>
              @if (produtoPrevia.conteudoOriginalBruto) { <p><strong>Conteúdo original:</strong> {{ produtoPrevia.conteudoOriginalBruto }}</p> }
            </aside>
            <div class="campo-largo acoes-formulario">
              <button class="botao primario" type="submit" [disabled]="cadastrando() || !destinoValido() || !formulario.numero.trim()">
                {{ cadastrando() ? 'Cadastrando edição e capa...' : 'Cadastrar edição e continuar' }}
              </button>
            </div>
          </form>
        }
      }

      @if (etapa() === 'vinculos' && previa(); as produtoPrevia) {
        <section class="vinculos-panini-etapa">
          <header>
            <div><p class="rotulo">Edição brasileira cadastrada</p><h3>{{ tituloEdicaoCadastrada() }}</h3></div>
            <span>ID {{ edicaoCadastrada()?.id }}</span>
          </header>
          <p class="texto-suave">As referências ausentes estão sendo procuradas em lote na Comic Vine. Revise os casos ambíguos antes de concluir.</p>
          <aside class="importacao-panini-fonte"><strong>{{ produtoPrevia.tituloProduto || 'Produto Panini' }}</strong><p>{{ produtoPrevia.conteudoOriginalBruto }}</p></aside>
          <div class="importacao-panini-referencias">
            @for (referencia of produtoPrevia.referencias; track referencia.indice) {
              <article [class.resolvida]="!!idSelecionado(referencia.indice)">
                <header><div><span>Referência {{ referencia.indice + 1 }}</span><strong>{{ referencia.textoOriginal }}</strong></div><em>{{ rotuloStatus(referencia.statusResolucao) }}</em></header>
                <p>{{ referencia.serie || 'Série não interpretada' }}<ng-container *ngIf="referencia.numero"> #{{ referencia.numero }}</ng-container><span *ngIf="referencia.anoSerie"> · série de {{ referencia.anoSerie }}</span></p>
                <label>Edição estrangeira confirmada
                  @if (referencia.candidatos.length) {
                    <select [ngModel]="idSelecionado(referencia.indice)" (ngModelChange)="selecionarEdicao(referencia.indice, $event)" [name]="'originalPaniniImportacao' + referencia.indice">
                      <option [ngValue]="null">Selecione uma edição</option>
                      @for (candidato of referencia.candidatos; track candidato.id) { <option [ngValue]="candidato.id">ID {{ candidato.id }} · {{ candidato.serie }} #{{ candidato.numero }} · {{ candidato.editora }}</option> }
                    </select>
                  } @else {
                    <input type="number" min="1" [ngModel]="idSelecionado(referencia.indice)" (ngModelChange)="selecionarEdicao(referencia.indice, $event)" [name]="'originalPaniniImportacao' + referencia.indice" placeholder="ID no catálogo estrangeiro" />
                    @if (referencia.serie && referencia.numero) {
                      <button class="botao secundario compacto" type="button" (click)="cadastrarOriginal(referencia)" [disabled]="resolvendoOriginais() || !!cadastrandoOriginais().size">{{ cadastrandoOriginais().has(referencia.indice) ? 'Buscando...' : 'Buscar pela Comic Vine' }}</button>
                    }
                  }
                  @if (errosOriginais()[referencia.indice]) { <small class="erro-original-panini">{{ errosOriginais()[referencia.indice] }}</small> }
                </label>
              </article>
            }
          </div>
          @if (progressoOriginais(); as progresso) { <p class="texto-suave">Resolvendo {{ progresso.atual }} de {{ progresso.total }} referência(s)...</p> }
          <div class="acoes-formulario conclusao-vinculos-panini">
            <span>{{ quantidadeSelecionada() }} de {{ produtoPrevia.referencias.length }} referência(s) selecionada(s)</span>
            <button class="botao secundario" type="button" (click)="concluirSemVinculos()" [disabled]="salvandoVinculos() || resolvendoOriginais()">Concluir sem confirmar vínculos</button>
            <button class="botao primario" type="button" (click)="confirmarVinculos()" [disabled]="salvandoVinculos() || resolvendoOriginais() || !quantidadeSelecionada()">{{ salvandoVinculos() ? 'Confirmando...' : 'Confirmar vínculos e concluir' }}</button>
          </div>
        </section>
      }

      @if (etapa() === 'concluido') {
        <section class="resultado-panini-concluido">
          <span class="resultado-panini-icone">✓</span>
          <div><p class="rotulo">Importação concluída</p><h3>{{ tituloEdicaoCadastrada() }}</h3><p>{{ resumoConclusao() }}</p></div>
          <div class="acoes-formulario">
            <button class="botao primario" type="button" (click)="novaImportacao()">Cadastrar outra edição</button>
            <a class="botao secundario" [routerLink]="['/edicoes', edicaoCadastrada()!.id]">Ver edição cadastrada</a>
          </div>
        </section>
      }

      @if (mensagem()) { <p class="mensagem-panini-fluxo" [class.erro]="mensagemErro()" role="status">{{ mensagem() }}</p> }
    </section>
  `,
  styles: [`
    :host { display: block; }
    .fluxo-panini-edicao { display: grid; gap: 18px; }
    .etapas-panini { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin: 0; padding: 0; list-style: none; counter-reset: none; }
    .etapas-panini li { padding: 10px 12px; border: 1px solid var(--borda); border-radius: 9px; color: var(--texto-suave); font-size: .86rem; font-weight: 750; }
    .etapas-panini li.ativa { border-color: var(--marca); color: var(--texto); background: var(--marca-suave); }
    .etapas-panini li.concluida { border-color: var(--verde); color: var(--verde); }
    .cadastro-panini-previa { margin-top: 4px; }
    .vinculos-panini-etapa, .resultado-panini-concluido { display: grid; gap: 16px; padding: 18px; border: 1px solid var(--borda); border-radius: 14px; background: var(--superficie); }
    .vinculos-panini-etapa > header { display: flex; justify-content: space-between; gap: 16px; align-items: start; }
    .vinculos-panini-etapa h3, .resultado-panini-concluido h3 { margin: 3px 0; }
    .conclusao-vinculos-panini { align-items: center; }
    .resultado-panini-concluido { grid-template-columns: auto minmax(0, 1fr); align-items: center; }
    .resultado-panini-concluido .acoes-formulario { grid-column: 1 / -1; }
    .resultado-panini-icone { display: grid; place-items: center; width: 48px; height: 48px; border-radius: 50%; color: white; background: var(--verde); font-size: 1.5rem; font-weight: 900; }
    .mensagem-panini-fluxo { margin: 0; padding: 11px 13px; border-radius: 9px; background: var(--marca-suave); }
    .mensagem-panini-fluxo.erro { color: var(--vermelho); background: color-mix(in srgb, var(--vermelho) 10%, transparent); }
    @media (max-width: 720px) { .etapas-panini { grid-template-columns: 1fr; } .resultado-panini-concluido { grid-template-columns: 1fr; } }
  `],
})
export class ImportacaoEdicaoPaniniComponent {
  private readonly api = inject(ApiService);

  readonly etapa = signal<'inicio' | 'revisao' | 'vinculos' | 'concluido'>('inicio');
  readonly analisando = signal(false);
  readonly cadastrando = signal(false);
  readonly previa = signal<PreviaConteudoOriginalPanini | null>(null);
  readonly buscandoColecoes = signal(false);
  readonly colecoesConsultadas = signal(false);
  readonly colecoes = signal<Serie[]>([]);
  readonly colecaoSelecionada = signal<Serie | null>(null);
  readonly criarNovaColecao = signal(false);
  readonly edicaoCadastrada = signal<Edicao | null>(null);
  readonly selecoes = signal<Record<number, number | null>>({});
  readonly errosOriginais = signal<Record<number, string>>({});
  readonly cadastrandoOriginais = signal<Set<number>>(new Set());
  readonly resolvendoOriginais = signal(false);
  readonly progressoOriginais = signal<{ atual: number; total: number } | null>(null);
  readonly salvandoVinculos = signal(false);
  readonly quantidadeSelecionada = computed(() => Object.values(this.selecoes()).filter(Boolean).length);
  readonly mensagem = signal('');
  readonly mensagemErro = signal(false);
  readonly resumoConclusao = signal('Edição cadastrada e pronta para consulta.');

  urlProduto = '';
  buscaColecao = '';
  formulario = this.formularioVazio();

  analisarProduto() {
    const url = this.urlProduto.trim();
    if (!url) return;
    this.analisando.set(true);
    this.limparMensagem();
    this.previa.set(null);
    this.colecoes.set([]);
    this.colecaoSelecionada.set(null);
    this.criarNovaColecao.set(false);
    this.api.analisarConteudoOriginalPanini(url).subscribe({
      next: (previa) => {
        const produto = previa.produto;
        if (!produto?.sku) {
          this.definirErro('A página não informou um SKU de produto válido.');
          this.analisando.set(false);
          return;
        }
        this.previa.set(previa);
        this.urlProduto = previa.urlPanini;
        this.formulario = {
          tituloSerie: produto.tituloSerieSugerido || '', volumeSerie: null,
          numero: produto.numeroSugerido || '', tituloEdicao: previa.tituloProduto || '',
          descricao: produto.descricao || '', dataPublicacao: produto.dataDisponibilidade || '',
          codigoBarras: produto.isbn || '', quantidadePaginas: produto.quantidadePaginas,
          precoCapa: produto.preco, formato: produto.formato || '',
        };
        this.buscaColecao = produto.tituloSerieSugerido || '';
        this.etapa.set('revisao');
        this.analisando.set(false);
        if (this.buscaColecao) this.buscarColecoes();
      },
      error: (erro) => { this.analisando.set(false); this.definirErro(this.erroHttp(erro, 'Não foi possível ler este produto da Panini.')); },
    });
  }

  buscarColecoes() {
    const termo = this.buscaColecao.trim();
    if (!termo) return;
    this.buscandoColecoes.set(true);
    this.colecoesConsultadas.set(false);
    this.api.listarSeries(termo, 0, 20, '', 'BRASILEIRA').subscribe({
      next: (resposta) => { this.colecoes.set(resposta.itens); this.colecoesConsultadas.set(true); this.buscandoColecoes.set(false); },
      error: () => { this.colecoes.set([]); this.colecoesConsultadas.set(true); this.buscandoColecoes.set(false); this.definirErro('Não foi possível pesquisar as coleções.'); },
    });
  }

  usarNovaColecao(criar: boolean) {
    this.criarNovaColecao.set(criar);
    if (criar) this.colecaoSelecionada.set(null);
  }

  destinoValido() {
    return this.criarNovaColecao() ? !!this.formulario.tituloSerie.trim() : !!this.colecaoSelecionada();
  }

  cadastrarEdicao() {
    const previa = this.previa();
    if (!previa || !this.destinoValido() || !this.formulario.numero.trim()) return;
    const colecao = this.colecaoSelecionada();
    this.cadastrando.set(true);
    this.limparMensagem();
    this.api.cadastrarEdicaoBrasileiraPanini({
      urlPanini: previa.urlPanini,
      serieId: colecao?.id || null,
      criarNovaSerie: this.criarNovaColecao(),
      tituloSerie: this.criarNovaColecao() ? this.formulario.tituloSerie.trim() : null,
      volumeSerie: this.criarNovaColecao() ? this.numeroOuNull(this.formulario.volumeSerie) : null,
      numero: this.formulario.numero.trim(),
      tituloEdicao: this.formulario.tituloEdicao.trim() || null,
      descricao: this.formulario.descricao.trim() || null,
      dataPublicacao: this.formulario.dataPublicacao || null,
      codigoBarras: this.formulario.codigoBarras.trim() || null,
      quantidadePaginas: this.numeroOuNull(this.formulario.quantidadePaginas),
      precoCapa: this.numeroOuNull(this.formulario.precoCapa),
      formato: this.formulario.formato.trim() || null,
    }).subscribe({
      next: (resultado) => {
        this.cadastrando.set(false);
        this.edicaoCadastrada.set(resultado.edicao);
        if (!previa.referencias.length) {
          this.resumoConclusao.set('Edição cadastrada. A Panini não informou referências estrangeiras para confirmar.');
          this.etapa.set('concluido');
          return;
        }
        const selecoes = previa.referencias.reduce<Record<number, number | null>>((mapa, referencia) => {
          mapa[referencia.indice] = referencia.candidatos.length === 1 ? referencia.candidatos[0].id : null;
          return mapa;
        }, {});
        this.selecoes.set(selecoes);
        this.etapa.set('vinculos');
        void this.resolverOriginaisAutomaticamente();
      },
      error: (erro) => { this.cadastrando.set(false); this.definirErro(this.erroHttp(erro, 'Não foi possível cadastrar esta edição.')); },
    });
  }

  idSelecionado(indice: number) { return this.selecoes()[indice] ?? null; }

  selecionarEdicao(indice: number, valor: number | string | null) {
    this.selecoes.update((atual) => ({ ...atual, [indice]: this.numeroOuNull(valor) }));
  }

  rotuloStatus(status: string) {
    if (status === 'ENCONTRADA') return 'Correspondência exata';
    if (status === 'AMBIGUA') return 'Requer escolha';
    if (status === 'NAO_INTERPRETADA') return 'Requer conferência';
    return 'Não encontrada no catálogo';
  }

  async resolverOriginaisAutomaticamente() {
    const previa = this.previa();
    if (!previa || this.resolvendoOriginais()) return;
    const pendentes = previa.referencias.filter((item) => !item.candidatos.length && !!item.serie && !!item.numero);
    if (!pendentes.length) return;
    this.resolvendoOriginais.set(true);
    this.progressoOriginais.set({ atual: 0, total: pendentes.length });
    try {
      const resultado = await firstValueFrom(this.api.cadastrarEdicoesOriginaisPanini({
        urlPanini: previa.urlPanini,
        referencias: pendentes.map((item) => ({ indice: item.indice, serie: item.serie!, anoSerie: item.anoSerie, numero: item.numero! })),
      }));
      let atual = 0;
      for (const item of resultado.resultados) {
        atual++;
        this.progressoOriginais.set({ atual, total: pendentes.length });
        if (item.candidato) {
          this.incluirCandidato(item.indice, item.candidato);
        } else {
          this.errosOriginais.update((erros) => ({ ...erros, [item.indice]: item.erro || 'Correspondência única não encontrada.' }));
        }
      }
    } catch (erro) {
      this.definirErro(this.erroHttp(erro, 'Não foi possível resolver as referências em lote.'));
    } finally {
      this.progressoOriginais.set(null);
      this.resolvendoOriginais.set(false);
    }
  }

  async cadastrarOriginal(referencia: PreviaConteudoOriginalPanini['referencias'][number]) {
    const previa = this.previa();
    if (!previa || !referencia.serie || !referencia.numero) return;
    this.cadastrandoOriginais.update((itens) => new Set(itens).add(referencia.indice));
    try {
      const candidato = await firstValueFrom(this.api.cadastrarEdicaoOriginalPanini({
        urlPanini: previa.urlPanini, serie: referencia.serie,
        anoSerie: referencia.anoSerie, numero: referencia.numero,
      }));
      this.incluirCandidato(referencia.indice, candidato);
    } catch (erro) {
      this.errosOriginais.update((erros) => ({ ...erros, [referencia.indice]: this.erroHttp(erro, 'Correspondência única não encontrada.') }));
    } finally {
      this.cadastrandoOriginais.update((itens) => { const novos = new Set(itens); novos.delete(referencia.indice); return novos; });
    }
  }

  confirmarVinculos() {
    const previa = this.previa();
    const edicao = this.edicaoCadastrada();
    if (!previa || !edicao) return;
    const vinculos = previa.referencias
      .map((referencia) => ({ edicaoOriginalId: this.idSelecionado(referencia.indice), referenciaOriginal: referencia.textoOriginal }))
      .filter((item): item is { edicaoOriginalId: number; referenciaOriginal: string } => !!item.edicaoOriginalId);
    if (!vinculos.length) return;
    this.salvandoVinculos.set(true);
    this.api.cadastrarConteudoOriginalPanini({ edicaoBrasileiraId: edicao.id, urlPanini: previa.urlPanini, vinculos }).subscribe({
      next: (resultado) => {
        this.salvandoVinculos.set(false);
        this.resumoConclusao.set(`${resultado.cadastrados} vínculo(s) confirmado(s).${resultado.jaExistentes ? ` ${resultado.jaExistentes} já existiam.` : ''}`);
        this.etapa.set('concluido');
      },
      error: (erro) => { this.salvandoVinculos.set(false); this.definirErro(this.erroHttp(erro, 'Não foi possível confirmar os vínculos.')); },
    });
  }

  concluirSemVinculos() {
    this.resumoConclusao.set('Edição cadastrada. Os vínculos estrangeiros ficaram pendentes para revisão posterior.');
    this.etapa.set('concluido');
  }

  novaImportacao() {
    this.etapa.set('inicio');
    this.urlProduto = '';
    this.buscaColecao = '';
    this.formulario = this.formularioVazio();
    this.previa.set(null);
    this.colecoes.set([]);
    this.colecoesConsultadas.set(false);
    this.colecaoSelecionada.set(null);
    this.criarNovaColecao.set(false);
    this.edicaoCadastrada.set(null);
    this.selecoes.set({});
    this.errosOriginais.set({});
    this.resumoConclusao.set('Edição cadastrada e pronta para consulta.');
    this.limparMensagem();
  }

  tituloEdicaoCadastrada() {
    const edicao = this.edicaoCadastrada();
    if (!edicao) return 'Edição Panini';
    return `${edicao.serie?.titulo || edicao.titulo || 'Edição'} #${edicao.numero}`;
  }

  private incluirCandidato(indice: number, candidato: CandidatoEdicaoOriginalPanini) {
    this.previa.update((atual) => atual ? {
      ...atual,
      referencias: atual.referencias.map((item) => item.indice === indice
        ? { ...item, candidatos: [candidato], statusResolucao: 'ENCONTRADA' as const } : item),
    } : atual);
    this.selecionarEdicao(indice, candidato.id);
    this.errosOriginais.update((erros) => ({ ...erros, [indice]: '' }));
  }

  private formularioVazio() {
    return { tituloSerie: '', volumeSerie: null as number | null, numero: '', tituloEdicao: '', descricao: '',
      dataPublicacao: '', codigoBarras: '', quantidadePaginas: null as number | null,
      precoCapa: null as number | null, formato: '' };
  }

  private numeroOuNull(valor: number | string | null | undefined) {
    if (valor === null || valor === undefined || valor === '') return null;
    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : null;
  }

  private erroHttp(erro: any, fallback: string) {
    return erro?.error?.mensagem || erro?.error?.message || fallback;
  }

  private definirErro(texto: string) { this.mensagemErro.set(true); this.mensagem.set(texto); }
  private limparMensagem() { this.mensagemErro.set(false); this.mensagem.set(''); }
}
