import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-apoie-page',
  imports: [CommonModule, RouterLink],
  template: `
    <section class="cabecalho-pagina">
      <div>
        <p class="rotulo">Apoie o HQ-HUB</p>
        <h1>Torne-se apoiador desse projeto.</h1>
      </div>
      <a class="botao secundario" routerLink="/painel">Voltar ao feed</a>
    </section>

    <section class="bloco apoio-card">
      <p>
        Agradecemos por considerar fazer uma doacao ao HQ-HUB. Pense em quantas vezes
        voce consultou sua colecao, pesquisou uma edicao, organizou sua estante ou
        encontrou informacoes uteis sobre quadrinhos por aqui.
      </p>
      <p>
        Se esse projeto foi valioso para voce, junte-se aos leitores e colecionadores
        que ajudam a manter um acervo livre, colaborativo e acessivel. Qualquer quantia
        ajuda: R$10, R$20, R$50 ou qualquer valor com que puder contribuir hoje.
      </p>
      <p>
        O HQ-HUB existe para aproximar colecionadores, organizar dados de HQs e preservar
        informacoes que ficam melhores quando muitas pessoas colaboram. Nao ha contribuicao
        pequena: cada cadastro conta, cada revisao conta, cada doacao conta.
      </p>

      <div class="pix-box">
        <span>Pix para apoiar</span>
        <strong>05354567432</strong>
      </div>

      <p class="agradecimento">Nos agradecemos.</p>
    </section>
  `,
  styles: `
    .apoio-card {
      display: grid;
      gap: 16px;
      max-width: 860px;
      border-color: rgba(184, 134, 11, 0.28);
      background: #fff9e8;
    }

    .apoio-card p {
      margin: 0;
      color: #352b12;
      line-height: 1.7;
    }

    .pix-box {
      display: grid;
      gap: 6px;
      width: fit-content;
      min-width: min(100%, 280px);
      padding: 14px 16px;
      border: 1px solid rgba(184, 134, 11, 0.35);
      border-radius: 8px;
      background: #fff;
    }

    .pix-box span {
      color: #6a5418;
      font-size: 0.82rem;
      font-weight: 850;
      text-transform: uppercase;
    }

    .pix-box strong {
      color: #164e63;
      font-size: 1.35rem;
      letter-spacing: 0;
    }

    .agradecimento {
      font-weight: 850;
    }

    :host-context(body.tema-escuro) .apoio-card {
      background: #2b220f;
      border-color: rgba(245, 158, 11, 0.32);
    }

    :host-context(body.tema-escuro) .apoio-card p {
      color: #fef3c7;
    }

    :host-context(body.tema-escuro) .pix-box {
      background: #111827;
      border-color: rgba(125, 211, 252, 0.24);
    }

    :host-context(body.tema-escuro) .pix-box span {
      color: #fde68a;
    }

    :host-context(body.tema-escuro) .pix-box strong {
      color: #7dd3fc;
    }
  `,
})
export class ApoiePage {}
