import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

import { AutenticacaoService } from '../../core/autenticacao.service';

type Modo = 'entrar' | 'cadastrar' | 'redefinir' | 'nova-senha';

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
        @if (modo() === 'entrar' || modo() === 'cadastrar') {
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

          @if (modo() === 'entrar') {
            <p class="link-esqueci-senha">
              <button type="button" class="link-botao" (click)="modo.set('redefinir')">Esqueci minha senha</button>
            </p>
          }
        }

        @if (modo() === 'redefinir') {
          <div class="alternador">
            <button type="button" class="ativo" style="grid-column: 1 / -1">Redefinir senha</button>
          </div>

          @if (!emailEnviado()) {
            <form [formGroup]="formularioRedefinir" (ngSubmit)="solicitarRedefinicao()">
              <p class="texto-suave" style="margin: 0 0 14px">Informe seu e-mail e enviaremos um link para redefinir sua senha.</p>
              <label>
                E-mail
                <input formControlName="email" autocomplete="email" placeholder="voce@email.com" />
              </label>

              @if (mensagem()) {
                <p class="mensagem-erro">{{ mensagem() }}</p>
              }

              <button class="botao primario cheio" type="submit" [disabled]="carregando()">
                {{ carregando() ? 'Enviando...' : 'Enviar link de redefinição' }}
              </button>
            </form>
          } @else {
            <p class="mensagem-sucesso">Link enviado! Verifique sua caixa de entrada (e a pasta de spam).</p>
          }

          <p class="link-esqueci-senha">
            <button type="button" class="link-botao" (click)="voltarAoLogin()">Voltar ao login</button>
          </p>
        }

        @if (modo() === 'nova-senha') {
          <div class="alternador">
            <button type="button" class="ativo" style="grid-column: 1 / -1">Nova senha</button>
          </div>

          @if (!senhaTrocada()) {
            <form [formGroup]="formularioNovaSenha" (ngSubmit)="aplicarNovaSenha()">
              <p class="texto-suave" style="margin: 0 0 14px">Digite sua nova senha para o HQ-HUB.</p>
              <label>
                Nova senha
                <input formControlName="novaSenha" type="password" autocomplete="new-password" placeholder="mínimo 6 caracteres" />
              </label>

              @if (mensagem()) {
                <p class="mensagem-erro">{{ mensagem() }}</p>
              }

              <button class="botao primario cheio" type="submit" [disabled]="carregando()">
                {{ carregando() ? 'Aguarde...' : 'Redefinir senha' }}
              </button>
            </form>
          } @else {
            <p class="mensagem-sucesso">Senha redefinida com sucesso!</p>
            <button type="button" class="botao primario cheio" style="margin-top: 14px; width: 100%" (click)="voltarAoLogin()">
              Fazer login
            </button>
          }
        }
      </section>
    </main>
  `,
})
export class AutenticacaoPage implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly roteador = inject(Router);
  private readonly rota = inject(ActivatedRoute);
  private readonly autenticacaoService = inject(AutenticacaoService);

  readonly modo = signal<Modo>('entrar');
  readonly carregando = signal(false);
  readonly mensagem = signal('');
  readonly emailEnviado = signal(false);
  readonly senhaTrocada = signal(false);
  private tokenRedefinicao = '';

  readonly formulario = this.fb.group({
    nome: [''],
    email: ['', [Validators.required, Validators.email]],
    senha: ['', [Validators.required, Validators.minLength(6)]],
  });

  readonly formularioRedefinir = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
  });

  readonly formularioNovaSenha = this.fb.group({
    novaSenha: ['', [Validators.required, Validators.minLength(6)]],
  });

  ngOnInit() {
    this.rota.queryParams.subscribe((params) => {
      const token = params['token'] as string | undefined;
      if (token) {
        this.tokenRedefinicao = token;
        this.modo.set('nova-senha');
      }
    });
  }

  voltarAoLogin() {
    this.mensagem.set('');
    this.emailEnviado.set(false);
    this.senhaTrocada.set(false);
    this.tokenRedefinicao = '';
    this.roteador.navigate(['/entrar'], { replaceUrl: true });
    this.modo.set('entrar');
  }

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

  solicitarRedefinicao() {
    this.mensagem.set('');

    if (this.formularioRedefinir.invalid) {
      this.formularioRedefinir.markAllAsTouched();
      this.mensagem.set('Informe um e-mail válido.');
      return;
    }

    const { email } = this.formularioRedefinir.getRawValue();
    this.carregando.set(true);

    this.autenticacaoService.solicitarRedefinicaoSenha(email!).subscribe({
      next: () => {
        this.carregando.set(false);
        this.emailEnviado.set(true);
      },
      error: () => {
        this.carregando.set(false);
        // Não revelar se o e-mail existe: sempre mostrar mensagem de sucesso
        this.emailEnviado.set(true);
      },
    });
  }

  aplicarNovaSenha() {
    this.mensagem.set('');

    if (this.formularioNovaSenha.invalid) {
      this.formularioNovaSenha.markAllAsTouched();
      this.mensagem.set('Informe uma senha com no mínimo 6 caracteres.');
      return;
    }

    const { novaSenha } = this.formularioNovaSenha.getRawValue();
    this.carregando.set(true);

    this.autenticacaoService.redefinirSenha(this.tokenRedefinicao, novaSenha!).subscribe({
      next: () => {
        this.carregando.set(false);
        this.senhaTrocada.set(true);
      },
      error: (erro) => this.tratarErro(erro),
    });
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

