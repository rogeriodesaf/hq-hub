import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { AssistenteFaqItem } from '../../core/modelos';

interface MensagemTela {
  autor: 'usuario' | 'assistente';
  texto: string;
}

@Component({
  selector: 'app-assistente-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Assistente</p>
        <h1>Pergunte sobre sua coleção e dados já catalogados.</h1>
      </div>
    </section>

    <section class="chat">
      @if (sugestoes().length) {
        <div class="sugestoes-assistente">
          <p class="sugestoes-titulo">Sugestoes rapidas</p>
          <div class="sugestoes-lista">
            @for (sugestao of sugestoes(); track sugestao.id) {
              <button type="button" class="botao-sugestao" (click)="usarSugestao(sugestao.pergunta)" [disabled]="carregando()">
                {{ sugestao.pergunta }}
              </button>
            }
          </div>
        </div>
      }

      <div class="mensagens">
        @for (mensagem of mensagens(); track $index) {
          <article [class.usuario]="mensagem.autor === 'usuario'">
            <p>{{ mensagem.texto }}</p>
          </article>
        }
      </div>
      <form class="entrada-chat" (ngSubmit)="perguntar()">
        <input [(ngModel)]="pergunta" name="pergunta" placeholder="Ex.: quais edições faltam na minha coleção?" />
        <button class="botao primario" type="submit" [disabled]="carregando()">
          Enviar
        </button>
      </form>
    </section>
  `,
})
export class AssistentePage {
  private static readonly TOTAL_SUGESTOES = 6;

  private readonly api = inject(ApiService);
  readonly mensagens = signal<MensagemTela[]>([
    { autor: 'assistente', texto: 'Olá. Posso ajudar com dúvidas sobre catálogo, coleção e planejamento.' },
  ]);
  readonly sugestoes = signal<AssistenteFaqItem[]>([]);
  readonly carregando = signal(false);
  pergunta = '';

  constructor() {
    this.carregarSugestoes();
  }

  usarSugestao(pergunta: string) {
    if (this.carregando()) {
      return;
    }

    this.pergunta = pergunta;
    this.perguntar();
  }

  perguntar() {
    const texto = this.pergunta.trim();
    if (!texto) {
      return;
    }

    this.mensagens.update((mensagens) => [...mensagens, { autor: 'usuario', texto }]);
    this.pergunta = '';
    this.carregando.set(true);

    this.api.perguntarAoAssistente(texto).subscribe({
      next: (resposta) => {
        this.carregando.set(false);
        this.mensagens.update((mensagens) => [...mensagens, { autor: 'assistente', texto: resposta.resposta }]);
      },
      error: () => {
        this.carregando.set(false);
        this.mensagens.update((mensagens) => [
          ...mensagens,
          { autor: 'assistente', texto: 'Não consegui responder agora. Tente novamente em instantes.' },
        ]);
      },
    });
  }

  private carregarSugestoes() {
    this.api.obterFaqAssistente().subscribe({
      next: (faq) => {
        this.sugestoes.set(faq.itens.slice(0, AssistentePage.TOTAL_SUGESTOES));
      },
      error: () => {
        this.sugestoes.set([]);
      },
    });
  }
}

