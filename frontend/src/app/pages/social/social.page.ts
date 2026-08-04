import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-social-page',
  imports: [RouterLink],
  template: `
    <section class="cabecalho-pagina social-cabecalho">
      <div>
        <p class="rotulo">Social</p>
        <h1>Sua comunidade de leitores.</h1>
        <p>Conversas, amizades e conteúdo da comunidade em um só lugar.</p>
      </div>
    </section>

    <section class="social-grade" aria-label="Áreas sociais">
      <a class="bloco social-card destaque" routerLink="/mensagens">
        <span>💬</span><div><h2>Direct</h2><p>Continue suas conversas privadas.</p></div><strong>→</strong>
      </a>
      <a class="bloco social-card" routerLink="/amigos">
        <span>👥</span><div><h2>Amigos</h2><p>Encontre e acompanhe outros colecionadores.</p></div><strong>→</strong>
      </a>
      <a class="bloco social-card" routerLink="/canais">
        <span>📺</span><div><h2>Canais</h2><p>Descubra conteúdo sobre quadrinhos.</p></div><strong>→</strong>
      </a>
      <a class="bloco social-card" routerLink="/colaboradores">
        <span>🤝</span><div><h2>Colaboradores</h2><p>Conheça quem ajuda a construir o catálogo.</p></div><strong>→</strong>
      </a>
      <a class="bloco social-card" routerLink="/painel">
        <span>🗨️</span><div><h2>Publicações e comentários</h2><p>Participe das conversas no Feed.</p></div><strong>→</strong>
      </a>
      <button class="bloco social-card" type="button" (click)="abrirNotificacoes()">
        <span>🔔</span><div><h2>Notificações</h2><p>Veja mensagens, amizades e novidades recentes.</p></div><strong>→</strong>
      </button>
    </section>
  `,
})
export class SocialPage {
  abrirNotificacoes() {
    window.dispatchEvent(new CustomEvent('hqhub-abrir-notificacoes'));
  }
}
