import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';

import { AutenticacaoService } from '../../core/autenticacao.service';

@Component({
  selector: 'app-autenticacao-page',
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <main class="auth-page">
      <section class="auth-visual">
        <div class="marca-grande">HQ-HUB</div>
        <h1>Sua coleção inteira, organizada para caber no bolso.</h1>
        <p>Pesquise edições, acompanhe faltantes, monte sua estante e planeje próximas compras.</p>
        <div class="capas-demo" aria-hidden="true">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </section>

      <section class="auth-card">
        <div class="alternador">
          <button type="button" [class.ativo]="modo() === 'entrar'" (click)="modo.set('entrar')">
            Entrar
          </button>
          <button type="button" [class.ativo]="modo() === 'cadastrar'" (click)="modo.set('cadastrar')">
            Criar conta
          </button>
        </div>

        <form [formGroup]="formulario" (ngSubmit)="enviar()">
          @if (modo() === 'cadastrar') {
            <label>
              Nome
              <input formControlName="nome" autocomplete="name" placeholder="Seu nome" />
            </label>
          }

          <label>
            E-mail
            <input formControlName="email" autocomplete="email" placeholder="voce@email.com" />
          </label>

          <label>
            Senha
            <input formControlName="senha" type="password" autocomplete="current-password" placeholder="mínimo 6 caracteres" />
          </label>

          @if (mensagem()) {
            <p class="mensagem-erro">{{ mensagem() }}</p>
          }

          <button class="botao primario cheio" type="submit" [disabled]="carregando()">
            {{ carregando() ? 'Aguarde...' : modo() === 'entrar' ? 'Entrar no HQ-HUB' : 'Criar conta' }}
          </button>
        </form>
      </section>
    </main>
  `,
})
export class AutenticacaoPage {
  private readonly fb = inject(FormBuilder);
  private readonly roteador = inject(Router);
  private readonly autenticacaoService = inject(AutenticacaoService);

  readonly modo = signal<'entrar' | 'cadastrar'>('entrar');
  readonly carregando = signal(false);
  readonly mensagem = signal('');

  readonly formulario = this.fb.group({
    nome: [''],
    email: ['', [Validators.required, Validators.email]],
    senha: ['', [Validators.required, Validators.minLength(6)]],
  });

  enviar() {
    this.mensagem.set('');

    if (this.formulario.invalid) {
      this.formulario.markAllAsTouched();
      this.mensagem.set('Preencha os dados corretamente.');
      return;
    }

    const { nome, email, senha } = this.formulario.getRawValue();
    this.carregando.set(true);

    if (this.modo() === 'cadastrar') {
      this.autenticacaoService.cadastrar(nome || 'Colecionador', email!, senha!).subscribe({
        next: () => this.entrar(email!, senha!),
        error: (erro) => this.tratarErro(erro),
      });
      return;
    }

    this.entrar(email!, senha!);
  }

  private entrar(email: string, senha: string) {
    this.autenticacaoService.entrar(email, senha).subscribe({
      next: () => this.roteador.navigateByUrl('/painel'),
      error: (erro) => this.tratarErro(erro),
    });
  }

  private tratarErro(erro: unknown) {
    const resposta = erro as { error?: { mensagem?: string } };
    this.carregando.set(false);
    this.mensagem.set(resposta.error?.mensagem ?? 'Não foi possível completar a ação.');
  }
}

