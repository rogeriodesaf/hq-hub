import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { Usuario } from '../../core/modelos';

@Component({
  selector: 'app-colaboradores-page',
  imports: [CommonModule, FormsModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Colaboradores</p>
        <h1>Seja colaborador do HQ-HUB.</h1>
      </div>
    </section>

    @if (ehAdministrador()) {
      <section class="bloco painel-admin-colaboradores">
        <div class="secao-titulo">
          <div>
            <h2>Cadastrar colaborador</h2>
            <p class="texto-suave">Promova um usuario existente ou crie um novo acesso com permissao de edicao do catalogo.</p>
          </div>
        </div>

        <div class="grade-formulario">
          <label>
            Nome
            <input [(ngModel)]="formulario.nome" name="colaboradorNome" autocomplete="name" />
          </label>
          <label>
            E-mail
            <input [(ngModel)]="formulario.email" name="colaboradorEmail" type="email" autocomplete="email" />
          </label>
          <label>
            Senha provisoria
            <input [(ngModel)]="formulario.senha" name="colaboradorSenha" type="password" autocomplete="new-password" />
            <small>Obrigatoria apenas se o e-mail ainda nao existir no sistema.</small>
          </label>
        </div>

        <div class="acoes-formulario">
          <button class="botao primario" type="button" (click)="cadastrarColaborador()" [disabled]="salvando()">
            {{ salvando() ? 'Cadastrando...' : 'Cadastrar colaborador' }}
          </button>
        </div>

        @if (mensagem()) {
          <p class="mensagem-formulario">{{ mensagem() }}</p>
        }
      </section>
    }

    <section class="bloco colaboradores-convite">
      <div>
        <strong>Ajude a aumentar o nosso acervo</strong>
        <p>
          Seja colaborador do HQ-HUB nos ajudando a cadastrar HQs, revisar informacoes,
          completar dados de series e deixar o catalogo cada vez mais util para outros colecionadores.
        </p>
        <a
          class="botao-colaborador"
          href="https://chat.whatsapp.com/Dctxr7AOfnR63EatscRHGG?mode=gi_t"
          target="_blank"
          rel="noopener noreferrer"
        >
          Quero ser colaborador
        </a>
      </div>
    </section>

    <section class="bloco lista-colaboradores">
      <h2>Colaboradores do HQ-HUB</h2>
      <ul>
        <li *ngFor="let colaborador of colaboradores()">{{ colaborador }}</li>
      </ul>
    </section>
  `,
  styles: `
    .painel-admin-colaboradores {
      display: grid;
      gap: 16px;
    }

    .grade-formulario {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 12px;
    }

    .grade-formulario label {
      display: grid;
      gap: 6px;
      font-weight: 700;
      color: var(--texto);
    }

    .grade-formulario input {
      min-height: 42px;
      border: 1px solid var(--borda);
      border-radius: 6px;
      padding: 0 12px;
      background: var(--superficie);
      color: var(--texto);
    }

    .grade-formulario small {
      color: var(--texto-suave);
      font-size: 0.78rem;
      font-weight: 600;
    }

    .acoes-formulario {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    .mensagem-formulario {
      margin: 0;
      color: var(--texto-suave);
      font-weight: 700;
    }

    .colaboradores-convite {
      display: grid;
      gap: 10px;
      border-color: rgba(22, 78, 99, 0.24);
      background: linear-gradient(135deg, rgba(22, 78, 99, 0.08), rgba(245, 158, 11, 0.08));
    }

    .colaboradores-convite strong {
      font-size: 1.1rem;
    }

    .colaboradores-convite p {
      max-width: 760px;
      margin: 8px 0 0;
      color: var(--texto-suave);
      line-height: 1.6;
    }

    .botao-colaborador {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: fit-content;
      min-height: 42px;
      margin-top: 14px;
      padding: 0 18px;
      border-radius: 6px;
      background: #164e63;
      color: #ffffff;
      font-weight: 700;
      text-decoration: none;
      box-shadow: 0 12px 26px rgba(22, 78, 99, 0.18);
    }

    .botao-colaborador:hover {
      background: #0f3a4a;
    }

    .lista-colaboradores {
      display: grid;
      gap: 16px;
    }

    .lista-colaboradores h2 {
      margin: 0;
    }

    .lista-colaboradores ul {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 12px;
      padding: 0;
      margin: 0;
      list-style: none;
    }

    .lista-colaboradores li {
      min-height: 52px;
      display: flex;
      align-items: center;
      padding: 12px 14px;
      border: 1px solid var(--borda);
      border-radius: 8px;
      background: var(--superficie);
      color: var(--texto);
      font-weight: 700;
    }

    :host-context(body.tema-escuro) .colaboradores-convite {
      background: linear-gradient(135deg, rgba(125, 211, 252, 0.12), rgba(245, 158, 11, 0.12));
      border-color: rgba(125, 211, 252, 0.24);
    }

    :host-context(body.tema-escuro) .botao-colaborador {
      background: #38bdf8;
      color: #082f49;
      box-shadow: 0 12px 26px rgba(56, 189, 248, 0.16);
    }

    :host-context(body.tema-escuro) .botao-colaborador:hover {
      background: #7dd3fc;
    }
  `,
})
export class ColaboradoresPage {
  private readonly api = inject(ApiService);
  private readonly autenticacao = inject(AutenticacaoService);

  protected readonly ehAdministrador = this.autenticacao.ehAdministrador;
  protected readonly salvando = signal(false);
  protected readonly mensagem = signal('');
  protected readonly colaboradoresCadastrados = signal<Usuario[]>([]);
  protected formulario = {
    nome: '',
    email: '',
    senha: '',
  };
  protected readonly colaboradores = computed(() => [
    'Cesar',
    'Pedro Jose',
    'Elivelton',
    'Wenderson',
    ...this.colaboradoresCadastrados().map((usuario) => usuario.nome),
  ]);

  cadastrarColaborador() {
    const nome = this.formulario.nome.trim();
    const email = this.formulario.email.trim();
    const senha = this.formulario.senha;

    if (!nome || !email) {
      this.mensagem.set('Informe nome e e-mail.');
      return;
    }

    this.salvando.set(true);
    this.mensagem.set('');
    this.api.cadastrarColaborador({ nome, email, senha: senha || null }).subscribe({
      next: (usuario) => {
        this.colaboradoresCadastrados.update((usuarios) => [...usuarios, usuario]);
        this.formulario = { nome: '', email: '', senha: '' };
        this.salvando.set(false);
        this.mensagem.set('Colaborador salvo com acesso de edicao.');
      },
      error: (erro) => {
        this.salvando.set(false);
        this.mensagem.set(erro?.error?.mensagem || 'Nao foi possivel cadastrar este colaborador.');
      },
    });
  }
}
