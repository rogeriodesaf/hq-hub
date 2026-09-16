import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideRouter, Router } from '@angular/router';
import { SwUpdate } from '@angular/service-worker';
import { EMPTY, of } from 'rxjs';
import { App } from './app';
import { ApiService } from './core/api.service';
import { NotificacaoSocial } from './core/modelos';

describe('App', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [
        provideHttpClient(),
        provideRouter([]),
        { provide: SwUpdate, useValue: { isEnabled: false, versionUpdates: EMPTY, unrecoverable: EMPTY } },
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should render the application footer', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('footer')?.textContent).toContain('Rogério de Sá');
  });

  it('separa notificações por períodos sem duplicar itens', () => {
    const app = TestBed.createComponent(App).componentInstance;
    const autor = { id: 2, nome: 'Alex' } as NotificacaoSocial['autor'];
    const hoje = new Date();
    const ontem = new Date(); ontem.setDate(ontem.getDate() - 1);
    app.notificacoesSociais.set([
      { id: 1, tipo: 'COMENTARIO_POSTAGEM', autor, postagemId: 3, mensagem: 'Alex comentou na sua publicação.', lida: false, dataCriacao: hoje.toISOString() },
      { id: 2, tipo: 'CURTIDA_POSTAGEM', autor, postagemId: 3, mensagem: 'Alex curtiu sua publicação.', lida: true, dataCriacao: ontem.toISOString() },
    ]);
    expect(app.notificacoesDoPeriodo('Hoje').map((item) => item.chave)).toEqual(['social-1']);
    expect(app.notificacoesDoPeriodo('Ontem').map((item) => item.chave)).toEqual(['social-2']);
    expect(app.itensNotificacoes()[0].descricao).toBe('comentou na sua publicação.');
  });

  it('marca apenas a notificação aberta como lida antes de navegar', () => {
    const app = TestBed.createComponent(App).componentInstance;
    const api = TestBed.inject(ApiService);
    const marcar = spyOn(api, 'marcarNotificacaoSocialComoLida').and.returnValue(of(void 0));
    spyOn(api, 'contarNotificacoesSociaisNaoLidas').and.returnValue(of({ total: 1 }));
    const navegar = spyOn(TestBed.inject(Router), 'navigate').and.resolveTo(true);
    const autor = { id: 2, nome: 'Alex' } as NotificacaoSocial['autor'];
    app.notificacoesSociais.set([1, 2].map((id) => ({ id, tipo: 'COMENTARIO_POSTAGEM', autor, postagemId: 3, mensagem: 'Alex comentou na sua publicação.', lida: false, dataCriacao: new Date().toISOString() })));
    app.abrirItemNotificacao(app.itensNotificacoes()[0]);
    expect(marcar).toHaveBeenCalledOnceWith(1);
    expect(app.notificacoesSociais().map((item) => item.lida)).toEqual([true, false]);
    expect(navegar).toHaveBeenCalledWith(['/postagem/3'], { queryParams: undefined });
  });
});
