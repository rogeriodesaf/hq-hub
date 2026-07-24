import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LucideDownload, LucidePlus, LucideSearch, LucideShare2, LucideSparkles } from '@lucide/angular';
import { firstValueFrom } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import {
  Edicao,
  EditoraResumo,
  ConfiguracaoColecao,
  EstanteEdicao,
  EstanteEditora,
  EstanteSerie,
  PaginaResposta,
  ResultadoPesquisaCatalogo,
  Serie,
} from '../../core/modelos';

@Component({
  selector: 'app-colecao-page',
  imports: [CommonModule, FormsModule, LucideDownload, LucidePlus, LucideSearch, LucideShare2, LucideSparkles],
  template: `
    <section class="cabecalho-pagina estante-cabecalho">
      <div>
        <p class="rotulo">Estante</p>
        <h1>Suas HQs agrupadas por editora e série.</h1>
      </div>
    </section>

    <section class="painel-formulario estante-painel-formulario">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Adicionar ao perfil</p>
          <h2>Cadastrar edição na sua coleção</h2>
        </div>
      </div>

      <div class="controle-segmentado-estante" role="group" aria-label="Forma de cadastro">
        <button type="button" [class.ativo]="!exibindoCadastroManual()" [attr.aria-pressed]="!exibindoCadastroManual()" (click)="exibindoCadastroManual() && alternarCadastroManual()">
          Catálogo HQ-HUB
        </button>
        <button type="button" [class.ativo]="exibindoCadastroManual()" [attr.aria-pressed]="exibindoCadastroManual()" (click)="!exibindoCadastroManual() && alternarCadastroManual()">
          Cadastro manual
        </button>
      </div>

      @if (!exibindoCadastroManual()) {
        <div class="barra-busca">
          <input
            [(ngModel)]="buscaEdicao"
            placeholder="Ex.: Batman, X-Men..."
            (ngModelChange)="agendarBuscaEdicoes()"
            (keyup.enter)="buscarEdicoes()"
          />
          <button class="botao primario" type="button" (click)="buscarEdicoes()" [disabled]="carregandoEdicoes()">
            <svg lucideSearch size="18" aria-hidden="true"></svg>
            {{ carregandoEdicoes() ? 'Buscando...' : 'Buscar edição' }}
          </button>
        </div>

        @if (resultadosEncontrados().length) {
          <div class="barra-selecao-edicoes">
            <div>
              <strong>{{ totalSelecionadas() }} selecionada(s)</strong>
              <span>Selecione edições internas para adicionar de uma vez.</span>
            </div>
            <div class="acoes-selecao-edicoes">
              <button class="botao compacto" type="button" (click)="selecionarTodasInternas()" [disabled]="!totalInternasSelecionaveis() || salvandoItem()">
                Selecionar internas
              </button>
              <button class="botao compacto" type="button" (click)="limparSelecaoEmMassa()" [disabled]="!totalSelecionadas() || salvandoItem()">
                Limpar
              </button>
              <button class="botao primario compacto" type="button" (click)="adicionarSelecionadasNaEstante()" [disabled]="!totalSelecionadas() || salvandoItem()">
                <svg lucidePlus size="17" aria-hidden="true"></svg>
                {{ salvandoItem() ? 'Adicionando...' : 'Adicionar selecionadas' }}
              </button>
            </div>
          </div>
          <div class="lista-escolha">
            @for (resultado of resultadosEncontrados(); track chaveResultado(resultado)) {
              <div class="resultado-selecao" [class.ativo]="resultadoSelecionado()?.idExterno === resultado.idExterno && resultadoSelecionado()?.id === resultado.id">
                <label class="checkbox-selecao switch-controle" [class.desabilitado]="!resultadoSelecionavelEmMassa(resultado)">
                  <input
                    type="checkbox"
                    [checked]="resultadoSelecionadoEmMassa(resultado)"
                    [disabled]="!resultadoSelecionavelEmMassa(resultado) || salvandoItem()"
                    (change)="alternarResultadoEmMassa(resultado, $any($event.target).checked)"
                  />
                  <span>Selecionar</span>
                </label>
                <button type="button" [class.ativo]="resultadoSelecionado()?.idExterno === resultado.idExterno && resultadoSelecionado()?.id === resultado.id" (click)="selecionarResultado(resultado)">
                  <strong>{{ tituloResultado(resultado) }}</strong>
                  <span>{{ descricaoResultado(resultado) }}</span>
                </button>
              </div>
            }
          </div>
        }

        <form class="colecao-formulario formulario-accordions" (ngSubmit)="cadastrarNaColecao()">
          <details class="accordion-formulario" open>
            <summary>Dados da coleção</summary>
            <div class="grade-formulario">
              <label class="campo-largo">
                Edição escolhida
                <input [value]="rotuloEdicaoEscolhida()" disabled />
              </label>
            </div>
          </details>

          <details class="accordion-formulario">
            <summary>Dados da edição</summary>
            <div class="grade-formulario">
              <label>
                Leitura
                <select [(ngModel)]="statusLeitura" name="statusLeitura">
                  <option value="NAO_LIDO">Não lido</option>
                  <option value="LIDO">Lido</option>
                </select>
              </label>
            </div>
          </details>

          <details class="accordion-formulario" open>
            <summary>Estado e compra</summary>
            <div class="grade-formulario">
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
                Preço (R$)
                <input type="number" min="0" step="0.01" [(ngModel)]="precoPago" name="precoPago" placeholder="Usar preço de capa" />
              </label>
            </div>
          </details>

          <details class="accordion-formulario">
            <summary>Informações extras</summary>
            <div class="grade-formulario">
              <label class="campo-largo">
                Observações
                <input [(ngModel)]="observacoes" name="observacoes" placeholder="Ex.: promoção, capa variante..." />
              </label>
            </div>
          </details>

          <button class="botao primario botao-principal-estante" type="submit" [disabled]="salvandoItem() || (!edicaoSelecionada() && !resultadoSelecionado())">
            <svg lucidePlus size="18" aria-hidden="true"></svg>
            {{ salvandoItem() ? 'Salvando...' : 'Adicionar à estante' }}
          </button>
        </form>
      } @else {
        <form class="colecao-formulario formulario-accordions" (ngSubmit)="cadastrarEdicaoManual()">
          <details class="accordion-formulario" open>
            <summary>Dados da coleção</summary>
            <div class="grade-formulario">
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
              placeholder="Ex.: Batman, X-Men..."
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
            <span class="texto-suave">Use V1, V2 etc. para separar fases.</span>
          </label>

          <label>
            Ano em que essa fase começou
            <input type="number" min="1900" max="2100" [(ngModel)]="novaSerieAnoInicio" name="novaSerieAnoInicio" />
          </label>

          @if (!serieSelecionadaManual()) {
            <label class="checkbox-formulario switch-controle campo-largo">
              <input
                type="checkbox"
                [(ngModel)]="gerarEdicoesAutomaticamente"
                name="gerarEdicoesAutomaticamente"
                (ngModelChange)="alternarGeracaoAutomaticaEdicoes()"
              />
              Gerar edições automaticamente
            </label>
          }

          @if (!serieSelecionadaManual() && gerarEdicoesAutomaticamente) {
            <section class="geracao-edicoes campo-largo">
              <div>
                <h3>Geração automática de edições</h3>
                <p class="texto-suave">Você poderá editar as edições depois.</p>
              </div>

              <div class="grade-formulario geracao-edicoes-campos">
                <label>
                  Quantidade de edições
                  <input type="number" min="1" max="500" step="1" [(ngModel)]="quantidadeEdicoesAutomaticas" name="quantidadeEdicoesAutomaticas" />
                </label>
                <label>
                  Número inicial
                  <input type="number" min="0" step="1" [(ngModel)]="numeroInicialEdicoesAutomaticas" name="numeroInicialEdicoesAutomaticas" />
                </label>
                <label>
                  Intervalo da numeração
                  <input type="number" min="1" step="1" [(ngModel)]="intervaloEdicoesAutomaticas" name="intervaloEdicoesAutomaticas" />
                </label>
              </div>

              <button class="botao compacto" type="button" (click)="gerarPreviaEdicoesAutomaticas()">
                <svg lucideSparkles size="17" aria-hidden="true"></svg>
                Gerar prévia
              </button>

              @if (previewGeradoEdicoesAutomaticas && previewEdicoesAutomaticas().length) {
                <div class="preview-edicoes-automaticas">
                  @for (edicao of previewEdicoesAutomaticas(); track edicao) {
                    <span>{{ edicao }}</span>
                  }
                  @if (totalEdicoesAutomaticasRestantes() > 0) {
                    <em>+{{ totalEdicoesAutomaticasRestantes() }} edições</em>
                  }
                </div>
              }
            </section>
          }
            </div>
          </details>

          <details class="accordion-formulario" open>
            <summary>Dados da edição</summary>
            <div class="grade-formulario">
          <label>
            Número da edição
            <input [(ngModel)]="novaEdicaoNumero" name="novaEdicaoNumero" [disabled]="novaEdicaoSemNumero" placeholder="1, 25, 300..." />
          </label>

          <label class="checkbox-formulario switch-controle">
            <input type="checkbox" [(ngModel)]="novaEdicaoSemNumero" name="novaEdicaoSemNumero" (ngModelChange)="alternarEdicaoSemNumero()" />
            Edição única ou sem número
          </label>

          <label>
            Título desta edição
            <input [(ngModel)]="novaEdicaoTitulo" name="novaEdicaoTitulo" placeholder="Ex.: A noite de Gwen Stacy" />
          </label>

          <label>
            Data de publicação
            <input type="date" [(ngModel)]="novaEdicaoDataPublicacao" name="novaEdicaoDataPublicacao" />
          </label>

          <label>
            Link da imagem da capa
            <input [(ngModel)]="novaEdicaoUrlCapa" name="novaEdicaoUrlCapa" placeholder="URL da imagem" />
          </label>

          <label>
            Formato/acabamento
            <input [(ngModel)]="novaEdicaoFormato" name="novaEdicaoFormato" placeholder="Ex.: capa dura, brochura" />
          </label>
            </div>
          </details>

          <details class="accordion-formulario" open>
            <summary>Estado e compra</summary>
            <div class="grade-formulario">
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
            Preço (R$)
            <input type="number" min="0" step="0.01" [(ngModel)]="precoPago" name="precoPagoManual" placeholder="Usar preço de capa" />
          </label>

          <label>
            Leitura
            <select [(ngModel)]="statusLeitura" name="statusLeituraManual">
              <option value="NAO_LIDO">Não lido</option>
              <option value="LIDO">Lido</option>
            </select>
          </label>
            </div>
          </details>

          <details class="accordion-formulario">
            <summary>Informações extras</summary>
            <div class="grade-formulario">
              <label>
                Link de referência
                <input [(ngModel)]="novaEdicaoUrlOrigem" name="novaEdicaoUrlOrigem" placeholder="URL de referência" />
              </label>
              <label class="campo-largo">
                O que precisa ser revisado?
                <input
                  [(ngModel)]="observacoesRevisaoCatalogo"
                  name="observacoesRevisaoCatalogo"
                  placeholder="Ex.: falta capa ou data"
                />
              </label>
              <label class="campo-largo">
                Observações
                <input [(ngModel)]="observacoes" name="observacoesManual" placeholder="Ex.: cadastro manual" />
              </label>
            </div>
          </details>

          <button class="botao primario botao-principal-estante" type="submit" [disabled]="salvandoItem()">
            <svg lucidePlus size="18" aria-hidden="true"></svg>
            {{ salvandoItem() ? 'Salvando...' : 'Criar edição e adicionar à estante' }}
          </button>
        </form>
      }

      @if (mensagem()) {
        <aside class="toast-sistema" [class.sucesso]="tipoMensagem() === 'sucesso'" [class.erro]="tipoMensagem() === 'erro'" [class.info]="tipoMensagem() === 'info'" role="status" aria-live="polite">
          <p>{{ mensagem() }}</p>
          <button type="button" class="fechar-toast" (click)="fecharMensagem()" aria-label="Fechar mensagem">×</button>
        </aside>
      }
    </section>

    <section class="painel-estante">
      <div class="secao-titulo">
        <div>
          <p class="rotulo">Minha estante</p>
          <h2>Organize suas leituras e compras</h2>
        </div>
        <div class="acoes-estante">
          <button class="botao compacto" type="button" (click)="exportarColecao('EXCEL')" [disabled]="exportandoColecao()">
            <svg lucideDownload size="17" aria-hidden="true"></svg>
            Excel
          </button>
          <button class="botao compacto" type="button" (click)="exportarColecao('GOOGLE')" [disabled]="exportandoColecao()">
            <svg lucideDownload size="17" aria-hidden="true"></svg>
            Google Sheets
          </button>
          @if (podeAdministrarCatalogo()) {
            <button class="botao compacto" type="button" (click)="deduplicarCatalogo()" [disabled]="deduplicandoCatalogo()">
              {{ deduplicandoCatalogo() ? 'Limpando...' : 'Limpar duplicidades' }}
            </button>
          }
          <span>{{ paginaEstante().totalItens }} itens</span>
        </div>
      </div>

      <div class="metricas-estante">
        <article>
          <span>Total filtrado</span>
          <strong>{{ paginaEstante().totalItens }}</strong>
        </article>
        <article>
          <span>Lidas nesta página</span>
          <strong>{{ resumoEstante().lidas }}</strong>
        </article>
        <article>
          <span>Não lidas nesta página</span>
          <strong>{{ resumoEstante().naoLidas }}</strong>
        </article>
        <article>
          <span>Valor nesta página</span>
          <strong>{{ (configuracaoColecao()?.exibirValorColecao ?? true) ? formatarMoeda(resumoEstante().valorTotal) : 'Oculto' }}</strong>
        </article>
      </div>

      <div class="configuracao-estante">
        <label>
          Visibilidade da estante
          <select
            [ngModel]="configuracaoColecao()?.visibilidadeColecao || 'PRIVADA'"
            name="visibilidadeColecao"
            (ngModelChange)="alterarConfiguracaoEstante({ visibilidadeColecao: $event })"
          >
            <option value="PRIVADA">Privada</option>
            <option value="AMIGOS">Somente amigos</option>
            <option value="PUBLICA">Pública</option>
          </select>
        </label>

        <label class="checkbox-formulario switch-controle">
          <input
            type="checkbox"
            [checked]="configuracaoColecao()?.exibirValorColecao ?? true"
            (change)="alterarConfiguracaoEstante({ exibirValorColecao: ($any($event.target).checked) })"
          />
          Exibir valor da estante
        </label>
      </div>

      @if (configuracaoColecao()?.visibilidadeColecao === 'PUBLICA') {
        <div class="configuracao-estante">
          <div>
            <strong>Compartilhe sua estante</strong>
            <p class="texto-suave">Visitantes verão capas, séries e status de leitura, sem preços ou datas de compra.</p>
          </div>
          <button class="botao primario compacto" type="button" (click)="copiarLinkEstantePublica()">
            <svg lucideShare2 size="17" aria-hidden="true"></svg>
            Copiar link público
          </button>
        </div>
      }

      <div class="controles-estante">
        <input [(ngModel)]="buscaEstante" placeholder="Filtrar por título, editora ou número" (ngModelChange)="agendarBuscaEstante()" />
        <section class="abas-filtro">
          <button type="button" [class.ativo]="filtroLeitura() === 'TODAS'" (click)="alterarFiltroLeitura('TODAS')">
            Todas
          </button>
          <button type="button" [class.ativo]="filtroLeitura() === 'LIDO'" (click)="alterarFiltroLeitura('LIDO')">
            Lidas
          </button>
          <button type="button" [class.ativo]="filtroLeitura() === 'NAO_LIDO'" (click)="alterarFiltroLeitura('NAO_LIDO')">
            Não lidas
          </button>
        </section>
      </div>

      @if (paginaEstante().totalPaginas > 1) {
        <div class="paginacao-estante">
          <button class="botao compacto" type="button" [disabled]="carregandoEstante() || paginaEstante().pagina === 0" (click)="mudarPaginaEstante(-1)">
            Anterior
          </button>
          <span>Página {{ paginaEstante().pagina + 1 }} de {{ paginaEstante().totalPaginas }}</span>
          <button
            class="botao compacto"
            type="button"
            [disabled]="carregandoEstante() || paginaEstante().pagina + 1 >= paginaEstante().totalPaginas"
            (click)="mudarPaginaEstante(1)"
          >
            Próxima
          </button>
        </div>
      }
    </section>

    @if (!carregandoEstante() && !estanteFiltrada().length) {
      <section class="estado-vazio">
        <h2>Nenhuma edição encontrada</h2>
        <p>Cadastre edições na coleção ou ajuste o filtro de leitura.</p>
      </section>
    }

    @if (carregandoEstante()) {
      <section class="estado-vazio">
        <h2>Carregando estante</h2>
        <p>Buscando apenas a página atual para manter a navegação leve.</p>
      </section>
    }

    <section class="estante">
      @for (editora of estanteFiltrada(); track chaveEditoraRender(editora)) {
        <article class="prateleira">
          <h2>{{ editora.nome }}</h2>
          @for (serie of editora.series; track chaveSerieRender(serie)) {
            <div class="serie-estante">
              <div class="secao-titulo">
                <h3>{{ serie.titulo }}@if (serie.volume) { <small>V{{ serie.volume }}</small>}</h3>
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
  private readonly autenticacao = inject(AutenticacaoService);
  readonly capaReserva = 'assets/capa-reserva.svg';
  readonly estante = signal<EstanteEditora[]>([]);
  readonly paginaEstante = signal<PaginaResposta<EstanteEditora>>({
    itens: [],
    pagina: 0,
    tamanho: 48,
    totalItens: 0,
    totalPaginas: 0,
  });
  readonly edicoesEncontradas = signal<Edicao[]>([]);
  readonly resultadosEncontrados = signal<ResultadoPesquisaCatalogo[]>([]);
  readonly resultadosSelecionadosEmMassa = signal<string[]>([]);
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
  readonly carregandoEstante = signal(false);
  readonly exportandoColecao = signal(false);
  readonly podeRevisarCatalogo = this.autenticacao.podeRevisarCatalogo;
  readonly podeAdministrarCatalogo = this.autenticacao.ehAdministrador;
  readonly configuracaoColecao = signal<ConfiguracaoColecao | null>(null);
  readonly salvandoConfiguracao = signal(false);
  readonly mensagem = signal('');
  readonly tipoMensagem = computed<'sucesso' | 'erro' | 'info'>(() => this.classificarMensagem(this.mensagem()));
  readonly filtroLeitura = signal<'TODAS' | 'LIDO' | 'NAO_LIDO'>('TODAS');
  readonly totalSelecionadas = computed(() => this.resultadosSelecionadosEmMassa().length);
  readonly totalInternasSelecionaveis = computed(() => this.resultadosEncontrados().filter((resultado) => this.resultadoSelecionavelEmMassa(resultado)).length);
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
  gerarEdicoesAutomaticamente = false;
  previewGeradoEdicoesAutomaticas = false;
  quantidadeEdicoesAutomaticas: number | null = null;
  numeroInicialEdicoesAutomaticas: number | null = 1;
  intervaloEdicoesAutomaticas: number | null = 1;
  novaEdicaoNumero = '';
  novaEdicaoSemNumero = false;
  novaEdicaoTitulo = '';
  novaEdicaoDataPublicacao = '';
  novaEdicaoUrlCapa = '';
  novaEdicaoFormato = '';
  novaEdicaoUrlOrigem = '';
  observacoesRevisaoCatalogo = '';
  private temporizadorBuscaEdicao: ReturnType<typeof setTimeout> | null = null;
  private temporizadorBuscaEstante: ReturnType<typeof setTimeout> | null = null;

  ngOnInit() {
    this.carregarConfiguracaoColecao();
    this.carregarEstante();
  }

  fecharMensagem() {
    this.mensagem.set('');
  }

  alterarConfiguracaoEstante(patch: Partial<Pick<ConfiguracaoColecao, 'visibilidadeColecao' | 'exibirValorColecao'>>) {
    const atual = this.configuracaoColecao();
    if (!atual) {
      return;
    }

    this.salvandoConfiguracao.set(true);
    this.api.atualizarConfiguracaoColecao({
      visibilidadeColecao: patch.visibilidadeColecao ?? atual.visibilidadeColecao,
      exibirValorColecao: patch.exibirValorColecao ?? atual.exibirValorColecao,
    }).subscribe({
      next: (resposta) => {
        this.configuracaoColecao.set(resposta);
        this.salvandoConfiguracao.set(false);
        this.mensagem.set('Configuração da estante atualizada.');
      },
      error: () => {
        this.salvandoConfiguracao.set(false);
        this.mensagem.set('Não foi possível atualizar a configuração da estante.');
      },
    });
  }

  async copiarLinkEstantePublica() {
    const usuarioId = this.autenticacao.usuario()?.id;
    if (!usuarioId) return;
    const link = `${window.location.origin}/compartilhar-estante/${usuarioId}`;
    try {
      await navigator.clipboard.writeText(link);
      this.mensagem.set('Link público da estante copiado.');
    } catch {
      this.mensagem.set(`Copie este link: ${link}`);
    }
  }

  agendarBuscaEstante() {
    if (this.temporizadorBuscaEstante) {
      clearTimeout(this.temporizadorBuscaEstante);
    }

    this.temporizadorBuscaEstante = setTimeout(() => this.carregarEstante(0), 350);
  }

  alterarFiltroLeitura(filtro: 'TODAS' | 'LIDO' | 'NAO_LIDO') {
    this.filtroLeitura.set(filtro);
    this.carregarEstante(0);
  }

  mudarPaginaEstante(delta: number) {
    const paginaAtual = this.paginaEstante().pagina;
    const proximaPagina = paginaAtual + delta;
    if (proximaPagina < 0 || proximaPagina >= this.paginaEstante().totalPaginas) {
      return;
    }

    this.carregarEstante(proximaPagina);
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
    this.limparGeracaoAutomaticaEdicoes();
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

  alternarGeracaoAutomaticaEdicoes() {
    this.previewGeradoEdicoesAutomaticas = false;
    if (!this.gerarEdicoesAutomaticamente) {
      this.limparGeracaoAutomaticaEdicoes();
      return;
    }

    this.numeroInicialEdicoesAutomaticas ??= 1;
    this.intervaloEdicoesAutomaticas ??= 1;
  }

  gerarPreviaEdicoesAutomaticas() {
    if (!this.validarGeracaoAutomaticaEdicoes()) {
      this.previewGeradoEdicoesAutomaticas = false;
      return;
    }

    this.previewGeradoEdicoesAutomaticas = true;
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
      this.resultadosSelecionadosEmMassa.set([]);
      return;
    }

    this.mensagem.set('');
    this.carregandoEdicoes.set(true);
    this.edicaoSelecionada.set(null);
    this.resultadoSelecionado.set(null);
    this.resultadosSelecionadosEmMassa.set([]);
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
        this.resultadosSelecionadosEmMassa.set([]);
        this.carregandoEdicoes.set(false);
        this.mensagem.set('Não foi possível buscar edições agora.');
      },
    });
  }

  agendarBuscaEdicoes() {
    this.edicaoSelecionada.set(null);
    this.resultadoSelecionado.set(null);
    this.resultadosSelecionadosEmMassa.set([]);

    if (this.temporizadorBuscaEdicao) {
      clearTimeout(this.temporizadorBuscaEdicao);
    }

    if (this.buscaEdicao.trim().length < 2) {
      this.resultadosEncontrados.set([]);
      this.resultadosSelecionadosEmMassa.set([]);
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

  resultadoSelecionavelEmMassa(resultado: ResultadoPesquisaCatalogo) {
    return resultado.fonte === 'HQ_HUB' && !!resultado.id;
  }

  resultadoSelecionadoEmMassa(resultado: ResultadoPesquisaCatalogo) {
    return this.resultadosSelecionadosEmMassa().includes(this.chaveResultado(resultado));
  }

  alternarResultadoEmMassa(resultado: ResultadoPesquisaCatalogo, selecionado: boolean) {
    if (!this.resultadoSelecionavelEmMassa(resultado)) {
      return;
    }

    const chave = this.chaveResultado(resultado);
    this.resultadosSelecionadosEmMassa.update((selecionados) => {
      if (selecionado) {
        return selecionados.includes(chave) ? selecionados : [...selecionados, chave];
      }

      return selecionados.filter((item) => item !== chave);
    });
    this.mensagem.set('');
  }

  selecionarTodasInternas() {
    const chaves = this.resultadosEncontrados()
      .filter((resultado) => this.resultadoSelecionavelEmMassa(resultado))
      .map((resultado) => this.chaveResultado(resultado));
    this.resultadosSelecionadosEmMassa.set(chaves);
    this.mensagem.set('');
  }

  limparSelecaoEmMassa() {
    this.resultadosSelecionadosEmMassa.set([]);
  }

  async adicionarSelecionadasNaEstante() {
    const selecionadas = this.resultadosEncontrados().filter((resultado) => this.resultadoSelecionadoEmMassa(resultado) && resultado.id);
    if (!selecionadas.length) {
      this.mensagem.set('Selecione pelo menos uma edição interna para adicionar.');
      return;
    }

    this.salvandoItem.set(true);
    this.mensagem.set('');

    let adicionadas = 0;
    let falhas = 0;

    for (const resultado of selecionadas) {
      try {
        await firstValueFrom(
          this.api.cadastrarItemColecao({
            edicaoId: resultado.id!,
            estadoConservacao: this.estadoConservacao,
            dataAquisicao: this.dataAquisicao || null,
            precoPago: this.precoPago,
            statusLeitura: this.statusLeitura,
            observacoes: this.observacoes || null,
          }),
        );
        adicionadas += 1;
      } catch {
        falhas += 1;
      }
    }

    this.salvandoItem.set(false);
    this.resultadosSelecionadosEmMassa.set([]);
    if (adicionadas) {
      this.mensagem.set(
        falhas
          ? `${adicionadas} edição(ões) adicionada(s). ${falhas} já estavam na estante ou não puderam ser adicionadas.`
          : `${adicionadas} edição(ões) adicionada(s) à sua estante.`,
      );
      this.limparFormulario();
      this.carregarEstante();
      return;
    }

    this.mensagem.set('Nenhuma edição foi adicionada. Verifique se elas já estão na sua estante.');
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

    if (!this.validarGeracaoAutomaticaEdicoes()) {
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
          suprimirRevisaoCatalogo: criada,
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

  previewEdicoesAutomaticas() {
    const parametros = this.parametrosGeracaoAutomatica();
    if (!parametros || !this.novaSerieTitulo.trim()) {
      return [];
    }
    if (
      !Number.isInteger(parametros.quantidade) ||
      parametros.quantidade < 1 ||
      parametros.quantidade > 500 ||
      !Number.isInteger(parametros.numeroInicial) ||
      parametros.numeroInicial < 0 ||
      !Number.isInteger(parametros.intervalo) ||
      parametros.intervalo < 1
    ) {
      return [];
    }

    const limite = Math.min(parametros.quantidade, 20);
    return Array.from({ length: limite }, (_, indice) => {
      const numero = parametros.numeroInicial + indice * parametros.intervalo;
      return `${this.novaSerieTitulo.trim()} #${numero}`;
    });
  }

  totalEdicoesAutomaticasRestantes() {
    const parametros = this.parametrosGeracaoAutomatica();
    return parametros ? Math.max(parametros.quantidade - 20, 0) : 0;
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

  descricaoResultado(resultado: ResultadoPesquisaCatalogo) {
    const partes = [
      resultado.nomeVolume || 'Série não informada',
      resultado.serieVolume ? `V${resultado.serieVolume}` : null,
      this.rotuloFonte(resultado),
    ].filter(Boolean);

    return partes.join(' · ');
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

  exportarColecao(formato: 'EXCEL' | 'GOOGLE') {
    this.exportandoColecao.set(true);
    this.mensagem.set('');
    this.api.exportarColecao(formato).subscribe({
      next: (arquivo) => {
        this.exportandoColecao.set(false);
        const url = URL.createObjectURL(arquivo);
        const link = document.createElement('a');
        link.href = url;
        link.download = formato === 'GOOGLE' ? 'hqhub-colecao-google-sheets.csv' : 'hqhub-colecao-excel.csv';
        link.click();
        URL.revokeObjectURL(url);
      },
      error: () => {
        this.exportandoColecao.set(false);
        this.mensagem.set('Nao foi possivel baixar sua colecao agora.');
      },
    });
  }

  deduplicarCatalogo() {
    if (!this.podeAdministrarCatalogo()) {
      return;
    }

    if (!window.confirm('Limpar duplicidades do catalogo agora? A rotina mantem series e edicoes mais completas e move os vinculos antes de remover repetidas.')) {
      return;
    }

    this.deduplicandoCatalogo.set(true);
    this.mensagem.set('');
    this.api.deduplicarSeries().subscribe({
      next: (series) => {
        this.api.deduplicarEdicoes().subscribe({
          next: (edicoes) => {
            this.deduplicandoCatalogo.set(false);
            const totalRemovido = series.seriesRemovidas + edicoes.edicoesRemovidas;
            this.mensagem.set(
              totalRemovido
                ? `Duplicidades limpas: ${series.seriesRemovidas} serie(s) e ${edicoes.edicoesRemovidas} edicao(oes) removida(s).`
                : 'Nenhuma duplicidade segura foi encontrada para limpar.',
            );
            this.carregarEstante();
          },
          error: () => {
            this.deduplicandoCatalogo.set(false);
            this.mensagem.set('As series foram verificadas, mas nao foi possivel limpar duplicidades de edicoes agora.');
          },
        });
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

  private carregarEstante(pagina = this.paginaEstante().pagina) {
    this.carregandoEstante.set(true);
    this.api.obterEstantePaginada(this.buscaEstante, this.filtroLeitura(), pagina, this.paginaEstante().tamanho).subscribe({
      next: (resposta) => {
        const estante = this.unificarSeriesFragmentadas(resposta.itens);
        this.paginaEstante.set({ ...resposta, itens: estante });
        this.estante.set(estante);
        this.carregandoEstante.set(false);
      },
      error: () => {
        this.estante.set([]);
        this.paginaEstante.set({ itens: [], pagina: 0, tamanho: 48, totalItens: 0, totalPaginas: 0 });
        this.carregandoEstante.set(false);
      },
    });
  }

  private async carregarEditorasCache() {
    if (this.editorasCache().length) {
      return;
    }

    const editoras = await firstValueFrom(this.api.listarEditoras());
    this.editorasCache.set(editoras);
  }

  private unificarSeriesFragmentadas(estante: EstanteEditora[]) {
    const editoras = new Map<string, EstanteEditora>();

    for (const editora of estante) {
      const chave = this.normalizarEditoraEstante(editora.nome);
      const existente = editoras.get(chave);

      if (!existente) {
        editoras.set(chave, {
          ...editora,
          series: [...editora.series],
        });
        continue;
      }

      existente.series = [...existente.series, ...editora.series];
    }

    return [...editoras.values()]
      .map((editora) => ({
        ...editora,
        series: this.unificarSeriesDaEditora(editora.series),
      }))
      .sort((a, b) => a.nome.localeCompare(b.nome));
  }

  chaveEditoraRender(editora: EstanteEditora) {
    return this.normalizarEditoraEstante(editora.nome);
  }

  chaveSerieRender(serie: EstanteSerie) {
    return this.chaveSerieEstante(serie, new Map());
  }

  private unificarSeriesDaEditora(series: EstanteSerie[]) {
    const grupos = new Map<string, EstanteSerie>();
    const volumesPorTitulo = this.volumesExplicitosPorTitulo(series);

    for (const serie of series) {
      const chave = this.chaveSerieEstante(serie, volumesPorTitulo);
      const destino = grupos.get(chave);
      const volume = this.volumeEstante(serie, volumesPorTitulo.get(this.normalizarTituloEstante(serie.titulo)));

      if (!destino) {
        grupos.set(chave, {
          ...serie,
          volume,
          edicoes: [...serie.edicoes],
        });
        continue;
      }

      destino.edicoes = this.ordenarEdicoesEstante(this.unificarEdicoesEstante([...destino.edicoes, ...serie.edicoes]));
    }

    return [...grupos.values()]
      .map((serie) => ({
        ...serie,
        edicoes: this.ordenarEdicoesEstante(serie.edicoes),
      }))
      .sort((a, b) => {
        const titulo = this.normalizarTituloEstante(a.titulo).localeCompare(this.normalizarTituloEstante(b.titulo));
        return titulo || this.volumeEstante(a) - this.volumeEstante(b);
      });
  }

  private volumesExplicitosPorTitulo(series: EstanteSerie[]) {
    const volumes = new Map<string, Set<number>>();

    for (const serie of series) {
      if (!serie.volume) {
        continue;
      }

      const titulo = this.normalizarTituloEstante(serie.titulo);
      const existentes = volumes.get(titulo) ?? new Set<number>();
      existentes.add(serie.volume);
      volumes.set(titulo, existentes);
    }

    return volumes;
  }

  private chaveSerieEstante(serie: EstanteSerie, volumesPorTitulo: Map<string, Set<number>>) {
    const titulo = this.normalizarTituloEstante(serie.titulo);
    return `${titulo}|${this.volumeEstante(serie, volumesPorTitulo.get(titulo))}`;
  }

  private volumeEstante(serie: EstanteSerie, volumesExplicitos?: Set<number>) {
    if (serie.volume) {
      return serie.volume;
    }

    if (volumesExplicitos?.size === 1) {
      return [...volumesExplicitos][0];
    }

    return 1;
  }

  private unificarEdicoesEstante(edicoes: EstanteEdicao[]) {
    return [...new Map(edicoes.map((edicao) => [edicao.itemColecaoId, edicao])).values()];
  }

  private ordenarEdicoesEstante(edicoes: EstanteEdicao[]) {
    return [...edicoes].sort((a, b) => {
      const numeroA = this.primeiroNumeroEstante(a.numero);
      const numeroB = this.primeiroNumeroEstante(b.numero);
      if (numeroA !== numeroB) {
        return numeroA - numeroB;
      }

      return this.normalizarNumeroEstante(a.numero).localeCompare(this.normalizarNumeroEstante(b.numero));
    });
  }

  private primeiroNumeroEstante(valor: string | null) {
    const encontrado = valor?.match(/\d+/);
    return encontrado ? Number(encontrado[0]) : Number.MAX_SAFE_INTEGER;
  }

  private normalizarNumeroEstante(valor: string | null) {
    return this.normalizar(valor || '').replace(/\s+/g, '');
  }

  private normalizarTituloEstante(valor: string) {
    const palavras = this.normalizar(valor).split(/\s+/).filter(Boolean);
    while (palavras.length && ['a', 'as', 'o', 'os'].includes(palavras[0])) {
      palavras.shift();
    }
    while (palavras.length && ['a', 'as', 'o', 'os'].includes(palavras[palavras.length - 1])) {
      palavras.pop();
    }
    return palavras.join(' ');
  }

  private normalizarEditoraEstante(valor: string) {
    return this.normalizar(valor)
      .split(/\s+/)
      .filter((palavra) => !['editora', 'editoras', 'comics', 'comic', 'brasil'].includes(palavra))
      .join(' ');
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

    const serie = {
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
    };
    const geracao = this.parametrosGeracaoAutomatica();

    if (geracao) {
      return await firstValueFrom(
        this.api.cadastrarSerieComEdicoes({
          serie,
          geracaoAutomaticaEdicoes: geracao,
        }),
      );
    }

    return await firstValueFrom(this.api.cadastrarSerie(serie));
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
        this.normalizar(edicao.numero) === this.normalizar(numero),
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

  private limparGeracaoAutomaticaEdicoes() {
    this.gerarEdicoesAutomaticamente = false;
    this.previewGeradoEdicoesAutomaticas = false;
    this.quantidadeEdicoesAutomaticas = null;
    this.numeroInicialEdicoesAutomaticas = 1;
    this.intervaloEdicoesAutomaticas = 1;
  }

  private parametrosGeracaoAutomatica() {
    if (!this.gerarEdicoesAutomaticamente || this.serieSelecionadaManual()) {
      return null;
    }

    const quantidade = this.quantidadeEdicoesAutomaticas;

    return {
      quantidade: Number(quantidade),
      numeroInicial: this.numeroInicialEdicoesAutomaticas ?? 1,
      intervalo: this.intervaloEdicoesAutomaticas ?? 1,
    };
  }

  private validarGeracaoAutomaticaEdicoes() {
    if (!this.gerarEdicoesAutomaticamente) {
      return true;
    }

    const parametros = this.parametrosGeracaoAutomatica();
    if (!parametros) {
      return true;
    }

    if (!Number.isInteger(parametros.quantidade) || parametros.quantidade < 1 || parametros.quantidade > 500) {
      this.mensagem.set('Quantidade de edições deve ser um número inteiro entre 1 e 500.');
      return false;
    }

    if (!Number.isInteger(parametros.numeroInicial) || parametros.numeroInicial < 0) {
      this.mensagem.set('Número inicial deve ser um número inteiro maior ou igual a zero.');
      return false;
    }

    if (!Number.isInteger(parametros.intervalo) || parametros.intervalo < 1) {
      this.mensagem.set('Intervalo da numeração deve ser um número inteiro maior que zero.');
      return false;
    }

    return true;
  }

  private numeroManualTratado() {
    return this.novaEdicaoSemNumero ? 'UNICA' : this.novaEdicaoNumero.trim();
  }

  private normalizar(valor: string | null | undefined) {
    return (valor || '')
      .normalize('NFD')
      .replace(/\p{M}/gu, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, ' ')
      .trim();
  }

  private classificarMensagem(texto: string): 'sucesso' | 'erro' | 'info' {
    const normalizado = texto
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();

    if (normalizado.includes('nao foi possivel') || normalizado.includes('verifique') || normalizado.includes('erro')) {
      return 'erro';
    }

    if (
      normalizado.includes('adicionad')
      || normalizado.includes('atualizad')
      || normalizado.includes('importad')
      || normalizado.includes('criad')
      || normalizado.includes('removid')
    ) {
      return 'sucesso';
    }

    return 'info';
  }

  private carregarConfiguracaoColecao() {
    this.api.obterConfiguracaoColecao().subscribe({
      next: (configuracao) => this.configuracaoColecao.set(configuracao),
      error: () =>
        this.configuracaoColecao.set({
          id: 0,
          visibilidadeColecao: 'PRIVADA',
          exibirValorColecao: true,
          dataCriacao: new Date().toISOString(),
          dataAtualizacao: new Date().toISOString(),
        }),
    });
  }

  private limparFormulario() {
    this.edicoesEncontradas.set([]);
    this.resultadosEncontrados.set([]);
    this.resultadosSelecionadosEmMassa.set([]);
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
    this.limparGeracaoAutomaticaEdicoes();
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
