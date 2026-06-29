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
      </div>
    </section>

    <section class="estado-vazio">
      <h2>Nenhum colaborador listado ainda</h2>
      <p>Os usuarios que se disponibilizarem para colaborar com o sistema aparecerao aqui.</p>
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

    :host-context(body.tema-escuro) .colaboradores-convite {
      background: linear-gradient(135deg, rgba(125, 211, 252, 0.12), rgba(245, 158, 11, 0.12));
      border-color: rgba(125, 211, 252, 0.24);
    }
  `,
})
export class ColaboradoresPage {}
