import { FormBuilder } from '@angular/forms';
import { TestBed } from '@angular/core/testing';
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, of, throwError } from 'rxjs';

import { AutenticacaoService } from '../../core/autenticacao.service';
import { AutenticacaoPage } from './autenticacao.page';

describe('Recuperação de senha', () => {
  let envio: jasmine.Spy;
  let rota: { queryParams: Observable<Record<string, string>>; snapshot: { fragment: string | null } };

  beforeEach(() => {
    envio = jasmine.createSpy('solicitarRedefinicaoSenha').and.returnValue(of(void 0));
    rota = { queryParams: of({}), snapshot: { fragment: null } };
    TestBed.configureTestingModule({
      providers: [
        FormBuilder,
        { provide: Router, useValue: { navigate: jasmine.createSpy('navigate') } },
        { provide: ActivatedRoute, useValue: rota },
        { provide: AutenticacaoService, useValue: { solicitarRedefinicaoSenha: envio } },
      ],
    });
  });

  it('aceita token no fragmento e retira-o da URL', () => {
    rota.snapshot.fragment = 'token=abc123';
    const limpar = spyOn(history, 'replaceState');
    const pagina = TestBed.runInInjectionContext(() => new AutenticacaoPage());
    pagina.ngOnInit();
    expect(pagina.modo()).toBe('nova-senha');
    expect(limpar).toHaveBeenCalled();
  });

  it('confirma solicitação sem revelar se o endereço existe', () => {
    const pagina = TestBed.runInInjectionContext(() => new AutenticacaoPage());
    pagina.formularioRedefinir.setValue({ email: 'leitor@example.com' });
    pagina.solicitarRedefinicao();
    expect(envio).toHaveBeenCalledWith('leitor@example.com');
    expect(pagina.emailEnviado()).toBeTrue();
  });

  it('não mostra detalhes internos da falha de transporte', () => {
    envio.and.returnValue(throwError(() => ({ error: { mensagem: 'SMTP conta existente' } })));
    const pagina = TestBed.runInInjectionContext(() => new AutenticacaoPage());
    pagina.formularioRedefinir.setValue({ email: 'leitor@example.com' });
    pagina.solicitarRedefinicao();
    expect(pagina.mensagem()).not.toContain('SMTP');
    expect(pagina.mensagem()).toContain('Tente novamente');
  });
});
