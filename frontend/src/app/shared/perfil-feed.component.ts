import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { resolverUrlMidia } from '../core/midia-url';
import { Usuario } from '../core/modelos';

type PerfilResumo = Pick<Usuario, 'nome' | 'bio' | 'fotoPerfilThumbnailUrl'>;

@Component({
  selector: 'app-perfil-feed',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <section class="perfil-feed" [class.resumo]="modo === 'resumo'">
      <div class="perfil-cabecalho">
        <div class="foto-perfil-feed">
          @if (usuario?.fotoPerfilThumbnailUrl) {
            <img [src]="resolverUrlMidia(usuario?.fotoPerfilThumbnailUrl)" alt="Foto de perfil" />
          } @else {
            {{ iniciais(usuario?.nome || nome || 'HQ') }}
          }
        </div>

        <div class="perfil-texto">
          <strong>{{ usuario?.nome || nome || 'Seu perfil' }}</strong>
          <p>{{ usuario?.bio || bio || 'Adicione uma bio para apresentar sua estante.' }}</p>
        </div>
      </div>

      @if (modo === 'edicao') {
        <label class="botao compacto secundario seletor-feed">
          Trocar foto
          <input type="file" accept="image/jpeg,image/png,image/webp" (change)="fotoSelecionada.emit($event)" />
        </label>
        <label>
          Nome
          <input [ngModel]="nome" (ngModelChange)="nomeChange.emit($event)" name="perfilNome" />
        </label>
        <label>
          Bio
          <textarea
            [ngModel]="bio"
            (ngModelChange)="bioChange.emit($event)"
            name="perfilBio"
            rows="4"
            maxlength="500"
            placeholder="O que voce le, coleciona ou procura?"
          ></textarea>
        </label>
        <button class="botao primario compacto" type="button" (click)="salvar.emit()" [disabled]="salvando || !nome.trim()">
          {{ salvando ? 'Salvando...' : 'Salvar perfil' }}
        </button>
      }
    </section>
  `,
  styles: `
    .perfil-feed {
      display: grid;
      gap: 10px;
      padding-bottom: 14px;
      border-bottom: 1px solid var(--borda);
    }

    .perfil-feed.resumo {
      padding-bottom: 0;
      border-bottom: 0;
    }

    .perfil-cabecalho {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .perfil-texto {
      display: grid;
      gap: 3px;
      min-width: 0;
    }

    .perfil-texto strong,
    .perfil-texto p {
      margin: 0;
      overflow-wrap: anywhere;
    }

    .perfil-texto strong {
      font-size: 1rem;
    }

    .perfil-texto p {
      color: var(--texto-suave);
      font-size: 0.88rem;
      line-height: 1.45;
    }

    .perfil-feed label {
      display: grid;
      gap: 6px;
      color: var(--texto-suave);
      font-size: 0.86rem;
      font-weight: 750;
    }

    .perfil-feed textarea {
      resize: vertical;
    }

    .foto-perfil-feed {
      display: grid;
      width: 92px;
      height: 92px;
      place-items: center;
      overflow: hidden;
      border-radius: 999px;
      background: var(--azul);
      color: #fff;
      font-size: 1.8rem;
      font-weight: 900;
      flex: 0 0 auto;
    }

    .foto-perfil-feed img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    .seletor-feed input {
      display: none;
    }
  `,
})
export class PerfilFeedComponent {
  readonly resolverUrlMidia = resolverUrlMidia;

  @Input() usuario: PerfilResumo | null = null;
  @Input() nome = '';
  @Input() bio = '';
  @Input() salvando = false;
  @Input() modo: 'resumo' | 'edicao' | 'visualizacao' = 'resumo';

  @Output() nomeChange = new EventEmitter<string>();
  @Output() bioChange = new EventEmitter<string>();
  @Output() fotoSelecionada = new EventEmitter<Event>();
  @Output() salvar = new EventEmitter<void>();

  iniciais(nome: string) {
    return nome
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((parte) => parte[0]?.toUpperCase())
      .join('') || 'HQ';
  }
}
