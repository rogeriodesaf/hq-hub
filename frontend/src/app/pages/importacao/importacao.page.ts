import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';

import { ApiService } from '../../core/api.service';
import {
  ResultadoBackfillComicVine,
  ResultadoImportacaoCatalogo,
  Serie,
} from '../../core/modelos';

@Component({
  selector: 'app-importacao-page',
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Alimentar catálogo</p>
        <h1>Cadastre HQs pelo formulário ou importe o JSON gerado pelo robô.</h1>
      </div>
    </section>

    <section class="importacao-layout">
      <article class="bloco painel-importacao">
        <nav class="modos-importacao" aria-label="Forma de alimentação do catálogo">
          <button
            type="button"
            [class.ativo]="modoEntrada() === 'visual'"
            (click)="selecionarModo('visual')"
          >
            <strong>Cadastro visual</strong>
            <span>Preencha os campos diretamente no site</span>
          </button>
          <button
            type="button"
            [class.ativo]="modoEntrada() === 'json'"
            (click)="selecionarModo('json')"
          >
            <strong>JSON / robô</strong>
            <span>Mantenha o processo que você já usa hoje</span>
          </button>
        </nav>

        <div class="secao-titulo">
          <div>
            <h2>{{ modoEntrada() === 'visual' ? 'Cadastro visual da HQ' : 'JSON do robô' }}</h2>
            <p class="texto-suave">
              @if (modoEntrada() === 'visual') {
                Preencha a série, as edições e as histórias. O HQ-HUB monta e envia o JSON por você.
              } @else {
                Carregue o arquivo gerado em rascunhos ou cole o conteúdo revisado, como você já faz hoje.
              }
            </p>
          </div>
        </div>

        @if (modoEntrada() === 'json') {
          <div class="acoes-importacao">
            <label class="botao secundario compacto seletor-arquivo">
              Selecionar JSON
              <input type="file" accept="application/json,.json" (change)="selecionarArquivo($event)" />
            </label>
            <button class="botao compacto" type="button" (click)="preencherModeloEmBranco()">
              Modelo em branco
            </button>
            <button class="botao compacto" type="button" (click)="adicionarHistoriaAoModelo()" [disabled]="!jsonTexto.trim()">
              + História no JSON
            </button>
          </div>
        }

        @if (modoEntrada() === 'visual') {
        <section class="editor-visual-importacao">
          <aside class="dica-importacao-colaborador">
            <strong>Guia rápido para colaboradores</strong>
            <p>
              Use este formulario quando a edicao tiver historias ou publicacoes originais. Preencha serie, editora e volume com cuidado:
              o volume diferencia fases com o mesmo titulo, como V1 e V2.
            </p>
            <p>
              Para capa, nao use URL direta de imagem do Guia dos Quadrinhos, pois o site costuma bloquear acesso externo.
              Prefira URLs de capa da Panini, Amazon ou outra fonte que carregue fora do site.
            </p>
          </aside>
          <div class="grade-importacao-visual">
            <label>
              Arquivo de origem
              <small>origem.arquivoEntrada</small>
              <input [(ngModel)]="visualImportacao.origem.arquivoEntrada" name="visualOrigemArquivo" />
            </label>
            <label class="campo-largo">
              URL da fonte
              <small>origem.url</small>
              <input [(ngModel)]="visualImportacao.origem.url" name="visualOrigemUrl" placeholder="https://..." />
            </label>
            <label>
              Titulo da serie
              <small>serieBrasileira.titulo</small>
              <input [(ngModel)]="visualImportacao.serieBrasileira.titulo" name="visualSerieTitulo" />
            </label>
            <label>
              Fase
              <small>serieBrasileira.fase</small>
              <input [(ngModel)]="visualImportacao.serieBrasileira.fase" name="visualSerieFase" />
            </label>
            <label>
              Editora
              <small>serieBrasileira.editora</small>
              <input [(ngModel)]="visualImportacao.serieBrasileira.editora" name="visualSerieEditora" />
            </label>
            <label>
              Volume
              <small>serieBrasileira.volume</small>
              <input type="number" min="1" [(ngModel)]="visualImportacao.serieBrasileira.volume" name="visualSerieVolume" />
            </label>
            <label>
              Total de edicoes
              <small>totalEdicoes</small>
              <input type="number" [ngModel]="visualImportacao.edicoes.length" name="visualTotalEdicoes" disabled />
            </label>
            <label>
              Total de historias
              <small>totalHistorias</small>
              <input type="number" [ngModel]="totalHistoriasVisual()" name="visualTotalHistorias" disabled />
            </label>
          </div>

          <section class="edicoes-visuais">
            <div class="secao-titulo compacta">
              <h3>Edicoes</h3>
              <button class="botao compacto" type="button" (click)="adicionarEdicaoVisual()">+ Edicao</button>
            </div>

            @for (edicao of visualImportacao.edicoes; track $index; let indiceEdicao = $index) {
              <article class="edicao-visual">
                <div class="secao-titulo compacta">
                  <strong>Edicao {{ indiceEdicao + 1 }}</strong>
                  <button class="botao perigo compacto" type="button" (click)="removerEdicaoVisual(indiceEdicao)" [disabled]="visualImportacao.edicoes.length === 1">Remover</button>
                </div>
                <div class="grade-importacao-visual">
                  <label>
                    Numero
                    <small>edicoes[{{ indiceEdicao }}].numero</small>
                    <input [(ngModel)]="edicao.numero" [name]="'visualEdicaoNumero' + indiceEdicao" />
                  </label>
                  <label>
                    Titulo de chamada
                    <small>edicoes[{{ indiceEdicao }}].tituloChamada</small>
                    <input [(ngModel)]="edicao.tituloChamada" [name]="'visualEdicaoTitulo' + indiceEdicao" />
                  </label>
                  <label>
                    Data
                    <small>edicoes[{{ indiceEdicao }}].dataPublicacao</small>
                    <input type="date" [(ngModel)]="edicao.dataPublicacao" [name]="'visualEdicaoData' + indiceEdicao" />
                  </label>
                  <label>
                    Publicado texto
                    <small>edicoes[{{ indiceEdicao }}].publicadoTexto</small>
                    <input [(ngModel)]="edicao.publicadoTexto" [name]="'visualEdicaoPublicado' + indiceEdicao" />
                  </label>
                  <label>
                    Editora
                    <small>edicoes[{{ indiceEdicao }}].editora</small>
                    <input [(ngModel)]="edicao.editora" [name]="'visualEdicaoEditora' + indiceEdicao" />
                  </label>
                  <label>
                    Licenciador
                    <small>edicoes[{{ indiceEdicao }}].licenciador</small>
                    <input [(ngModel)]="edicao.licenciador" [name]="'visualEdicaoLicenciador' + indiceEdicao" />
                  </label>
                  <label>
                    Categoria
                    <small>edicoes[{{ indiceEdicao }}].categoria</small>
                    <input [(ngModel)]="edicao.categoria" [name]="'visualEdicaoCategoria' + indiceEdicao" />
                  </label>
                  <label>
                    Genero
                    <small>edicoes[{{ indiceEdicao }}].genero</small>
                    <input [(ngModel)]="edicao.genero" [name]="'visualEdicaoGenero' + indiceEdicao" />
                  </label>
                  <label>
                    Status
                    <small>edicoes[{{ indiceEdicao }}].status</small>
                    <input [(ngModel)]="edicao.status" [name]="'visualEdicaoStatus' + indiceEdicao" />
                  </label>
                  <label>
                    Paginas
                    <small>edicoes[{{ indiceEdicao }}].numeroPaginas</small>
                    <input type="number" min="1" [(ngModel)]="edicao.numeroPaginas" [name]="'visualEdicaoPaginas' + indiceEdicao" />
                  </label>
                  <label>
                    Formato
                    <small>edicoes[{{ indiceEdicao }}].formato</small>
                    <input [(ngModel)]="edicao.formato" [name]="'visualEdicaoFormato' + indiceEdicao" />
                  </label>
                  <label>
                    Preco de capa
                    <small>edicoes[{{ indiceEdicao }}].precoCapa</small>
                    <input type="number" min="0" step="0.01" [(ngModel)]="edicao.precoCapa" [name]="'visualEdicaoPreco' + indiceEdicao" />
                  </label>
                  <label class="campo-largo">
                    URL da capa
                    <small>edicoes[{{ indiceEdicao }}].urlCapa</small>
                    <input [(ngModel)]="edicao.urlCapa" [name]="'visualEdicaoCapa' + indiceEdicao" placeholder="https://..." />
                  </label>
                  <label class="campo-largo">
                    Descricao
                    <small>edicoes[{{ indiceEdicao }}].descricao</small>
                    <textarea rows="3" [(ngModel)]="edicao.descricao" [name]="'visualEdicaoDescricao' + indiceEdicao"></textarea>
                  </label>
                </div>

                <section class="historias-visuais">
                  <div class="secao-titulo compacta">
                    <strong>Historias</strong>
                    <button class="botao compacto" type="button" (click)="adicionarHistoriaVisual(edicao)">+ Historia</button>
                  </div>
                  @for (historia of edicao.historias; track $index; let indiceHistoria = $index) {
                    <article class="historia-visual">
                      <div class="secao-titulo compacta">
                        <span>Historia {{ indiceHistoria + 1 }}</span>
                        <button class="botao perigo compacto" type="button" (click)="removerHistoriaVisual(edicao, indiceHistoria)" [disabled]="edicao.historias.length === 1">Remover</button>
                      </div>
                      <div class="grade-importacao-visual">
                        <label>
                          Ordem
                          <small>historias[{{ indiceHistoria }}].ordem</small>
                          <input type="number" min="1" [(ngModel)]="historia.ordem" [name]="'visualHistoriaOrdem' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Titulo em portugues
                          <small>historias[{{ indiceHistoria }}].tituloPortugues</small>
                          <input [(ngModel)]="historia.tituloPortugues" [name]="'visualHistoriaTituloPt' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Titulo original
                          <small>historias[{{ indiceHistoria }}].tituloOriginal</small>
                          <input [(ngModel)]="historia.tituloOriginal" [name]="'visualHistoriaTituloOriginal' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Paginas
                          <small>historias[{{ indiceHistoria }}].quantidadePaginas</small>
                          <input type="number" min="1" [(ngModel)]="historia.quantidadePaginas" [name]="'visualHistoriaPaginas' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label class="campo-largo">
                          Resumo
                          <small>historias[{{ indiceHistoria }}].resumo</small>
                          <textarea rows="3" [(ngModel)]="historia.resumo" [name]="'visualHistoriaResumo' + indiceEdicao + '-' + indiceHistoria"></textarea>
                        </label>
                        <label>
                          Serie original
                          <small>publicacaoOriginal.serieOriginal</small>
                          <input [(ngModel)]="historia.publicacaoOriginal.serieOriginal" [name]="'visualHistoriaSerieOriginal' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Numero original
                          <small>publicacaoOriginal.numeroOriginal</small>
                          <input [(ngModel)]="historia.publicacaoOriginal.numeroOriginal" [name]="'visualHistoriaNumeroOriginal' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Ano original
                          <small>publicacaoOriginal.anoOriginal</small>
                          <input type="number" min="1900" [(ngModel)]="historia.publicacaoOriginal.anoOriginal" [name]="'visualHistoriaAnoOriginal' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <label>
                          Texto da publicacao
                          <small>publicacaoOriginal.texto</small>
                          <input [(ngModel)]="historia.publicacaoOriginal.texto" [name]="'visualHistoriaTextoOriginal' + indiceEdicao + '-' + indiceHistoria" />
                        </label>
                        <details class="dados-avancados campo-largo">
                          <summary>Outros dados da publicação original</summary>
                          <div class="grade-importacao-visual">
                            <label>
                              ID Comic Vine
                              <small>publicacaoOriginal.idComicVine</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.idComicVine" [name]="'visualHistoriaComicVineId' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label class="campo-largo">
                              URL Comic Vine
                              <small>publicacaoOriginal.urlComicVine</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.urlComicVine" [name]="'visualHistoriaComicVineUrl' + indiceEdicao + '-' + indiceHistoria" placeholder="https://..." />
                            </label>
                            <label class="campo-largo">
                              URL da fonte
                              <small>publicacaoOriginal.urlOrigem</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.urlOrigem" [name]="'visualHistoriaUrlOrigem' + indiceEdicao + '-' + indiceHistoria" placeholder="https://..." />
                            </label>
                            <label class="campo-largo">
                              URL da capa original
                              <small>publicacaoOriginal.urlCapa</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.urlCapa" [name]="'visualHistoriaUrlCapa' + indiceEdicao + '-' + indiceHistoria" placeholder="https://..." />
                            </label>
                            <label class="campo-largo">
                              URL de compra na Amazon
                              <small>publicacaoOriginal.urlCompraAmazon</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.urlCompraAmazon" [name]="'visualHistoriaUrlAmazon' + indiceEdicao + '-' + indiceHistoria" placeholder="https://..." />
                            </label>
                            <label>
                              Preço na Amazon
                              <small>publicacaoOriginal.precoCompraAmazon</small>
                              <input type="number" min="0" step="0.01" [(ngModel)]="historia.publicacaoOriginal.precoCompraAmazon" [name]="'visualHistoriaPrecoAmazon' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label>
                              Data de captura do preço
                              <small>publicacaoOriginal.dataCapturacaoPrecoCompraAmazon</small>
                              <input type="date" [(ngModel)]="historia.publicacaoOriginal.dataCapturacaoPrecoCompraAmazon" [name]="'visualHistoriaDataPrecoAmazon' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label>
                              Título da publicação
                              <small>publicacaoOriginal.titulo</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.titulo" [name]="'visualHistoriaPublicacaoTitulo' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label>
                              Nome do volume
                              <small>publicacaoOriginal.nomeVolume</small>
                              <input [(ngModel)]="historia.publicacaoOriginal.nomeVolume" [name]="'visualHistoriaNomeVolume' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label>
                              Data de capa
                              <small>publicacaoOriginal.dataCapa</small>
                              <input type="date" [(ngModel)]="historia.publicacaoOriginal.dataCapa" [name]="'visualHistoriaDataCapa' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label>
                              Data de venda
                              <small>publicacaoOriginal.dataVenda</small>
                              <input type="date" [(ngModel)]="historia.publicacaoOriginal.dataVenda" [name]="'visualHistoriaDataVenda' + indiceEdicao + '-' + indiceHistoria" />
                            </label>
                            <label class="campo-largo">
                              Descrição original
                              <small>publicacaoOriginal.descricaoOriginal</small>
                              <textarea rows="3" [(ngModel)]="historia.publicacaoOriginal.descricaoOriginal" [name]="'visualHistoriaDescricaoOriginal' + indiceEdicao + '-' + indiceHistoria"></textarea>
                            </label>
                            <label class="campo-largo">
                              Descrição em português
                              <small>publicacaoOriginal.descricaoPortugues</small>
                              <textarea rows="3" [(ngModel)]="historia.publicacaoOriginal.descricaoPortugues" [name]="'visualHistoriaDescricaoPortugues' + indiceEdicao + '-' + indiceHistoria"></textarea>
                            </label>
                          </div>
                        </details>
                      </div>
                    </article>
                  }
                </section>
              </article>
            }
          </section>

          <div class="acoes-importacao">
            <button class="botao compacto secundario" type="button" (click)="baixarJsonVisual()">Baixar cópia em JSON</button>
          </div>
        </section>
        }

        @if (modoEntrada() === 'json') {
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
        }

        @if (mensagem()) {
          <p class="mensagem-importacao" [class.sucesso]="tipoMensagem() === 'sucesso'" [class.erro]="tipoMensagem() === 'erro'">{{ mensagem() }}</p>
        }

        <div class="rodape-importacao">
          @if (modoEntrada() === 'visual') {
            <button class="botao primario" type="button" (click)="importarVisual()" [disabled]="importando()">
              {{ importando() ? 'Cadastrando...' : 'Cadastrar no catálogo' }}
            </button>
          } @else {
            <button class="botao primario" type="button" (click)="importar()" [disabled]="importando() || !jsonTexto.trim()">
              {{ importando() ? 'Importando...' : 'Importar para o catálogo' }}
            </button>
          }
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
            <a class="botao compacto" routerLink="/catalogo" [queryParams]="{ serieId: resultado()?.serieId }">Abrir no catálogo</a>
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

    .modos-importacao {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 10px;
    }

    .modos-importacao button {
      display: grid;
      gap: 4px;
      padding: 14px;
      text-align: left;
      color: var(--texto);
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
      cursor: pointer;
    }

    .modos-importacao button.ativo {
      border-color: var(--primaria);
      background: rgba(37, 99, 235, 0.1);
      box-shadow: inset 0 0 0 1px var(--primaria);
    }

    .modos-importacao span {
      color: var(--texto-suave);
      font-size: 0.82rem;
      line-height: 1.35;
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

    .editor-visual-importacao,
    .edicao-visual,
    .historia-visual {
      display: grid;
      gap: 14px;
      padding: 14px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie-suave);
    }

    .dica-importacao-colaborador {
      display: grid;
      gap: 6px;
      padding: 12px;
      border: 1px solid rgba(255, 135, 31, 0.34);
      border-radius: 8px;
      background: rgba(255, 135, 31, 0.1);
      color: var(--texto);
    }

    .dica-importacao-colaborador p {
      margin: 0;
      color: var(--texto-suave);
      line-height: 1.45;
    }

    .grade-importacao-visual {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 10px;
    }

    .grade-importacao-visual label {
      display: grid;
      gap: 5px;
      min-width: 0;
      color: var(--texto);
      font-size: 0.9rem;
      font-weight: 750;
    }

    .grade-importacao-visual small {
      color: var(--texto-suave);
      font-size: 0.76rem;
      font-weight: 700;
      overflow-wrap: anywhere;
    }

    .campo-largo {
      grid-column: 1 / -1;
    }

    .dados-avancados {
      padding: 12px;
      border: 1px dashed var(--borda);
      border-radius: 8px;
      background: var(--superficie);
    }

    .dados-avancados summary {
      cursor: pointer;
      font-weight: 800;
    }

    .dados-avancados[open] summary {
      margin-bottom: 12px;
    }

    .edicoes-visuais,
    .historias-visuais {
      display: grid;
      gap: 12px;
    }

    .edicao-visual {
      background: var(--superficie);
    }

    .historia-visual {
      background: var(--superficie-2);
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

    .mensagem-importacao {
      margin: 0;
      padding: 12px 14px;
      border-radius: 8px;
      border: 1px solid var(--borda);
      font-weight: 700;
    }

    .mensagem-importacao.sucesso {
      border-color: rgba(22, 163, 74, 0.35);
      background: rgba(22, 163, 74, 0.12);
      color: #15803d;
    }

    .mensagem-importacao.erro {
      border-color: rgba(220, 38, 38, 0.32);
      background: rgba(220, 38, 38, 0.1);
      color: #b91c1c;
    }

    @media (max-width: 900px) {
      .importacao-layout {
        grid-template-columns: 1fr;
      }

      .grade-importacao-visual {
        grid-template-columns: 1fr;
      }

      .modos-importacao {
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
  readonly tipoMensagem = computed(() => this.classificarMensagem(this.mensagem()));
  readonly importando = signal(false);
  readonly gerandoRascunho = signal(false);
  readonly nomeArquivo = signal('');
  readonly modoEntrada = signal<'visual' | 'json'>('visual');
  readonly buscandoSeriesCapa = signal(false);
  readonly salvandoCapaCatalogo = signal(false);
  readonly seriesCapa = signal<Serie[]>([]);
  readonly serieCapaSelecionada = signal<Serie | null>(null);
  buscaSerieCapa = '';
  numeroEdicaoCapa = '';
  urlCapaManual = '';
  jsonTexto = '';
  rascunho = {
    urlGuia: '',
    urlPaniniInicial: '',
    quantidade: 1,
    tituloSerie: '',
    fase: '',
    editora: 'Panini',
    volume: 1,
  };
  visualImportacao: any = this.modeloImportacao();

  selecionarModo(modo: 'visual' | 'json') {
    if (modo === this.modoEntrada()) {
      return;
    }

    if (modo === 'json') {
      this.atualizarJsonPeloVisual(false);
    } else if (this.jsonTexto.trim()) {
      this.carregarVisualDoJson(false);
    }
    this.modoEntrada.set(modo);
    this.mensagem.set('');
  }

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
      this.carregarVisualDoJson(false);
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
    this.carregarVisualDoJson(false);
    this.mensagem.set('Exemplo estrutural carregado. Para importar de verdade, selecione o JSON completo gerado pelo robô.');
  }

  preencherModeloEmBranco() {
    this.visualImportacao = this.modeloImportacao();
    this.jsonTexto = JSON.stringify(this.visualImportacao, null, 2);
    this.nomeArquivo.set('modelo-importacao-hqhub.json');
    this.resultado.set(null);
    this.mensagem.set('Modelo em branco carregado. Preencha serie, editora e numero da edicao antes de importar.');
  }

  adicionarHistoriaAoModelo() {
    this.mensagem.set('');
    let corpo: any;
    try {
      corpo = JSON.parse(this.jsonTexto);
    } catch {
      this.mensagem.set('Carregue um JSON valido antes de adicionar historia.');
      return;
    }

    if (!Array.isArray(corpo.edicoes)) {
      corpo.edicoes = [this.modeloEdicao()];
    }
    if (!corpo.edicoes.length) {
      corpo.edicoes.push(this.modeloEdicao());
    }
    if (!Array.isArray(corpo.edicoes[0].historias)) {
      corpo.edicoes[0].historias = [];
    }

    corpo.edicoes[0].historias.push(this.modeloHistoria(corpo.edicoes[0].historias.length + 1));
    corpo.totalHistorias = corpo.edicoes.reduce((total: number, edicao: any) => total + (Array.isArray(edicao.historias) ? edicao.historias.length : 0), 0);
    this.jsonTexto = JSON.stringify(corpo, null, 2);
    this.visualImportacao = this.completarVisualImportacao(corpo);
    this.mensagem.set('Historia adicionada ao JSON carregado.');
  }

  gerarRascunhoPeloRobo() {
    this.mensagem.set('');
    this.resultado.set(null);

    const validacao = this.validarGeracaoRascunho();
    if (validacao) {
      this.mensagem.set(validacao);
      return;
    }

    this.gerandoRascunho.set(true);
    this.api.gerarRascunhoImportacao({
      urlGuia: this.rascunho.urlGuia.trim(),
      urlPaniniInicial: this.rascunho.urlPaniniInicial.trim() || null,
      quantidade: Number(this.rascunho.quantidade),
      tituloSerie: this.rascunho.tituloSerie.trim(),
      fase: this.rascunho.fase.trim() || null,
      editora: this.rascunho.editora.trim(),
      volume: this.rascunho.volume ? Number(this.rascunho.volume) : null,
    }).subscribe({
      next: (rascunho) => {
        this.jsonTexto = JSON.stringify(rascunho, null, 2);
        this.nomeArquivo.set('rascunho-gerado-pelo-robo.json');
        this.carregarVisualDoJson(false);
        this.gerandoRascunho.set(false);
        this.mensagem.set('JSON gerado pelo robo. Revise o conteudo antes de importar para o catalogo.');
      },
      error: (erro) => {
        this.gerandoRascunho.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel gerar o rascunho pelo robo.');
      },
    });
  }

  async importar() {
    this.mensagem.set('');
    this.resultado.set(null);

    let corpo: any;
    try {
      corpo = JSON.parse(this.jsonTexto);
    } catch {
      this.mensagem.set('O conteúdo informado não é um JSON válido.');
      return;
    }

    const validacao = this.validarMinimoImportacao(corpo);
    if (validacao) {
      this.mensagem.set(validacao);
      return;
    }

    corpo = this.normalizarImportacao(corpo);
    this.jsonTexto = JSON.stringify(corpo, null, 2);

    const lotes = this.criarLotesImportacao(corpo);
    this.importando.set(true);
    let acumulado: ResultadoImportacaoCatalogo | null = null;
    let loteAtual = 0;

    try {
      for (let indice = 0; indice < lotes.length; indice++) {
        loteAtual = indice + 1;
        this.mensagem.set(`Importando lote ${indice + 1} de ${lotes.length}...`);
        const resultadoLote = await firstValueFrom(
          this.api.importarCatalogo(lotes[indice], indice === lotes.length - 1),
        );
        acumulado = this.somarResultadosImportacao(acumulado, resultadoLote);
        this.resultado.set(acumulado);
      }

      const resumoCapas = await this.executarBackfillCapasComicVine(acumulado);
      this.mensagem.set(
        `Importação feita com sucesso em ${lotes.length} lote(s). A série já está disponível no catálogo. ${resumoCapas}`,
      );
    } catch (erro: any) {
      const concluidos = acumulado
        ? 'Os lotes anteriores foram salvos e podem ser reenviados com segurança. '
        : '';
      const detalhe = erro?.error?.mensagem || 'Não foi possível importar o catálogo.';
      this.mensagem.set(`Falha no lote ${loteAtual} de ${lotes.length}. ${concluidos}${detalhe}`);
    } finally {
      this.importando.set(false);
    }
  }

  importarVisual() {
    this.atualizarJsonPeloVisual(false);
    return this.importar();
  }

  baixarJsonVisual() {
    this.atualizarJsonPeloVisual(false);
    const titulo = String(this.visualImportacao?.serieBrasileira?.titulo || 'catalogo-hqhub')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
    const arquivo = new Blob([this.jsonTexto], { type: 'application/json;charset=utf-8' });
    const url = URL.createObjectURL(arquivo);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${titulo || 'catalogo-hqhub'}.json`;
    link.click();
    URL.revokeObjectURL(url);
    this.mensagem.set('Cópia em JSON gerada a partir do formulário visual.');
  }

  private async executarBackfillCapasComicVine(
    resultadoImportacao: ResultadoImportacaoCatalogo | null,
  ): Promise<string> {
    if (!resultadoImportacao?.serieId) {
      return 'O enriquecimento de capas ficou pendente porque a série não retornou um identificador.';
    }

    let cursor: number | null = null;
    let processadas = 0;
    let atualizadas = 0;
    let semCorrespondencia = 0;
    const avisos: string[] = [];

    try {
      do {
        this.mensagem.set(
          `Catálogo importado. Enriquecendo capas da Comic Vine: ${processadas} processada(s)...`,
        );
        const lote: ResultadoBackfillComicVine = await firstValueFrom(
          this.api.preencherCapasComicVineImportacao(resultadoImportacao.serieId, cursor),
        );
        processadas += lote.processadas;
        atualizadas += lote.atualizadas;
        semCorrespondencia += lote.semCorrespondencia;
        avisos.push(...(lote.avisos || []));
        cursor = lote.proximoCursor;

        if (!lote.possuiMais) {
          break;
        }

        await new Promise((resolve) => setTimeout(resolve, 250));
      } while (processadas < 5000);

      if (avisos.length) {
        this.resultado.set({
          ...resultadoImportacao,
          avisos: [...(resultadoImportacao.avisos || []), ...avisos.slice(0, 50)],
        });
      }

      return `Comic Vine: ${atualizadas} capa(s) atualizada(s) e ${semCorrespondencia} sem correspondência segura.`;
    } catch (erro: any) {
      if (erro?.status === 403) {
        return 'As capas da Comic Vine ficaram pendentes porque o backfill exige perfil de administrador.';
      }
      const detalhe = erro?.error?.mensagem || 'falha temporária';
      return `As capas da Comic Vine poderão ser retomadas depois (${detalhe}).`;
    }
  }

  private criarLotesImportacao(corpo: any) {
    const maximoHistoriasPorLote = 20;
    const lotes: any[] = [];

    for (const edicao of corpo.edicoes || []) {
      const historias = Array.isArray(edicao.historias) ? edicao.historias : [];
      const grupos = historias.length
        ? Array.from(
            { length: Math.ceil(historias.length / maximoHistoriasPorLote) },
            (_, indice) =>
              historias.slice(
                indice * maximoHistoriasPorLote,
                (indice + 1) * maximoHistoriasPorLote,
              ),
          )
        : [[]];

      for (const grupo of grupos) {
        lotes.push({
          ...corpo,
          totalEdicoes: 1,
          totalHistorias: grupo.length,
          avisos: lotes.length === 0 ? corpo.avisos || [] : [],
          edicoes: [{ ...edicao, historias: grupo }],
        });
      }
    }

    return lotes;
  }

  private somarResultadosImportacao(
    acumulado: ResultadoImportacaoCatalogo | null,
    atual: ResultadoImportacaoCatalogo,
  ): ResultadoImportacaoCatalogo {
    if (!acumulado) {
      return { ...atual, avisos: [...(atual.avisos || [])] };
    }

    return {
      serieId: acumulado.serieId || atual.serieId,
      serieTitulo: acumulado.serieTitulo || atual.serieTitulo,
      editorasCriadas: acumulado.editorasCriadas + atual.editorasCriadas,
      seriesCriadas: acumulado.seriesCriadas + atual.seriesCriadas,
      edicoesCriadas: acumulado.edicoesCriadas + atual.edicoesCriadas,
      edicoesAtualizadas: acumulado.edicoesAtualizadas + atual.edicoesAtualizadas,
      historiasCriadas: acumulado.historiasCriadas + atual.historiasCriadas,
      conteudosCriados: acumulado.conteudosCriados + atual.conteudosCriados,
      publicacoesCriadas: acumulado.publicacoesCriadas + atual.publicacoesCriadas,
      itensReaproveitados: acumulado.itensReaproveitados + atual.itensReaproveitados,
      avisos: [...(acumulado.avisos || []), ...(atual.avisos || [])],
    };
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
    this.visualImportacao = this.modeloImportacao();
    this.nomeArquivo.set('');
    this.resultado.set(null);
    this.mensagem.set('');
    this.buscaSerieCapa = '';
    this.seriesCapa.set([]);
    this.serieCapaSelecionada.set(null);
    this.numeroEdicaoCapa = '';
    this.urlCapaManual = '';
  }

  totalHistoriasVisual() {
    return (this.visualImportacao.edicoes || [])
      .reduce((total: number, edicao: any) => total + (Array.isArray(edicao.historias) ? edicao.historias.length : 0), 0);
  }

  adicionarEdicaoVisual() {
    this.visualImportacao.edicoes.push(this.modeloEdicao());
    this.atualizarTotaisVisuais();
  }

  removerEdicaoVisual(indice: number) {
    if (this.visualImportacao.edicoes.length <= 1) {
      return;
    }

    this.visualImportacao.edicoes.splice(indice, 1);
    this.atualizarTotaisVisuais();
  }

  adicionarHistoriaVisual(edicao: any) {
    if (!Array.isArray(edicao.historias)) {
      edicao.historias = [];
    }

    edicao.historias.push(this.modeloHistoria(edicao.historias.length + 1));
    this.atualizarTotaisVisuais();
  }

  removerHistoriaVisual(edicao: any, indice: number) {
    if (!Array.isArray(edicao.historias) || edicao.historias.length <= 1) {
      return;
    }

    edicao.historias.splice(indice, 1);
    this.atualizarTotaisVisuais();
  }

  atualizarJsonPeloVisual(exibirMensagem = true) {
    this.atualizarTotaisVisuais();
    this.jsonTexto = JSON.stringify(this.visualImportacao, null, 2);
    if (exibirMensagem) {
      this.mensagem.set('JSON atualizado a partir do formulário visual.');
    }
  }

  carregarVisualDoJson(exibirMensagem = true) {
    try {
      const corpo = JSON.parse(this.jsonTexto);
      this.visualImportacao = this.completarVisualImportacao(corpo);
      this.atualizarTotaisVisuais();
      if (exibirMensagem) {
        this.mensagem.set('Formulario visual carregado a partir do JSON.');
      }
    } catch {
      if (exibirMensagem) {
        this.mensagem.set('Nao foi possivel carregar o formulario porque o JSON esta invalido.');
      }
    }
  }

  private atualizarTotaisVisuais() {
    if (!Array.isArray(this.visualImportacao.edicoes) || !this.visualImportacao.edicoes.length) {
      this.visualImportacao.edicoes = [this.modeloEdicao()];
    }

    this.visualImportacao.totalEdicoes = this.visualImportacao.edicoes.length;
    this.visualImportacao.totalHistorias = this.totalHistoriasVisual();
    if (this.visualImportacao.origem?.url) {
      this.visualImportacao.origem.urlsProcessadas = [this.visualImportacao.origem.url];
    }
    if (this.visualImportacao.origem) {
      this.visualImportacao.origem.geradoEm = this.visualImportacao.origem.geradoEm || new Date().toISOString().slice(0, 10);
      this.visualImportacao.origem.gerador = this.visualImportacao.origem.gerador || 'HQ-HUB formulario visual';
    }
  }

  private completarVisualImportacao(corpo: any) {
    const modelo = this.modeloImportacao();
    const origem = { ...modelo.origem, ...(corpo?.origem || {}) };
    const serieBrasileira = { ...modelo.serieBrasileira, ...(corpo?.serieBrasileira || {}) };
    const edicoes = Array.isArray(corpo?.edicoes) && corpo.edicoes.length ? corpo.edicoes : [this.modeloEdicao()];

    return {
      ...modelo,
      ...corpo,
      origem,
      serieBrasileira,
      avisos: Array.isArray(corpo?.avisos) ? corpo.avisos : [],
      edicoes: edicoes.map((edicao: any) => ({
        ...this.modeloEdicao(),
        ...edicao,
        historias: Array.isArray(edicao?.historias) && edicao.historias.length
          ? edicao.historias.map((historia: any, indice: number) => ({
              ...this.modeloHistoria(indice + 1),
              ...historia,
              publicacaoOriginal: {
                ...this.modeloHistoria(indice + 1).publicacaoOriginal,
                ...(historia?.publicacaoOriginal || {}),
              },
            }))
          : [this.modeloHistoria(1)],
      })),
    };
  }

  private modeloImportacao() {
    return {
      origem: {
        arquivoEntrada: '',
        url: '',
        urlsProcessadas: [],
        geradoEm: new Date().toISOString().slice(0, 10),
        gerador: 'HQ-HUB',
      },
      serieBrasileira: {
        titulo: '',
        fase: '',
        editora: '',
        volume: null,
      },
      totalEdicoes: 1,
      totalHistorias: 1,
      avisos: [],
      edicoes: [this.modeloEdicao()],
    };
  }

  private modeloEdicao() {
    return {
      numero: '',
      tituloChamada: '',
      dataPublicacao: null,
      publicadoTexto: '',
      editora: '',
      licenciador: '',
      categoria: '',
      genero: '',
      status: '',
      numeroPaginas: null,
      formato: '',
      precoCapa: null,
      urlCapa: '',
      descricao: '',
      historias: [this.modeloHistoria(1)],
    };
  }

  private modeloHistoria(ordem: number) {
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
        idComicVine: '',
        urlComicVine: '',
        urlOrigem: '',
        urlCapa: '',
        urlCompraAmazon: '',
        precoCompraAmazon: null,
        dataCapturacaoPrecoCompraAmazon: null,
        titulo: '',
        nomeVolume: '',
        dataCapa: null,
        dataVenda: null,
        descricaoOriginal: '',
        descricaoPortugues: '',
      },
    };
  }

  private validarMinimoImportacao(corpo: any) {
    if (!corpo?.serieBrasileira?.titulo?.trim()) {
      return 'Preencha serieBrasileira.titulo antes de importar.';
    }
    if (!corpo?.serieBrasileira?.editora?.trim()) {
      return 'Preencha serieBrasileira.editora antes de importar.';
    }
    if (!Array.isArray(corpo.edicoes) || !corpo.edicoes.length) {
      return 'Inclua pelo menos uma edicao no JSON.';
    }

    const edicaoSemNumero = corpo.edicoes.findIndex((edicao: any) => !String(edicao?.numero || '').trim());
    if (edicaoSemNumero >= 0) {
      return `Preencha edicoes[${edicaoSemNumero}].numero antes de importar.`;
    }
    return '';
  }

  private classificarMensagem(mensagem: string) {
    const normalizada = mensagem
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();

    if (!normalizada.trim()) {
      return 'info';
    }

    if (normalizada.includes('sucesso') || normalizada.includes('atualizada') || normalizada.includes('carregado') || normalizada.includes('adicionada')) {
      return 'sucesso';
    }

    if (normalizada.includes('nao foi possivel') || normalizada.includes('erro') || normalizada.includes('invalido') || normalizada.includes('preencha') || normalizada.includes('informe')) {
      return 'erro';
    }

    return 'info';
  }

  private validarGeracaoRascunho() {
    if (!this.rascunho.urlGuia.trim()) {
      return 'Informe a URL do Guia antes de gerar o JSON.';
    }
    if (!this.rascunho.tituloSerie.trim()) {
      return 'Informe o titulo da serie antes de gerar o JSON.';
    }
    if (!this.rascunho.editora.trim()) {
      return 'Informe a editora antes de gerar o JSON.';
    }
    if (!Number(this.rascunho.quantidade) || Number(this.rascunho.quantidade) < 1) {
      return 'Informe uma quantidade de edicoes maior que zero.';
    }
    return '';
  }

  private normalizarImportacao(corpo: any) {
    const normalizado = this.removerVazios(corpo);
    normalizado.edicoes = (normalizado.edicoes || []).map((edicao: any) => ({
      ...edicao,
      historias: this.normalizarHistorias(edicao.historias),
    }));
    normalizado.totalEdicoes = normalizado.edicoes.length;
    normalizado.totalHistorias = normalizado.edicoes.reduce((total: number, edicao: any) => total + (edicao.historias?.length || 0), 0);
    return normalizado;
  }

  private normalizarHistorias(historias: any[] | null | undefined) {
    if (!Array.isArray(historias)) {
      return [];
    }

    return historias
      .map((historia) => this.removerVazios(historia))
      .filter((historia) => this.historiaTemMinimo(historia));
  }

  private historiaTemMinimo(historia: any) {
    return !!historia?.tituloPortugues
      && !!historia?.publicacaoOriginal?.serieOriginal
      && !!historia?.publicacaoOriginal?.numeroOriginal;
  }

  private removerVazios(valor: any): any {
    if (Array.isArray(valor)) {
      return valor.map((item) => this.removerVazios(item)).filter((item) => item !== null);
    }
    if (valor && typeof valor === 'object') {
      return Object.entries(valor).reduce<Record<string, any>>((objeto, [chave, item]) => {
        const tratado = this.removerVazios(item);
        if (tratado !== null) {
          objeto[chave] = tratado;
        }
        return objeto;
      }, {});
    }
    if (typeof valor === 'string') {
      const texto = valor.trim();
      return texto ? texto : null;
    }
    return valor ?? null;
  }
}
