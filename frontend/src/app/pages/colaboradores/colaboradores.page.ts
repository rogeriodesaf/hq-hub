import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';

@Component({
  selector: 'app-colaboradores-page',
  imports: [CommonModule],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Colaboradores</p>
        <h1>Seja colaborador do HQ-HUB.</h1>
      </div>
    </section>

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
        <li *ngFor="let colaborador of colaboradores">{{ colaborador }}</li>
      </ul>
    </section>
  `,
  styles: `
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
  protected readonly colaboradores = ['César', 'Pedro José', 'Elivelton', 'Wenderson'];
}
