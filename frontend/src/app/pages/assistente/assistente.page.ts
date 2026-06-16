import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';

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
  private readonly api = inject(ApiService);
  readonly mensagens = signal<MensagemTela[]>([
    { autor: 'assistente', texto: 'Olá. Posso ajudar com dúvidas sobre catálogo, coleção e planejamento.' },
  ]);
  readonly carregando = signal(false);
  pergunta = '';

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
}
