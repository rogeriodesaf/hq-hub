import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { ContribuicaoCatalogo, EditoraResumo } from '../../core/modelos';

interface FormularioImportacaoRevisao {
  origemArquivoEntrada: string;
  origemUrl: string;
  serieTitulo: string;
  serieFase: string;
  serieEditora: string;
  serieVolume: number | null;
  edicaoNumero: string;
  edicaoTituloChamada: string;
  edicaoDataPublicacao: string;
  edicaoPublicadoTexto: string;
  edicaoEditora: string;
  edicaoLicenciador: string;
  edicaoCategoria: string;
  edicaoGenero: string;
  edicaoStatus: string;
  edicaoNumeroPaginas: number | null;
  edicaoFormato: string;
  edicaoPrecoCapa: number | null;
  edicaoUrlCapa: string;
  edicaoDescricao: string;
  edicaoCodigoBarras: string;
  historias: HistoriaImportacaoFormulario[];
}

interface HistoriaImportacaoFormulario {
  ordem: number | null;
  tituloPortugues: string;
  tituloOriginal: string;
  quantidadePaginas: number | null;
  resumo: string;
  publicacaoOriginal: PublicacaoOriginalFormulario;
}

interface PublicacaoOriginalFormulario {
  serieOriginal: string;
  numeroOriginal: string;
  anoOriginal: number | null;
  texto: string;
  urlOrigem: string;
  urlCapa: string;
  urlCompraAmazon: string;
}

@Component({
  selector: 'app-revisao-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Revisao</p>
        <h1>Pendencias enviadas por usuarios para checagem do catalogo.</h1>
      </div>
      <button class="botao compacto" type="button" (click)="carregar()" [disabled]="carregando()">
        {{ carregando() ? 'Atualizando...' : 'Atualizar' }}
      </button>
    </section>

    @if (mensagem()) {
      <p class="mensagem-erro">{{ mensagem() }}</p>
    }

    <section class="metricas-revisao">
      <article>
        <span>Pendentes</span>
        <strong>{{ pendentes().length }}</strong>
      </article>
      <article>
        <span>Novas edicoes</span>
        <strong>{{ pendentesCadastroManual().length }}</strong>
      </article>
    </section>

    <section class="lista-revisao">
      @for (contribuicao of pendentes(); track contribuicao.id) {
        <article class="bloco revisao-card">
          <div class="secao-titulo">
            <div>
              <p class="rotulo">{{ rotuloTipo(contribuicao) }}</p>
              <h2>{{ tituloEdicao(contribuicao) }}</h2>
            </div>
            <span>{{ contribuicao.usuario.nome }}</span>
          </div>

          <div class="grade-revisao">
            <div>
              <strong>serieBrasileira.titulo</strong>
              <span>{{ formulario(contribuicao).serieTitulo || 'Pendente' }}</span>
            </div>
            <div>
              <strong>serieBrasileira.editora</strong>
              <span>{{ formulario(contribuicao).serieEditora || 'Pendente' }}</span>
            </div>
            <div>
              <strong>edicoes[0].urlCapa</strong>
              <span>{{ formulario(contribuicao).edicaoUrlCapa ? 'Informada' : 'Pendente' }}</span>
            </div>
            <div>
              <strong>edicoes[0].formato</strong>
              <span>{{ formulario(contribuicao).edicaoFormato || 'Pendente' }}</span>
            </div>
            <div>
              <strong>origem.url</strong>
              <span>{{ formulario(contribuicao).origemUrl || 'Pendente' }}</span>
            </div>
          </div>

          @if (contribuicao.observacoes) {
            <p class="texto-suave">{{ contribuicao.observacoes }}</p>
          }

          <details open>
            <summary>Editor do JSON padrao de importacao</summary>
            <div class="editor-json-revisao">
              <label>
                origem.arquivoEntrada
                <input [(ngModel)]="formulario(contribuicao).origemArquivoEntrada" [name]="'origemArquivoEntrada' + contribuicao.id" />
              </label>
              <label>
                origem.url
                <input [(ngModel)]="formulario(contribuicao).origemUrl" [name]="'origemUrl' + contribuicao.id" />
              </label>

              <label>
                serieBrasileira.titulo
                <input [(ngModel)]="formulario(contribuicao).serieTitulo" [name]="'serieTitulo' + contribuicao.id" />
              </label>
              <label>
                serieBrasileira.fase
                <input [(ngModel)]="formulario(contribuicao).serieFase" [name]="'serieFase' + contribuicao.id" />
              </label>
              <label>
                serieBrasileira.editora
                <input [(ngModel)]="formulario(contribuicao).serieEditora" [name]="'serieEditora' + contribuicao.id" />
              </label>
              <label>
                serieBrasileira.volume
                <input type="number" min="1" [(ngModel)]="formulario(contribuicao).serieVolume" [name]="'serieVolume' + contribuicao.id" />
              </label>

              <label>
                edicoes[0].numero
                <input [(ngModel)]="formulario(contribuicao).edicaoNumero" [name]="'edicaoNumero' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].tituloChamada
                <input [(ngModel)]="formulario(contribuicao).edicaoTituloChamada" [name]="'edicaoTituloChamada' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].dataPublicacao
                <input type="date" [(ngModel)]="formulario(contribuicao).edicaoDataPublicacao" [name]="'edicaoDataPublicacao' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].publicadoTexto
                <input [(ngModel)]="formulario(contribuicao).edicaoPublicadoTexto" [name]="'edicaoPublicadoTexto' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].editora
                <input [(ngModel)]="formulario(contribuicao).edicaoEditora" [name]="'edicaoEditora' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].licenciador
                <input [(ngModel)]="formulario(contribuicao).edicaoLicenciador" [name]="'edicaoLicenciador' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].categoria
                <input [(ngModel)]="formulario(contribuicao).edicaoCategoria" [name]="'edicaoCategoria' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].genero
                <input [(ngModel)]="formulario(contribuicao).edicaoGenero" [name]="'edicaoGenero' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].status
                <input [(ngModel)]="formulario(contribuicao).edicaoStatus" [name]="'edicaoStatus' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].numeroPaginas
                <input type="number" min="1" [(ngModel)]="formulario(contribuicao).edicaoNumeroPaginas" [name]="'edicaoNumeroPaginas' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].formato
                <input [(ngModel)]="formulario(contribuicao).edicaoFormato" [name]="'edicaoFormato' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].precoCapa
                <input type="number" min="0" step="0.01" [(ngModel)]="formulario(contribuicao).edicaoPrecoCapa" [name]="'edicaoPrecoCapa' + contribuicao.id" />
              </label>
              <label class="campo-largo">
                edicoes[0].urlCapa
                <input [(ngModel)]="formulario(contribuicao).edicaoUrlCapa" [name]="'edicaoUrlCapa' + contribuicao.id" />
              </label>
              <label>
                edicoes[0].codigoBarras
                <input [(ngModel)]="formulario(contribuicao).edicaoCodigoBarras" [name]="'edicaoCodigoBarras' + contribuicao.id" />
              </label>
              <label class="campo-largo">
                Descricao da edicao
                <textarea rows="4" [(ngModel)]="formulario(contribuicao).edicaoDescricao" [name]="'edicaoDescricao' + contribuicao.id"></textarea>
              </label>
              <section class="campo-largo historias-revisao">
                <div class="secao-titulo compacta">
                  <div>
                    <p class="rotulo">Historias publicadas nesta edicao</p>
                    <span class="contador-historias">{{ totalHistoriasValidas(contribuicao) }} pronta(s) para importar</span>
                  </div>
                  <button class="botao compacto" type="button" (click)="adicionarHistoria(contribuicao)">+ Mais historia</button>
                </div>
                <p class="historia-ajuda">
                  Para aparecer no catalogo, cada historia precisa ter titulo em portugues, serie original e numero original.
                </p>

                @for (historia of formulario(contribuicao).historias; track $index; let indice = $index) {
                  <article class="historia-revisao">
                    <div class="secao-titulo compacta">
                      <strong>Historia {{ indice + 1 }}</strong>
                      <button
                        class="botao perigo compacto"
                        type="button"
                        (click)="removerHistoria(contribuicao, indice)"
                        [disabled]="formulario(contribuicao).historias.length === 1"
                      >
                        Remover
                      </button>
                    </div>

                    <div class="historia-grupos">
                      <fieldset>
                        <legend>Dados da historia</legend>
                        <div class="editor-json-revisao historia-campos">
                          <label>
                            Ordem
                            <input type="number" min="1" [(ngModel)]="historia.ordem" [name]="'historiaOrdem' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Titulo em portugues
                            <input [(ngModel)]="historia.tituloPortugues" [name]="'historiaTituloPortugues' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Titulo original
                            <input [(ngModel)]="historia.tituloOriginal" [name]="'historiaTituloOriginal' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Paginas
                            <input type="number" min="1" [(ngModel)]="historia.quantidadePaginas" [name]="'historiaQuantidadePaginas' + contribuicao.id + '-' + indice" />
                          </label>
                          <label class="campo-largo">
                            Resumo
                            <textarea rows="4" [(ngModel)]="historia.resumo" [name]="'historiaResumo' + contribuicao.id + '-' + indice"></textarea>
                          </label>
                        </div>
                      </fieldset>

                      <fieldset>
                        <legend>Publicacao original</legend>
                        <div class="editor-json-revisao historia-campos">
                          <label>
                            Serie original
                            <input [(ngModel)]="historia.publicacaoOriginal.serieOriginal" [name]="'historiaSerieOriginal' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Numero original
                            <input [(ngModel)]="historia.publicacaoOriginal.numeroOriginal" [name]="'historiaNumeroOriginal' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Ano original
                            <input type="number" min="1900" [(ngModel)]="historia.publicacaoOriginal.anoOriginal" [name]="'historiaAnoOriginal' + contribuicao.id + '-' + indice" />
                          </label>
                          <label>
                            Texto exibido
                            <input [(ngModel)]="historia.publicacaoOriginal.texto" [name]="'historiaTextoOriginal' + contribuicao.id + '-' + indice" />
                          </label>
                          <label class="campo-largo">
                            Link da fonte
                            <input [(ngModel)]="historia.publicacaoOriginal.urlOrigem" [name]="'historiaUrlOrigem' + contribuicao.id + '-' + indice" />
                          </label>
                          <label class="campo-largo">
                            URL da capa
                            <input [(ngModel)]="historia.publicacaoOriginal.urlCapa" [name]="'historiaUrlCapa' + contribuicao.id + '-' + indice" />
                          </label>
                          <label class="campo-largo">
                            Link Amazon
                            <input [(ngModel)]="historia.publicacaoOriginal.urlCompraAmazon" [name]="'historiaUrlCompraAmazon' + contribuicao.id + '-' + indice" />
                          </label>
                        </div>
                      </fieldset>
                    </div>

                    @if (mensagemHistoriaIncompleta(historia)) {
                      <p class="mensagem-historia">{{ mensagemHistoriaIncompleta(historia) }}</p>
                    }
                  </article>
                }
              </section>
            </div>
          </details>

          <details>
            <summary>Previa do JSON que sera importado</summary>
            <pre>{{ jsonPreview(contribuicao) }}</pre>
          </details>

          @if (contribuicao.dadosSugeridosJson) {
            <details>
              <summary>Dados enviados originalmente</summary>
              <pre>{{ formatarDados(contribuicao.dadosSugeridosJson) }}</pre>
            </details>
          }

          <label class="campo-revisao">
            Mensagem da revisao
            <input
              [(ngModel)]="mensagensRevisao[contribuicao.id]"
              [name]="'mensagemRevisao' + contribuicao.id"
              placeholder="Ex.: dados completos, faltam historias, fonte conferida..."
            />
          </label>

          <div class="acoes-revisao">
            <button class="botao compacto" type="button" (click)="salvarDadosCatalogo(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Salvar dados da edicao
            </button>
            <button class="botao primario compacto" type="button" (click)="importarJsonRevisado(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Importar edicao e historias
            </button>
            <button class="botao compacto" type="button" (click)="aprovar(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Marcar como checado
            </button>
            <button class="botao perigo compacto" type="button" (click)="recusar(contribuicao)" [disabled]="revisandoId() === contribuicao.id">
              Recusar
            </button>
          </div>
        </article>
      } @empty {
        <section class="estado-vazio">
          <h2>Nenhuma pendencia de catalogo</h2>
          <p>Quando alguem criar uma edicao pela estante ou sugerir dados, ela aparece aqui para revisao.</p>
        </section>
      }
    </section>
  `,
  styles: `
    .metricas-revisao {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 180px));
      gap: 12px;
      margin-bottom: 18px;
    }

    .metricas-revisao article,
    .grade-revisao div {
      display: grid;
      gap: 4px;
      padding: 12px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
    }

    .metricas-revisao span,
    .grade-revisao span {
      color: var(--texto-suave);
      font-size: 0.86rem;
      overflow-wrap: anywhere;
    }

    .metricas-revisao strong {
      font-size: 1.5rem;
    }

    .lista-revisao,
    .revisao-card {
      display: grid;
      gap: 14px;
    }

    .grade-revisao,
    .editor-json-revisao {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 10px;
    }

    .editor-json-revisao label,
    .campo-revisao {
      display: grid;
      gap: 6px;
      font-size: 0.88rem;
      color: var(--texto-suave);
    }

    .campo-largo {
      grid-column: 1 / -1;
    }

    .acoes-revisao {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    details {
      border: 1px solid var(--borda);
      border-radius: 8px;
      padding: 10px 12px;
      background: var(--superficie-suave);
    }

    summary {
      cursor: pointer;
      font-weight: 700;
    }

    pre {
      margin: 10px 0 0;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
      font-size: 0.82rem;
      color: var(--texto-suave);
    }

    textarea {
      resize: vertical;
    }

    .historias-revisao {
      display: grid;
      gap: 12px;
    }

    .historia-revisao {
      display: grid;
      gap: 12px;
      padding: 12px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
    }

    .historia-campos {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .historia-grupos {
      display: grid;
      gap: 12px;
    }

    .historia-grupos fieldset {
      display: grid;
      gap: 10px;
      margin: 0;
      padding: 12px;
      border: 1px solid var(--borda);
      border-radius: 8px;
    }

    .historia-grupos legend {
      padding: 0 6px;
      color: var(--texto);
      font-weight: 800;
    }

    .contador-historias {
      color: var(--texto-suave);
      font-size: 0.86rem;
      font-weight: 700;
    }

    .historia-ajuda {
      margin: -4px 0 0;
      color: var(--texto-suave);
      line-height: 1.45;
    }

    .mensagem-historia {
      margin: 0;
      padding: 10px 12px;
      border: 1px solid rgba(217, 65, 65, 0.28);
      border-radius: 8px;
      color: #8f2424;
      background: rgba(217, 65, 65, 0.08);
    }

    .secao-titulo.compacta {
      align-items: center;
      gap: 10px;
    }

    @media (max-width: 900px) {
      .metricas-revisao,
      .grade-revisao,
      .editor-json-revisao {
        grid-template-columns: 1fr;
      }

      .historia-campos {
        grid-template-columns: 1fr;
      }
    }
  `,
})
export class RevisaoPage implements OnInit {
  private readonly api = inject(ApiService);

  readonly pendentes = signal<ContribuicaoCatalogo[]>([]);
  readonly carregando = signal(false);
  readonly revisandoId = signal<number | null>(null);
  readonly mensagem = signal('');
  readonly pendentesCadastroManual = computed(() =>
    this.pendentes().filter((contribuicao) => contribuicao.fonteExterna === 'CADASTRO_USUARIO'),
  );
  mensagensRevisao: Record<number, string> = {};
  formularios: Record<number, FormularioImportacaoRevisao> = {};

  ngOnInit() {
    this.carregar();
  }

  carregar() {
    this.carregando.set(true);
    this.mensagem.set('');
    this.api.listarContribuicoesPendentes().subscribe({
      next: (pendentes) => {
        this.pendentes.set(pendentes);
        for (const contribuicao of pendentes) {
          this.formularios[contribuicao.id] = this.criarFormulario(contribuicao);
        }
        this.carregando.set(false);
      },
      error: (erro) => {
        this.carregando.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel carregar as pendencias.');
      },
    });
  }

  formulario(contribuicao: ContribuicaoCatalogo) {
    if (!this.formularios[contribuicao.id]) {
      this.formularios[contribuicao.id] = this.criarFormulario(contribuicao);
    }
    return this.formularios[contribuicao.id];
  }

  aprovar(contribuicao: ContribuicaoCatalogo) {
    this.revisar(contribuicao, 'aprovar');
  }

  recusar(contribuicao: ContribuicaoCatalogo) {
    this.revisar(contribuicao, 'recusar');
  }

  async salvarDadosCatalogo(contribuicao: ContribuicaoCatalogo) {
    const form = this.formulario(contribuicao);
    const serie = contribuicao.edicao.serie;
    if (!serie?.id || !serie.editora?.id) {
      this.mensagem.set('Nao foi possivel identificar a serie desta edicao.');
      return;
    }

    this.revisandoId.set(contribuicao.id);
    this.mensagem.set('');
    try {
      const editora = await this.obterOuCriarEditora(form.serieEditora || serie.editora.nome);
      await firstValueFrom(this.api.atualizarSerie(serie.id, {
        titulo: form.serieTitulo.trim(),
        descricao: this.textoOuNull(form.serieFase),
        anoInicio: null,
        anoFim: null,
        volume: this.numeroOuNull(form.serieVolume),
        ordemCronologica: this.numeroOuNull(form.serieVolume),
        fonteExterna: contribuicao.edicao.serie ? contribuicao.edicao.fonteExterna : null,
        idExterno: null,
        urlOrigem: this.textoOuNull(form.origemUrl),
        editoraId: editora.id,
      }));
      await firstValueFrom(this.api.atualizarEdicao(contribuicao.edicao.id, {
        numero: form.edicaoNumero.trim(),
        titulo: this.textoOuNull(form.edicaoTituloChamada),
        descricao: this.textoOuNull(form.edicaoDescricao),
        dataPublicacao: this.textoOuNull(form.edicaoDataPublicacao),
        urlCapa: this.textoOuNull(form.edicaoUrlCapa),
        codigoBarras: this.textoOuNull(form.edicaoCodigoBarras),
        quantidadePaginas: this.numeroOuNull(form.edicaoNumeroPaginas),
        precoCapa: this.numeroOuNull(form.edicaoPrecoCapa),
        formato: this.textoOuNull(form.edicaoFormato),
        fonteExterna: contribuicao.edicao.fonteExterna,
        idExterno: contribuicao.edicao.idExterno,
        urlOrigem: this.textoOuNull(form.origemUrl),
        serieId: serie.id,
      }));
      this.mensagem.set('Dados da edicao salvos no catalogo. Para criar historias e vinculos, use Importar edicao e historias.');
      this.carregar();
    } catch (erro) {
      this.mensagem.set(this.mensagemErro(erro, 'Nao foi possivel salvar os dados editoriais.'));
    } finally {
      this.revisandoId.set(null);
    }
  }

  async importarJsonRevisado(contribuicao: ContribuicaoCatalogo) {
    const form = this.formulario(contribuicao);
    if (this.historias(form).length === 0) {
      this.mensagem.set('Preencha pelo menos uma historia completa antes de importar. Campos obrigatorios: titulo em portugues, serie original e numero original.');
      return;
    }

    this.revisandoId.set(contribuicao.id);
    this.mensagem.set('');
    try {
      const resultado = await firstValueFrom(this.api.importarCatalogo(this.montarJsonImportacao(contribuicao)));
      this.mensagem.set(
        `JSON importado: ${resultado.edicoesCriadas} edicao(oes) criada(s), ${resultado.edicoesAtualizadas} atualizada(s), ${resultado.publicacoesCriadas} publicacao(oes).`,
      );
      this.carregar();
    } catch (erro) {
      this.mensagem.set(this.mensagemErro(erro, 'Nao foi possivel importar o JSON revisado.'));
    } finally {
      this.revisandoId.set(null);
    }
  }

  tituloEdicao(contribuicao: ContribuicaoCatalogo) {
    const serie = contribuicao.edicao.serie?.titulo || 'Edicao';
    const numero = contribuicao.edicao.numero ? ` #${contribuicao.edicao.numero}` : '';
    const titulo = contribuicao.edicao.titulo ? ` - ${contribuicao.edicao.titulo}` : '';
    return `${serie}${numero}${titulo}`;
  }

  rotuloTipo(contribuicao: ContribuicaoCatalogo) {
    if (contribuicao.fonteExterna === 'CADASTRO_USUARIO') {
      return 'Nova edicao criada na estante';
    }

    const rotulos: Record<string, string> = {
      CAPA_EDICAO: 'Sugestao de capa',
      DADOS_EDICAO: 'Dados da edicao',
      PUBLICACAO_BRASILEIRA: 'Publicacao brasileira',
      LINK_GUIA_DOS_QUADRINHOS: 'Link do Guia dos Quadrinhos',
      OUTRA_INFORMACAO: 'Outra informacao',
    };
    return rotulos[contribuicao.tipo] || contribuicao.tipo;
  }

  formatarDados(valor: string) {
    try {
      return JSON.stringify(JSON.parse(valor), null, 2);
    } catch {
      return valor;
    }
  }

  jsonPreview(contribuicao: ContribuicaoCatalogo) {
    return JSON.stringify(this.montarJsonImportacao(contribuicao), null, 2);
  }

  private criarFormulario(contribuicao: ContribuicaoCatalogo): FormularioImportacaoRevisao {
    const dados = this.dadosSugeridos(contribuicao);
    const edicao = contribuicao.edicao;
    const serie = edicao.serie;
    return {
      origemArquivoEntrada: dados?.['origem'] || `revisao-catalogo-${contribuicao.id}`,
      origemUrl: contribuicao.urlFonte || edicao.urlOrigem || dados?.['urlOrigem'] || '',
      serieTitulo: serie?.titulo || dados?.['serie'] || '',
      serieFase: '',
      serieEditora: serie?.editora?.nome || dados?.['editora'] || '',
      serieVolume: serie?.volume ?? dados?.['volume'] ?? null,
      edicaoNumero: edicao.numero || dados?.['numero'] || '',
      edicaoTituloChamada: edicao.titulo || dados?.['titulo'] || '',
      edicaoDataPublicacao: edicao.dataPublicacao || dados?.['dataPublicacao'] || '',
      edicaoPublicadoTexto: '',
      edicaoEditora: serie?.editora?.nome || dados?.['editora'] || '',
      edicaoLicenciador: '',
      edicaoCategoria: '',
      edicaoGenero: '',
      edicaoStatus: '',
      edicaoNumeroPaginas: edicao.quantidadePaginas,
      edicaoFormato: edicao.formato || dados?.['formato'] || '',
      edicaoPrecoCapa: edicao.precoCapa,
      edicaoUrlCapa: edicao.urlCapa || dados?.['urlCapa'] || '',
      edicaoDescricao: edicao.descricao || edicao.descricaoExibicao || '',
      edicaoCodigoBarras: edicao.codigoBarras || '',
      historias: [this.historiaVazia(1)],
    };
  }

  private montarJsonImportacao(contribuicao: ContribuicaoCatalogo) {
    const form = this.formulario(contribuicao);
    const historias = this.historias(form);
    return {
      origem: {
        arquivoEntrada: form.origemArquivoEntrada || `revisao-catalogo-${contribuicao.id}`,
        url: this.textoOuNull(form.origemUrl),
        urlsProcessadas: this.textoOuNull(form.origemUrl) ? [form.origemUrl.trim()] : [],
        geradoEm: new Date().toISOString().slice(0, 10),
        gerador: 'Revisao HQ-HUB',
      },
      serieBrasileira: {
        titulo: form.serieTitulo.trim(),
        fase: this.textoOuNull(form.serieFase),
        editora: form.serieEditora.trim(),
        volume: this.numeroOuNull(form.serieVolume),
      },
      totalEdicoes: 1,
      totalHistorias: historias.length,
      avisos: contribuicao.observacoes ? [contribuicao.observacoes] : [],
      edicoes: [
        {
          numero: form.edicaoNumero.trim(),
          tituloChamada: this.textoOuNull(form.edicaoTituloChamada),
          dataPublicacao: this.textoOuNull(form.edicaoDataPublicacao),
          publicadoTexto: this.textoOuNull(form.edicaoPublicadoTexto),
          editora: this.textoOuNull(form.edicaoEditora),
          licenciador: this.textoOuNull(form.edicaoLicenciador),
          categoria: this.textoOuNull(form.edicaoCategoria),
          genero: this.textoOuNull(form.edicaoGenero),
          status: this.textoOuNull(form.edicaoStatus),
          numeroPaginas: this.numeroOuNull(form.edicaoNumeroPaginas),
          formato: this.textoOuNull(form.edicaoFormato),
          precoCapa: this.numeroOuNull(form.edicaoPrecoCapa),
          urlCapa: this.textoOuNull(form.edicaoUrlCapa),
          descricao: this.textoOuNull(form.edicaoDescricao),
          historias,
        },
      ],
    };
  }

  private historias(form: FormularioImportacaoRevisao) {
    return form.historias
      .map((historia, indice) => this.historiaParaJson(historia, indice + 1))
      .filter((historia) => !!historia);
  }

  totalHistoriasValidas(contribuicao: ContribuicaoCatalogo) {
    return this.historias(this.formulario(contribuicao)).length;
  }

  mensagemHistoriaIncompleta(historia: HistoriaImportacaoFormulario) {
    if (!this.historiaTemAlgumDado(historia) || this.historiaParaJson(historia, historia.ordem || 1)) {
      return '';
    }

    const faltando: string[] = [];
    if (!this.textoOuNull(historia.tituloPortugues)) {
      faltando.push('titulo em portugues');
    }
    if (!this.textoOuNull(historia.publicacaoOriginal.serieOriginal)) {
      faltando.push('serie original');
    }
    if (!this.textoOuNull(historia.publicacaoOriginal.numeroOriginal)) {
      faltando.push('numero original');
    }

    return faltando.length ? `Falta preencher: ${faltando.join(', ')}.` : '';
  }

  private historiaTemAlgumDado(historia: HistoriaImportacaoFormulario) {
    return [
      historia.tituloPortugues,
      historia.tituloOriginal,
      historia.resumo,
      historia.publicacaoOriginal.serieOriginal,
      historia.publicacaoOriginal.numeroOriginal,
      historia.publicacaoOriginal.texto,
      historia.publicacaoOriginal.urlOrigem,
      historia.publicacaoOriginal.urlCapa,
      historia.publicacaoOriginal.urlCompraAmazon,
    ].some((valor) => !!this.textoOuNull(valor))
      || this.numeroOuNull(historia.quantidadePaginas) !== null
      || this.numeroOuNull(historia.publicacaoOriginal.anoOriginal) !== null;
  }

  private historiasAPartirDeTextoGuia(texto: string) {
    const blocos = this.blocosHistoriasGuia(texto);
    return blocos
      .map((bloco, indice) => this.historiaAPartirDeBlocoGuia(bloco, indice + 1))
      .filter((historia) => !!historia);
  }

  private blocosHistoriasGuia(texto: string) {
    const linhas = texto
      .replace(/\r/g, '')
      .split('\n')
      .map((linha) => linha.trim())
      .filter(Boolean);

    const blocos: string[][] = [];
    let atual: string[] = [];

    for (const linha of linhas) {
      const novaHistoria = this.pareceTituloHistoria(linha) && atual.some((item) => this.ehLinhaPaginas(item));
      if (novaHistoria) {
        blocos.push(atual);
        atual = [linha];
        continue;
      }

      atual.push(linha);
    }

    if (atual.length) {
      blocos.push(atual);
    }

    return blocos;
  }

  private historiaAPartirDeBlocoGuia(linhas: string[], ordem: number) {
    const tituloPortugues = linhas[0]?.trim();
    const linhaOriginal = linhas.find((linha) => linha.toLocaleLowerCase('pt-BR').startsWith('título original:'));
    const linhaPublicacao = linhas.find((linha) => linha.toLocaleLowerCase('pt-BR').startsWith('publicada pela primeira vez em'));
    const linhaPaginas = linhas.find((linha) => this.ehLinhaPaginas(linha));

    if (!tituloPortugues || !linhaPublicacao) {
      return null;
    }

    const publicacaoOriginal = this.publicacaoOriginalAPartirDeLinha(linhaPublicacao);
    if (!publicacaoOriginal) {
      return null;
    }

    return {
      ordem,
      tituloPortugues,
      tituloOriginal: this.tituloOriginalAPartirDeLinha(linhaOriginal),
      quantidadePaginas: this.paginasAPartirDeLinha(linhaPaginas),
      resumo: this.resumoAPartirDeBloco(linhas),
      publicacaoOriginal,
    };
  }

  private publicacaoOriginalAPartirDeLinha(linha: string) {
    const texto = linha.replace(/^Publicada pela primeira vez em\s*/i, '').trim();
    const correspondencia = texto.match(/^(.*?)\s+n[°º]\s*([^/]+)\/(\d{4})(?:\s*-\s*(.*))?$/i);
    if (!correspondencia) {
      return null;
    }

    const serieOriginal = correspondencia[1]?.trim();
    const numeroOriginal = correspondencia[2]?.trim();
    const anoOriginal = Number(correspondencia[3]);

    return {
      serieOriginal,
      numeroOriginal,
      anoOriginal: Number.isFinite(anoOriginal) ? anoOriginal : null,
      texto,
      urlOrigem: null,
      urlCapa: null,
      urlCompraAmazon: null,
    };
  }

  private resumoAPartirDeBloco(linhas: string[]) {
    const inicio = linhas.findIndex((linha) => linha.toLocaleLowerCase('pt-BR').startsWith('publicada pela primeira vez em'));
    const fim = linhas.findIndex((linha) => linha.toLocaleLowerCase('pt-BR').startsWith('título original:'));
    if (inicio < 0) {
      return null;
    }

    const trecho = linhas
      .slice(inicio + 1, fim > inicio ? fim : linhas.length)
      .filter((linha) => !this.ehLinhaPaginas(linha))
      .join(' ')
      .trim();

    return trecho || null;
  }

  private tituloOriginalAPartirDeLinha(linha: string | undefined) {
    if (!linha) {
      return null;
    }

    const titulo = linha
      .replace(/^Título original:\s*/i, '')
      .replace(/^["“”]|["“”]\.?$/g, '')
      .trim();

    return titulo || null;
  }

  private paginasAPartirDeLinha(linha: string | undefined) {
    const paginas = linha?.match(/(\d+)/)?.[1];
    return paginas ? Number(paginas) : null;
  }

  private pareceTituloHistoria(linha: string) {
    if (!linha || linha.includes(':')) {
      return false;
    }

    return !this.ehLinhaPaginas(linha)
      && !linha.toLocaleLowerCase('pt-BR').startsWith('publicada pela primeira vez em');
  }

  private ehLinhaPaginas(linha: string) {
    return /^\d+\s+p[aá]ginas?$/i.test(linha.trim());
  }

  adicionarHistoria(contribuicao: ContribuicaoCatalogo) {
    const form = this.formulario(contribuicao);
    form.historias.push(this.historiaVazia(form.historias.length + 1));
  }

  removerHistoria(contribuicao: ContribuicaoCatalogo, indice: number) {
    const form = this.formulario(contribuicao);
    if (form.historias.length <= 1) {
      return;
    }

    form.historias.splice(indice, 1);
  }

  private historiaVazia(ordem: number): HistoriaImportacaoFormulario {
    return {
      ordem,
      tituloPortugues: '',
      tituloOriginal: '',
      quantidadePaginas: null,
      resumo: '',
      publicacaoOriginal: {
        serieOriginal: '',
        numeroOriginal: '',
        anoOriginal: null,
        texto: '',
        urlOrigem: '',
        urlCapa: '',
        urlCompraAmazon: '',
      },
    };
  }

  private historiaParaJson(historia: HistoriaImportacaoFormulario, ordemPadrao: number) {
    const tituloPortugues = this.textoOuNull(historia.tituloPortugues);
    const serieOriginal = this.textoOuNull(historia.publicacaoOriginal.serieOriginal);
    const numeroOriginal = this.textoOuNull(historia.publicacaoOriginal.numeroOriginal);
    if (!tituloPortugues || !serieOriginal || !numeroOriginal) {
      return null;
    }

    return {
      ordem: this.numeroOuNull(historia.ordem) ?? ordemPadrao,
      tituloPortugues,
      tituloOriginal: this.textoOuNull(historia.tituloOriginal),
      quantidadePaginas: this.numeroOuNull(historia.quantidadePaginas),
      resumo: this.textoOuNull(historia.resumo),
      publicacaoOriginal: {
        serieOriginal,
        numeroOriginal,
        anoOriginal: this.numeroOuNull(historia.publicacaoOriginal.anoOriginal),
        texto: this.textoOuNull(historia.publicacaoOriginal.texto),
        urlOrigem: this.textoOuNull(historia.publicacaoOriginal.urlOrigem),
        urlCapa: this.textoOuNull(historia.publicacaoOriginal.urlCapa),
        urlCompraAmazon: this.textoOuNull(historia.publicacaoOriginal.urlCompraAmazon),
      },
    };
  }

  private async obterOuCriarEditora(nome: string): Promise<EditoraResumo> {
    const nomeTratado = nome.trim();
    const editoras = await firstValueFrom(this.api.listarEditoras());
    const existente = editoras.find((editora) => this.normalizar(editora.nome) === this.normalizar(nomeTratado));
    if (existente) {
      return existente;
    }

    return await firstValueFrom(this.api.cadastrarEditora({
      nome: nomeTratado,
      descricao: null,
      paisOrigem: null,
      fonteExterna: null,
      idExterno: null,
      urlOrigem: null,
    }));
  }

  private dadosSugeridos(contribuicao: ContribuicaoCatalogo): Record<string, any> | null {
    if (!contribuicao.dadosSugeridosJson) {
      return null;
    }

    try {
      return JSON.parse(contribuicao.dadosSugeridosJson);
    } catch {
      return null;
    }
  }

  private revisar(contribuicao: ContribuicaoCatalogo, acao: 'aprovar' | 'recusar') {
    this.revisandoId.set(contribuicao.id);
    this.mensagem.set('');
    const mensagemRevisao = this.mensagensRevisao[contribuicao.id]?.trim() || null;
    const requisicao =
      acao === 'aprovar'
        ? this.api.aprovarContribuicaoCatalogo(contribuicao.id, mensagemRevisao)
        : this.api.recusarContribuicaoCatalogo(contribuicao.id, mensagemRevisao);

    requisicao.subscribe({
      next: () => {
        this.revisandoId.set(null);
        this.pendentes.update((pendentes) => pendentes.filter((item) => item.id !== contribuicao.id));
        delete this.formularios[contribuicao.id];
        this.mensagem.set(acao === 'aprovar' ? 'Pendencia marcada como checada.' : 'Pendencia recusada.');
      },
      error: (erro) => {
        this.revisandoId.set(null);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel revisar esta pendencia.');
      },
    });
  }

  private textoOuNull(valor: string | null | undefined) {
    const texto = valor?.trim();
    return texto ? texto : null;
  }

  private numeroOuNull(valor: number | string | null | undefined) {
    if (valor === null || valor === undefined || valor === '') {
      return null;
    }

    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : null;
  }

  private mensagemErro(erro: unknown, padrao: string) {
    const resposta = erro as { error?: { mensagem?: string } };
    return resposta.error?.mensagem || padrao;
  }

  private normalizar(valor: string | null | undefined) {
    return (valor || '').trim().toLocaleLowerCase('pt-BR');
  }
}
