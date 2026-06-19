import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { Edicao, EditoraResumo, EstanteEdicao, EstanteEditora, ResultadoPesquisaCatalogo, Serie } from '../../core/modelos';

@Component({
  selector: 'app-colecao-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Estante</p>
        <h1>Suas HQs agrupadas por editora e série.</h1>
      </div>
    </section>

    <section class="painel-formulario">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Adicionar ao perfil</p>
          <h2>Cadastrar edição na sua coleção</h2>
        </div>
        <button class="botao icone-texto" type="button" (click)="alternarCadastroManual()">
          {{ exibindoCadastroManual() ? 'Usar catálogo interno' : 'Não encontrei no catálogo' }}
        </button>
      </div>

      @if (!exibindoCadastroManual()) {
        <div class="barra-busca">
          <input
            [(ngModel)]="buscaEdicao"
            placeholder="Digite parte do título, ex.: Homem-Aranha, Definitiva, Saga do Batman"
            (ngModelChange)="agendarBuscaEdicoes()"
            (keyup.enter)="buscarEdicoes()"
          />
          <button class="botao primario" type="button" (click)="buscarEdicoes()" [disabled]="carregandoEdicoes()">
            {{ carregandoEdicoes() ? 'Buscando...' : 'Buscar edição' }}
          </button>
        </div>

        @if (resultadosEncontrados().length) {
          <div class="lista-escolha">
            @for (resultado of resultadosEncontrados(); track chaveResultado(resultado)) {
              <button type="button" [class.ativo]="resultadoSelecionado()?.idExterno === resultado.idExterno && resultadoSelecionado()?.id === resultado.id" (click)="selecionarResultado(resultado)">
                <strong>{{ tituloResultado(resultado) }}</strong>
                <span>{{ resultado.nomeVolume || 'Série não informada' }} · {{ rotuloFonte(resultado) }}</span>
              </button>
            }
          </div>
        }

        <form class="grade-formulario colecao-formulario" (ngSubmit)="cadastrarNaColecao()">
          <label>
            Edição escolhida
            <input [value]="rotuloEdicaoEscolhida()" disabled />
          </label>

          <label>
            Conservação
            <select [(ngModel)]="estadoConservacao" name="estadoConservacao">
              <option value="NOVO">Novo</option>
              <option value="EXCELENTE">Excelente</option>
              <option value="MUITO_BOM">Muito bom</option>
              <option value="BOM">Bom</option>
              <option value="REGULAR">Regular</option>
              <option value="RUIM">Ruim</option>
            </select>
          </label>

          <label>
            Data da compra
            <input type="date" [(ngModel)]="dataAquisicao" name="dataAquisicao" />
          </label>

          <label>
            Preço pago
            <input type="number" min="0" step="0.01" [(ngModel)]="precoPago" name="precoPago" placeholder="0,00" />
          </label>

          <label>
            Leitura
            <select [(ngModel)]="statusLeitura" name="statusLeitura">
              <option value="NAO_LIDO">Não lido</option>
              <option value="LIDO">Lido</option>
            </select>
          </label>

          <label class="campo-largo">
            Observações
            <input [(ngModel)]="observacoes" name="observacoes" placeholder="Ex.: comprado em promoção, capa variante..." />
          </label>

          <button class="botao primario" type="submit" [disabled]="salvandoItem() || (!edicaoSelecionada() && !resultadoSelecionado())">
            {{ salvandoItem() ? 'Salvando...' : 'Adicionar à estante' }}
          </button>
        </form>
      } @else {
        <form class="grade-formulario colecao-formulario" (ngSubmit)="cadastrarEdicaoManual()">
          <label>
            Editora
            <input
              [(ngModel)]="novaEditoraNome"
              name="novaEditoraNome"
              placeholder="Marvel, Abril, Panini..."
              (ngModelChange)="atualizarSugestoesEditora()"
            />
          </label>

          @if (editoraSelecionadaManual()) {
            <div class="selecao-existente">
              <strong>Usando editora existente:</strong>
              <span>{{ editoraSelecionadaManual()?.nome }}</span>
              <button class="botao compacto" type="button" (click)="limparEditoraSelecionada()">Trocar</button>
            </div>
          } @else if (editorasSugeridas().length) {
            <div class="lista-escolha lista-curta campo-largo">
              @for (editora of editorasSugeridas(); track editora.id) {
                <button type="button" (click)="selecionarEditoraManual(editora)">
                  <strong>{{ editora.nome }}</strong>
                  <span>Já cadastrada no catálogo interno</span>
                </button>
              }
            </div>
          }

          <label>
            Título da série ou coleção
            <input
              [(ngModel)]="novaSerieTitulo"
              name="novaSerieTitulo"
              placeholder="Ex.: Batman, Amazing Spider-Man, X-Men..."
              (ngModelChange)="atualizarSugestoesSerie()"
            />
          </label>

          @if (serieSelecionadaManual()) {
            <div class="selecao-existente campo-largo">
              <strong>Usando série existente:</strong>
              <span>{{ descreverSerie(serieSelecionadaManual()!) }}</span>
              <button class="botao compacto" type="button" (click)="limparSerieSelecionada()">Trocar</button>
            </div>
          } @else if (seriesSugeridas().length) {
            <div class="lista-escolha lista-curta campo-largo">
              @for (serie of seriesSugeridas(); track serie.id) {
                <button type="button" (click)="selecionarSerieManual(serie)">
                  <strong>{{ serie.titulo }}</strong>
                  <span>{{ descreverSerie(serie) }}</span>
                </button>
              }
            </div>
          }

          <label>
            Volume/fase da série
            <input type="number" min="1" [(ngModel)]="novaSerieVolume" name="novaSerieVolume" placeholder="1 para V1, 2 para V2..." />
          </label>

          <label>
            Ano em que essa fase começou
            <input type="number" min="1900" max="2100" [(ngModel)]="novaSerieAnoInicio" name="novaSerieAnoInicio" />
          </label>

          <label>
            Número da edição
            <input [(ngModel)]="novaEdicaoNumero" name="novaEdicaoNumero" [disabled]="novaEdicaoSemNumero" placeholder="1, 25, 300..." />
          </label>

          <label class="checkbox-formulario">
            <input type="checkbox" [(ngModel)]="novaEdicaoSemNumero" name="novaEdicaoSemNumero" (ngModelChange)="alternarEdicaoSemNumero()" />
            Edição única ou sem número
          </label>

          <label>
            Título desta edição
            <input [(ngModel)]="novaEdicaoTitulo" name="novaEdicaoTitulo" placeholder="Opcional. Ex.: A noite em que Gwen Stacy morreu" />
          </label>

          <label>
            Data de publicação
            <input type="date" [(ngModel)]="novaEdicaoDataPublicacao" name="novaEdicaoDataPublicacao" />
          </label>

          <label>
            Link da imagem da capa
            <input [(ngModel)]="novaEdicaoUrlCapa" name="novaEdicaoUrlCapa" placeholder="Opcional. Cole uma URL de imagem" />
          </label>

          <label>
            Formato/acabamento
            <input [(ngModel)]="novaEdicaoFormato" name="novaEdicaoFormato" placeholder="Opcional. Ex.: capa dura, brochura, omnibus..." />
          </label>

          <label>
            Link de referência
            <input [(ngModel)]="novaEdicaoUrlOrigem" name="novaEdicaoUrlOrigem" placeholder="Opcional. Página onde você encontrou essa edição" />
          </label>

          <label class="campo-largo">
            O que ainda precisa ser revisado?
            <input
              [(ngModel)]="observacoesRevisaoCatalogo"
              name="observacoesRevisaoCatalogo"
              placeholder="Opcional. Ex.: falta capa, data aproximada, conferir editora..."
            />
          </label>

          <label>
            Conservação
            <select [(ngModel)]="estadoConservacao" name="estadoConservacaoManual">
              <option value="NOVO">Novo</option>
              <option value="EXCELENTE">Excelente</option>
              <option value="MUITO_BOM">Muito bom</option>
              <option value="BOM">Bom</option>
              <option value="REGULAR">Regular</option>
              <option value="RUIM">Ruim</option>
            </select>
          </label>

          <label>
            Data da compra
            <input type="date" [(ngModel)]="dataAquisicao" name="dataAquisicaoManual" />
          </label>

          <label>
            Preço pago
            <input type="number" min="0" step="0.01" [(ngModel)]="precoPago" name="precoPagoManual" placeholder="0,00" />
          </label>

          <label>
            Leitura
            <select [(ngModel)]="statusLeitura" name="statusLeituraManual">
              <option value="NAO_LIDO">Não lido</option>
              <option value="LIDO">Lido</option>
            </select>
          </label>

          <label class="campo-largo">
            Observações
            <input [(ngModel)]="observacoes" name="observacoesManual" placeholder="Ex.: importada manualmente para a estante" />
          </label>

          <button class="botao primario" type="submit" [disabled]="salvandoItem()">
            {{ salvandoItem() ? 'Salvando...' : 'Criar edição e adicionar à estante' }}
          </button>
        </form>
      }

      @if (mensagem()) {
        <p class="mensagem-erro">{{ mensagem() }}</p>
      }
    </section>

    <section class="painel-estante">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Minha estante</p>
          <h2>Organize suas leituras e compras</h2>
        </div>
        <div class="acoes-estante">
          <button class="botao compacto" type="button" (click)="deduplicarCatalogo()" [disabled]="deduplicandoCatalogo()">
            {{ deduplicandoCatalogo() ? 'Limpando...' : 'Limpar duplicidades' }}
          </button>
          <span>{{ resumoEstante().total }} itens</span>
        </div>
      </div>

      <div class="metricas-estante">
        <article>
          <span>Total</span>
          <strong>{{ resumoEstante().total }}</strong>
        </article>
        <article>
          <span>Lidas</span>
          <strong>{{ resumoEstante().lidas }}</strong>
        </article>
        <article>
          <span>Não lidas</span>
          <strong>{{ resumoEstante().naoLidas }}</strong>
        </article>
        <article>
          <span>Valor registrado</span>
          <strong>{{ formatarMoeda(resumoEstante().valorTotal) }}</strong>
        </article>
      </div>

      <div class="controles-estante">
        <input [(ngModel)]="buscaEstante" placeholder="Filtrar por título, editora ou número" />
        <section class="abas-filtro">
          <button type="button" [class.ativo]="filtroLeitura() === 'TODAS'" (click)="filtroLeitura.set('TODAS')">
            Todas
          </button>
          <button type="button" [class.ativo]="filtroLeitura() === 'LIDO'" (click)="filtroLeitura.set('LIDO')">
            Lidas
          </button>
          <button type="button" [class.ativo]="filtroLeitura() === 'NAO_LIDO'" (click)="filtroLeitura.set('NAO_LIDO')">
            Não lidas
          </button>
        </section>
      </div>
    </section>

    @if (!estanteFiltrada().length) {
      <section class="estado-vazio">
        <h2>Nenhuma edição encontrada</h2>
        <p>Cadastre edições na coleção ou ajuste o filtro de leitura.</p>
      </section>
    }

    <section class="estante">
      @for (editora of estanteFiltrada(); track editora.editoraId) {
        <article class="prateleira">
          <h2>{{ editora.nome }}</h2>
          @for (serie of editora.series; track serie.serieId) {
            <div class="serie-estante">
              <div class="secao-titulo">
                <h3>{{ serie.titulo }}</h3>
                <span>{{ serie.edicoes.length }} edições</span>
              </div>
              <div class="linha-capas">
                @for (edicao of serie.edicoes; track edicao.itemColecaoId) {
                  <div class="lombada" role="button" tabindex="0" (click)="selecionarEdicaoEstante(edicao)" (keyup.enter)="selecionarEdicaoEstante(edicao)">
                    <img
                      [src]="edicao.urlCapa || capaReserva"
                      [alt]="edicao.titulo || edicao.numero"
                      loading="lazy"
                      (error)="usarCapaReserva($event)"
                    />
                    <span>#{{ edicao.numero }}</span>
                    <small [class.lido]="edicao.statusLeitura === 'LIDO'">{{ rotuloLeitura(edicao.statusLeitura) }}</small>
                    @if (edicao.dataAquisicao) {
                      <em>Comprado em {{ formatarData(edicao.dataAquisicao) }}</em>
                    }
                  </div>
                }
              </div>
            </div>
          }
        </article>
      }
    </section>

    @if (edicaoEstanteSelecionada()) {
      <section class="detalhe-edicao" role="dialog" aria-modal="true" aria-label="Detalhes da edição na estante">
        <div class="detalhe-fundo" (click)="edicaoEstanteSelecionada.set(null)"></div>
        <article class="detalhe-painel detalhe-estante">
          <button class="fechar-detalhe" type="button" (click)="edicaoEstanteSelecionada.set(null)" aria-label="Fechar detalhes">×</button>
          <div class="detalhe-cabecalho">
            <img
              [src]="edicaoEstanteSelecionada()?.urlCapa || capaReserva"
              [alt]="edicaoEstanteSelecionada()?.titulo || edicaoEstanteSelecionada()?.numero || 'Capa da edição'"
              (error)="usarCapaReserva($event)"
            />
            <div>
              <p class="rotulo">Item da sua estante</p>
              <h2>#{{ edicaoEstanteSelecionada()?.numero }} {{ edicaoEstanteSelecionada()?.titulo || '' }}</h2>
              <div class="chips">
                <span>{{ rotuloLeitura(edicaoEstanteSelecionada()?.statusLeitura || '') }}</span>
                <span>{{ rotuloConservacao(edicaoEstanteSelecionada()?.estadoConservacao || '') }}</span>
                @if (edicaoEstanteSelecionada()?.precoPago) {
                  <span>{{ formatarMoeda(edicaoEstanteSelecionada()?.precoPago || 0) }}</span>
                }
              </div>
              @if (edicaoEstanteSelecionada()?.dataAquisicao) {
                <p class="compra-confirmada">Comprado em {{ formatarData(edicaoEstanteSelecionada()?.dataAquisicao || '') }}</p>
              }
              @if (edicaoEstanteSelecionada()?.statusLeitura !== 'LIDO') {
                <button class="botao primario compacto" type="button" (click)="marcarSelecionadaComoLida()" [disabled]="atualizandoLeitura()">
                  {{ atualizandoLeitura() ? 'Atualizando...' : 'Marcar como lida' }}
                </button>
              }
              <button class="botao perigo compacto" type="button" (click)="removerSelecionadaDaEstante()" [disabled]="removendoItem()">
                {{ removendoItem() ? 'Removendo...' : 'Remover da estante' }}
              </button>
            </div>
          </div>
        </article>
      </section>
    }
  `,
})
export class ColecaoPage implements OnInit {
  private readonly api = inject(ApiService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly estante = signal<EstanteEditora[]>([]);
  readonly edicoesEncontradas = signal<Edicao[]>([]);
  readonly resultadosEncontrados = signal<ResultadoPesquisaCatalogo[]>([]);
  readonly edicaoSelecionada = signal<Edicao | null>(null);
  readonly resultadoSelecionado = signal<ResultadoPesquisaCatalogo | null>(null);
  readonly carregandoEdicoes = signal(false);
  readonly salvandoItem = signal(false);
  readonly exibindoCadastroManual = signal(false);
  readonly editorasCache = signal<EditoraResumo[]>([]);
  readonly editorasSugeridas = signal<EditoraResumo[]>([]);
  readonly editoraSelecionadaManual = signal<EditoraResumo | null>(null);
  readonly seriesSugeridas = signal<Serie[]>([]);
  readonly serieSelecionadaManual = signal<Serie | null>(null);
  readonly edicaoEstanteSelecionada = signal<EstanteEdicao | null>(null);
  readonly atualizandoLeitura = signal(false);
  readonly removendoItem = signal(false);
  readonly deduplicandoCatalogo = signal(false);
  readonly mensagem = signal('');
  readonly filtroLeitura = signal<'TODAS' | 'LIDO' | 'NAO_LIDO'>('TODAS');
  readonly resumoEstante = computed(() => {
    const edicoes = this.estante().flatMap((editora) => editora.series.flatMap((serie) => serie.edicoes));
    const lidas = edicoes.filter((edicao) => edicao.statusLeitura === 'LIDO').length;
    const valorTotal = edicoes.reduce((total, edicao) => total + (edicao.precoPago || 0), 0);

    return {
      total: edicoes.length,
      lidas,
      naoLidas: edicoes.length - lidas,
      valorTotal,
    };
  });
  readonly estanteFiltrada = computed(() => {
    const filtro = this.filtroLeitura();
    const termo = this.normalizar(this.buscaEstante);

    return this.estante()
      .map((editora) => ({
        ...editora,
        series: editora.series
          .map((serie) => ({
            ...serie,
            edicoes: serie.edicoes.filter((edicao) => {
              const passaLeitura = filtro === 'TODAS' || edicao.statusLeitura === filtro;
              const texto = this.normalizar(`${editora.nome} ${serie.titulo} ${edicao.numero} ${edicao.titulo || ''}`);
              const passaBusca = !termo || texto.includes(termo);
              return passaLeitura && passaBusca;
            }),
          }))
          .filter((serie) => serie.edicoes.length > 0),
      }))
      .filter((editora) => editora.series.length > 0);
  });

  buscaEdicao = '';
  buscaEstante = '';
  estadoConservacao = 'MUITO_BOM';
  dataAquisicao = '';
  precoPago: number | null = null;
  statusLeitura = 'NAO_LIDO';
  observacoes = '';

  novaEditoraNome = '';
  novaSerieTitulo = '';
  novaSerieVolume: number | null = 1;
  novaSerieAnoInicio: number | null = null;
  novaEdicaoNumero = '';
  novaEdicaoSemNumero = false;
  novaEdicaoTitulo = '';
  novaEdicaoDataPublicacao = '';
  novaEdicaoUrlCapa = '';
  novaEdicaoFormato = '';
  novaEdicaoUrlOrigem = '';
  observacoesRevisaoCatalogo = '';
  private temporizadorBuscaEdicao: ReturnType<typeof setTimeout> | null = null;

  ngOnInit() {
    this.carregarEstante();
  }

  alternarCadastroManual() {
    this.exibindoCadastroManual.update((valor) => !valor);
    this.mensagem.set('');
    this.editorasSugeridas.set([]);
    this.seriesSugeridas.set([]);
  }

  atualizarSugestoesEditora() {
    this.editoraSelecionadaManual.set(null);
    this.serieSelecionadaManual.set(null);
    this.seriesSugeridas.set([]);

    const termo = this.normalizar(this.novaEditoraNome);
    if (termo.length < 2) {
      this.editorasSugeridas.set([]);
      return;
    }

    this.carregarEditorasCache().then(() => {
      const sugestoes = this.editorasCache()
        .filter((editora) => this.normalizar(editora.nome).includes(termo))
        .slice(0, 6);
      this.editorasSugeridas.set(sugestoes);
    });
  }

  selecionarEditoraManual(editora: EditoraResumo) {
    this.editoraSelecionadaManual.set(editora);
    this.novaEditoraNome = editora.nome;
    this.editorasSugeridas.set([]);
    this.atualizarSugestoesSerie();
  }

  limparEditoraSelecionada() {
    this.editoraSelecionadaManual.set(null);
    this.serieSelecionadaManual.set(null);
    this.novaEditoraNome = '';
    this.novaSerieTitulo = '';
    this.editorasSugeridas.set([]);
    this.seriesSugeridas.set([]);
  }

  atualizarSugestoesSerie() {
    this.serieSelecionadaManual.set(null);

    const termo = this.normalizar(this.novaSerieTitulo);
    if (termo.length < 2) {
      this.seriesSugeridas.set([]);
      return;
    }

    this.api.listarSeries(this.novaSerieTitulo.trim(), 0, 8).subscribe({
      next: (resposta) => {
        const editoraSelecionada = this.editoraSelecionadaManual();
        const sugestoes = resposta.itens.filter(
          (serie) => !editoraSelecionada || serie.editora?.id === editoraSelecionada.id,
        );
        this.seriesSugeridas.set(sugestoes.slice(0, 6));
      },
      error: () => this.seriesSugeridas.set([]),
    });
  }

  selecionarSerieManual(serie: Serie) {
    this.serieSelecionadaManual.set(serie);
    this.novaSerieTitulo = serie.titulo;
    this.novaSerieVolume = serie.volume;
    this.novaSerieAnoInicio = serie.anoInicio;
    this.seriesSugeridas.set([]);

    if (serie.editora) {
      this.editoraSelecionadaManual.set(serie.editora);
      this.novaEditoraNome = serie.editora.nome;
      this.editorasSugeridas.set([]);
    }
  }

  limparSerieSelecionada() {
    this.serieSelecionadaManual.set(null);
    this.novaSerieTitulo = '';
    this.novaSerieVolume = 1;
    this.novaSerieAnoInicio = null;
    this.seriesSugeridas.set([]);
  }

  alternarEdicaoSemNumero() {
    if (this.novaEdicaoSemNumero) {
      this.novaEdicaoNumero = '';
    }
  }

  buscarEdicoes() {
    if (this.temporizadorBuscaEdicao) {
      clearTimeout(this.temporizadorBuscaEdicao);
      this.temporizadorBuscaEdicao = null;
    }

    if (!this.buscaEdicao.trim()) {
      this.mensagem.set('Informe um termo para buscar a edição.');
      this.resultadosEncontrados.set([]);
      return;
    }

    this.mensagem.set('');
    this.carregandoEdicoes.set(true);
    this.edicaoSelecionada.set(null);
    this.resultadoSelecionado.set(null);
    this.api.pesquisarCatalogo(this.buscaEdicao, 0, 12).subscribe({
      next: (resposta) => {
        this.resultadosEncontrados.set(resposta.itens);
        this.carregandoEdicoes.set(false);
        if (!resposta.itens.length) {
          this.mensagem.set('Nenhuma edição encontrada. Use o cadastro manual para criar uma nova.');
        }
      },
      error: () => {
        this.resultadosEncontrados.set([]);
        this.carregandoEdicoes.set(false);
        this.mensagem.set('Não foi possível buscar edições agora.');
      },
    });
  }

  agendarBuscaEdicoes() {
    this.edicaoSelecionada.set(null);
    this.resultadoSelecionado.set(null);

    if (this.temporizadorBuscaEdicao) {
      clearTimeout(this.temporizadorBuscaEdicao);
    }

    if (this.buscaEdicao.trim().length < 2) {
      this.resultadosEncontrados.set([]);
      return;
    }

    this.temporizadorBuscaEdicao = setTimeout(() => this.buscarEdicoes(), 450);
  }

  selecionarEdicao(edicao: Edicao) {
    this.edicaoSelecionada.set(edicao);
    this.resultadoSelecionado.set(null);
    this.mensagem.set('');
  }

  selecionarResultado(resultado: ResultadoPesquisaCatalogo) {
    this.resultadoSelecionado.set(resultado);
    this.edicaoSelecionada.set(null);
    this.mensagem.set('');

    if (resultado.id) {
      this.api.buscarEdicaoPorId(resultado.id).subscribe({
        next: (edicao) => this.edicaoSelecionada.set(edicao),
        error: () => this.mensagem.set('Não foi possível carregar a edição interna selecionada.'),
      });
    }
  }

  cadastrarNaColecao() {
    const edicao = this.edicaoSelecionada();
    if (!edicao) {
      const resultado = this.resultadoSelecionado();
      if (!resultado) {
        this.mensagem.set('Escolha uma edição antes de cadastrar.');
        return;
      }

      this.importarResultadoEAdicionar(resultado);
      return;
    }

    this.adicionarEdicaoNaColecao(edicao);
  }

  private adicionarEdicaoNaColecao(edicao: Edicao) {
    this.salvandoItem.set(true);
    this.mensagem.set('');
    this.api
      .cadastrarItemColecao({
        edicaoId: edicao.id,
        estadoConservacao: this.estadoConservacao,
        dataAquisicao: this.dataAquisicao || null,
        precoPago: this.precoPago,
        statusLeitura: this.statusLeitura,
        observacoes: this.observacoes || null,
      })
      .subscribe({
        next: () => {
          this.salvandoItem.set(false);
          this.mensagem.set('Edição adicionada à sua estante.');
          this.limparFormulario();
          this.carregarEstante();
        },
        error: (erro) => {
          this.salvandoItem.set(false);
          this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível adicionar a edição. Verifique se ela já está na sua coleção.'));
        },
      });
  }

  private async importarResultadoEAdicionar(resultado: ResultadoPesquisaCatalogo) {
    if (resultado.fonte !== 'COMIC_VINE') {
      this.mensagem.set('Selecione uma edição válida para adicionar à estante.');
      return;
    }

    this.salvandoItem.set(true);
    this.mensagem.set('');

    try {
      const editora = await this.obterOuCriarEditoraPorNome('Comic Vine', null);
      const serie = await this.obterOuCriarSeriePorDados({
        titulo: resultado.nomeVolume || resultado.titulo || 'Série importada da Comic Vine',
        editoraId: editora.id,
        fonteExterna: null,
      });
      const edicao = await this.obterOuCriarEdicaoPorResultado(resultado, serie.id);

      await firstValueFrom(
        this.api.cadastrarItemColecao({
          edicaoId: edicao.id,
          estadoConservacao: this.estadoConservacao,
          dataAquisicao: this.dataAquisicao || null,
          precoPago: this.precoPago,
          statusLeitura: this.statusLeitura,
          observacoes: this.observacoes || null,
        }),
      );

      this.mensagem.set('Edição importada da Comic Vine e adicionada à sua estante.');
      this.limparFormulario();
      this.carregarEstante();
    } catch (erro) {
      this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível importar esta edição agora.'));
    } finally {
      this.salvandoItem.set(false);
    }
  }

  async cadastrarEdicaoManual() {
    if (!this.novaEditoraNome.trim() || !this.novaSerieTitulo.trim() || !this.numeroManualTratado()) {
      this.mensagem.set('Preencha pelo menos editora, série e número da edição, ou marque que é uma edição única.');
      return;
    }

    this.salvandoItem.set(true);
    this.mensagem.set('');

    try {
      const editora = await this.obterOuCriarEditora();
      const serie = await this.obterOuCriarSerie(editora.id);
      const { edicao, criada } = await this.obterOuCriarEdicao(serie.id);

      await firstValueFrom(
        this.api.cadastrarItemColecao({
          edicaoId: edicao.id,
          estadoConservacao: this.estadoConservacao,
          dataAquisicao: this.dataAquisicao || null,
          precoPago: this.precoPago,
          statusLeitura: this.statusLeitura,
          observacoes: this.observacoes || null,
        }),
      );

      let revisaoRegistrada = false;
      if (criada) {
        revisaoRegistrada = await this.registrarRevisaoCadastroManual(edicao);
      }

      this.mensagem.set(
        criada && revisaoRegistrada
          ? 'Nova edição criada, adicionada à sua estante e enviada para revisão do catálogo.'
          : 'Nova edição criada e adicionada à sua estante.',
      );
      this.edicaoSelecionada.set(edicao);
      this.exibindoCadastroManual.set(false);
      this.limparFormulario();
      this.carregarEstante();
    } catch (erro) {
      this.mensagem.set(this.extrairMensagemErro(erro, 'Não foi possível criar a edição manualmente agora.'));
    } finally {
      this.salvandoItem.set(false);
    }
  }

  tituloEdicao(edicao: Edicao) {
    return `#${edicao.numero}${edicao.titulo ? ' - ' + edicao.titulo : ''}`;
  }

  tituloResultado(resultado: ResultadoPesquisaCatalogo) {
    const serie = resultado.nomeVolume || resultado.titulo || 'Edição sem título';
    const numero = resultado.numero ? ` #${resultado.numero}` : '';
    const titulo = resultado.titulo && resultado.titulo !== resultado.nomeVolume ? ` - ${resultado.titulo}` : '';
    return `${serie}${numero}${titulo}`;
  }

  rotuloFonte(resultado: ResultadoPesquisaCatalogo) {
    return resultado.fonte === 'HQ_HUB' || resultado.jaCadastrada ? 'Catálogo interno' : 'Comic Vine';
  }

  chaveResultado(resultado: ResultadoPesquisaCatalogo) {
    return `${resultado.fonte}-${resultado.id || resultado.idExterno || resultado.numero || resultado.titulo}`;
  }

  rotuloEdicaoEscolhida() {
    const edicao = this.edicaoSelecionada();
    if (edicao) {
      return this.tituloEdicao(edicao);
    }

    const resultado = this.resultadoSelecionado();
    if (resultado) {
      return this.tituloResultado(resultado);
    }

    return 'Nenhuma edição selecionada';
  }

  descreverSerie(serie: Serie) {
    const partes = [
      serie.editora?.nome || this.novaEditoraNome || 'Editora não informada',
      serie.volume ? `V${serie.volume}` : null,
      serie.anoInicio ? `${serie.anoInicio}` : null,
    ].filter(Boolean);

    return partes.join(' · ');
  }

  rotuloLeitura(status: string) {
    return status === 'LIDO' ? 'Lido' : 'Não lido';
  }

  rotuloConservacao(status: string) {
    const rotulos: Record<string, string> = {
      NOVO: 'Novo',
      EXCELENTE: 'Excelente',
      MUITO_BOM: 'Muito bom',
      BOM: 'Bom',
      REGULAR: 'Regular',
      RUIM: 'Ruim',
    };

    return rotulos[status] || status || 'Conservação não informada';
  }

  selecionarEdicaoEstante(edicao: EstanteEdicao) {
    this.edicaoEstanteSelecionada.set(edicao);
  }

  marcarSelecionadaComoLida() {
    const edicao = this.edicaoEstanteSelecionada();
    if (!edicao || edicao.statusLeitura === 'LIDO') {
      return;
    }

    this.atualizandoLeitura.set(true);
    this.api.buscarItemColecao(edicao.itemColecaoId).subscribe({
      next: (item) => {
        this.api
          .atualizarItemColecao(edicao.itemColecaoId, {
            edicaoId: item.edicao.id,
            estadoConservacao: item.estadoConservacao,
            dataAquisicao: item.dataAquisicao,
            precoPago: item.precoPago,
            statusLeitura: 'LIDO',
            observacoes: item.observacoes,
          })
          .subscribe({
            next: () => {
              this.atualizandoLeitura.set(false);
              this.edicaoEstanteSelecionada.set({ ...edicao, statusLeitura: 'LIDO' });
              this.carregarEstante();
            },
            error: () => {
              this.atualizandoLeitura.set(false);
              this.mensagem.set('Não foi possível marcar esta edição como lida.');
            },
          });
      },
      error: () => {
        this.atualizandoLeitura.set(false);
        this.mensagem.set('Não foi possível carregar este item da estante.');
      },
    });
  }

  removerSelecionadaDaEstante() {
    const edicao = this.edicaoEstanteSelecionada();
    if (!edicao) {
      return;
    }

    const titulo = `#${edicao.numero}${edicao.titulo ? ' - ' + edicao.titulo : ''}`;
    if (!window.confirm(`Remover ${titulo} da sua estante?`)) {
      return;
    }

    this.removendoItem.set(true);
    this.mensagem.set('');
    this.api.removerItemColecao(edicao.itemColecaoId).subscribe({
      next: () => {
        this.removendoItem.set(false);
        this.edicaoEstanteSelecionada.set(null);
        this.mensagem.set('Revista removida da sua estante.');
        this.carregarEstante();
      },
      error: () => {
        this.removendoItem.set(false);
        this.mensagem.set('Nao foi possivel remover esta revista da estante.');
      },
    });
  }

  deduplicarCatalogo() {
    if (!window.confirm('Limpar duplicidades do catalogo agora? A rotina mantem a edicao mais completa e move os vinculos antes de remover as repetidas.')) {
      return;
    }

    this.deduplicandoCatalogo.set(true);
    this.mensagem.set('');
    this.api.deduplicarEdicoes().subscribe({
      next: (resultado) => {
        this.deduplicandoCatalogo.set(false);
        this.mensagem.set(
          resultado.edicoesRemovidas
            ? `Duplicidades limpas: ${resultado.edicoesRemovidas} edicao(oes) removida(s) em ${resultado.gruposMesclados} grupo(s).`
            : 'Nenhuma duplicidade segura foi encontrada para limpar.',
        );
        this.carregarEstante();
      },
      error: () => {
        this.deduplicandoCatalogo.set(false);
        this.mensagem.set('Nao foi possivel limpar duplicidades agora.');
      },
    });
  }

  formatarMoeda(valor: number) {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  formatarData(data: string) {
    return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' }).format(
      new Date(`${data}T00:00:00`),
    );
  }

  usarCapaReserva(evento: Event) {
    const imagem = evento.target as HTMLImageElement;
    if (!imagem.src.endsWith(this.capaReserva)) {
      imagem.src = this.capaReserva;
    }
  }

  private carregarEstante() {
    this.api.obterEstante().subscribe({
      next: (resposta) => this.estante.set(resposta),
      error: () => this.estante.set([]),
    });
  }

  private async carregarEditorasCache() {
    if (this.editorasCache().length) {
      return;
    }

    const editoras = await firstValueFrom(this.api.listarEditoras());
    this.editorasCache.set(editoras);
  }

  private async obterOuCriarEditora() {
    const editoraSelecionada = this.editoraSelecionadaManual();
    if (editoraSelecionada) {
      return editoraSelecionada;
    }

    const editoras = await firstValueFrom(this.api.listarEditoras());
    const editoraExistente = editoras.find((editora) => this.normalizar(editora.nome) === this.normalizar(this.novaEditoraNome));

    if (editoraExistente) {
      return editoraExistente;
    }

    return await firstValueFrom(
      this.api.cadastrarEditora({
        nome: this.novaEditoraNome.trim(),
        descricao: null,
        paisOrigem: null,
        fonteExterna: null,
        idExterno: null,
        urlOrigem: null,
      }),
    );
  }

  private async obterOuCriarEditoraPorNome(nome: string, fonteExterna: string | null) {
    const editoras = await firstValueFrom(this.api.listarEditoras());
    const editoraExistente = editoras.find((editora) => this.normalizar(editora.nome) === this.normalizar(nome));

    if (editoraExistente) {
      return editoraExistente;
    }

    return await firstValueFrom(
      this.api.cadastrarEditora({
        nome,
        descricao: null,
        paisOrigem: null,
        fonteExterna,
        idExterno: null,
        urlOrigem: null,
      }),
    );
  }

  private async obterOuCriarSerie(editoraId: number) {
    const serieSelecionada = this.serieSelecionadaManual();
    if (serieSelecionada && serieSelecionada.editora?.id === editoraId) {
      return serieSelecionada;
    }

    const series = await firstValueFrom(this.api.listarSeries(this.novaSerieTitulo.trim(), 0, 20));
    const serieExistente = series.itens.find(
      (serie) =>
        this.normalizar(serie.titulo) === this.normalizar(this.novaSerieTitulo) &&
        serie.editora?.id === editoraId &&
        (serie.volume || null) === (this.novaSerieVolume || null),
    );

    if (serieExistente) {
      return serieExistente;
    }

    return await firstValueFrom(
      this.api.cadastrarSerie({
        titulo: this.novaSerieTitulo.trim(),
        descricao: null,
        anoInicio: this.novaSerieAnoInicio,
        anoFim: null,
        volume: this.novaSerieVolume,
        ordemCronologica: this.novaSerieVolume,
        fonteExterna: null,
        idExterno: null,
        urlOrigem: null,
        editoraId,
      }),
    );
  }

  private async obterOuCriarSeriePorDados(dados: {
    titulo: string;
    editoraId: number;
    fonteExterna: string | null;
  }) {
    const series = await firstValueFrom(this.api.listarSeries(dados.titulo, 0, 20));
    const serieExistente = series.itens.find(
      (serie) =>
        this.normalizar(serie.titulo) === this.normalizar(dados.titulo) &&
        serie.editora?.id === dados.editoraId,
    );

    if (serieExistente) {
      return serieExistente;
    }

    return await firstValueFrom(
      this.api.cadastrarSerie({
        titulo: dados.titulo,
        descricao: null,
        anoInicio: null,
        anoFim: null,
        volume: null,
        ordemCronologica: null,
        fonteExterna: dados.fonteExterna,
        idExterno: null,
        urlOrigem: null,
        editoraId: dados.editoraId,
      }),
    );
  }

  private async obterOuCriarEdicao(serieId: number) {
    const numero = this.numeroManualTratado();
    const resultado = await firstValueFrom(this.api.listarEdicoes(numero, 0, 30, serieId));
    const edicaoExistente = resultado.itens.find(
      (edicao) =>
        edicao.serie?.id === serieId &&
        this.normalizar(edicao.numero) === this.normalizar(numero) &&
        this.normalizar(edicao.titulo || '') === this.normalizar(this.novaEdicaoTitulo || ''),
    );

    if (edicaoExistente) {
      return { edicao: edicaoExistente, criada: false };
    }

    const edicao = await firstValueFrom(
      this.api.cadastrarEdicao({
        numero,
        titulo: this.novaEdicaoTitulo.trim() || null,
        descricao: null,
        dataPublicacao: this.novaEdicaoDataPublicacao || null,
        urlCapa: this.novaEdicaoUrlCapa.trim() || null,
        codigoBarras: null,
        quantidadePaginas: null,
        precoCapa: null,
        formato: this.novaEdicaoFormato.trim() || null,
        fonteExterna: null,
        idExterno: null,
        urlOrigem: this.novaEdicaoUrlOrigem.trim() || null,
        serieId,
      }),
    );
    return { edicao, criada: true };
  }

  private async obterOuCriarEdicaoPorResultado(resultado: ResultadoPesquisaCatalogo, serieId: number) {
    if (resultado.id) {
      return await firstValueFrom(this.api.buscarEdicaoPorId(resultado.id));
    }

    const numero = resultado.numero || 'SN';
    const existentes = await firstValueFrom(this.api.listarEdicoes(numero, 0, 30, serieId));
    const porOrigem = existentes.itens.find(
      (edicao) => edicao.fonteExterna === 'COMICVINE' && edicao.idExterno === resultado.idExterno,
    );

    if (porOrigem) {
      return porOrigem;
    }

    const porNumero = existentes.itens.find(
      (edicao) => edicao.serie?.id === serieId && this.normalizar(edicao.numero) === this.normalizar(numero),
    );

    if (porNumero) {
      return porNumero;
    }

    return await firstValueFrom(
      this.api.cadastrarEdicao({
        numero,
        titulo: resultado.titulo,
        descricao: null,
        dataPublicacao: resultado.dataPublicacao,
        urlCapa: resultado.urlCapa,
        codigoBarras: null,
        quantidadePaginas: null,
        precoCapa: null,
        formato: null,
        fonteExterna: 'COMICVINE',
        idExterno: resultado.idExterno,
        urlOrigem: resultado.urlOrigem,
        serieId,
      }),
    );
  }

  private async registrarRevisaoCadastroManual(edicao: Edicao) {
    const dadosSugeridos = {
      origem: 'CADASTRO_MANUAL_ESTANTE',
      editora: this.novaEditoraNome.trim(),
      serie: this.novaSerieTitulo.trim(),
      volume: this.novaSerieVolume,
      anoInicio: this.novaSerieAnoInicio,
      numero: this.numeroManualTratado(),
      edicaoSemNumero: this.novaEdicaoSemNumero,
      titulo: this.novaEdicaoTitulo.trim() || null,
      dataPublicacao: this.novaEdicaoDataPublicacao || null,
      urlCapa: this.novaEdicaoUrlCapa.trim() || null,
      formato: this.novaEdicaoFormato.trim() || null,
      urlOrigem: this.novaEdicaoUrlOrigem.trim() || null,
    };

    try {
      await firstValueFrom(
        this.api.cadastrarContribuicaoCatalogo({
          edicaoId: edicao.id,
          tipo: 'DADOS_EDICAO',
          urlCapaSugerida: null,
          edicaoDestinoId: null,
          tipoPublicacaoRelacionada: null,
          fonteExterna: 'CADASTRO_USUARIO',
          urlFonte: this.novaEdicaoUrlOrigem.trim() || null,
          dadosSugeridosJson: JSON.stringify(dadosSugeridos),
          observacoes:
            this.observacoesRevisaoCatalogo.trim() ||
            'Edição criada por usuário na estante. Revisar dados do catálogo, capa, fontes e vínculos.',
        }),
      );
      return true;
    } catch {
      return false;
    }
  }

  private extrairMensagemErro(erro: unknown, mensagemPadrao: string) {
    const resposta = erro as { error?: { mensagem?: string } };
    return resposta.error?.mensagem ?? mensagemPadrao;
  }

  private numeroManualTratado() {
    return this.novaEdicaoSemNumero ? 'UNICA' : this.novaEdicaoNumero.trim();
  }

  private normalizar(valor: string | null | undefined) {
    return (valor || '').trim().toLocaleLowerCase('pt-BR');
  }

  private limparFormulario() {
    this.edicoesEncontradas.set([]);
    this.resultadosEncontrados.set([]);
    this.edicaoSelecionada.set(null);
    this.resultadoSelecionado.set(null);
    this.buscaEdicao = '';
    this.estadoConservacao = 'MUITO_BOM';
    this.dataAquisicao = '';
    this.precoPago = null;
    this.statusLeitura = 'NAO_LIDO';
    this.observacoes = '';
    this.novaEditoraNome = '';
    this.novaSerieTitulo = '';
    this.novaSerieVolume = 1;
    this.novaSerieAnoInicio = null;
    this.novaEdicaoNumero = '';
    this.novaEdicaoSemNumero = false;
    this.novaEdicaoTitulo = '';
    this.novaEdicaoDataPublicacao = '';
    this.novaEdicaoUrlCapa = '';
    this.novaEdicaoFormato = '';
    this.novaEdicaoUrlOrigem = '';
    this.observacoesRevisaoCatalogo = '';
    this.editorasSugeridas.set([]);
    this.editoraSelecionadaManual.set(null);
    this.seriesSugeridas.set([]);
    this.serieSelecionadaManual.set(null);
  }
}

