import { TestBed } from '@angular/core/testing';

import { CompartilhamentoService } from './compartilhamento.service';

describe('CompartilhamentoService', () => {
  let service: CompartilhamentoService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CompartilhamentoService);
  });

  it('usa Web Share API quando disponível', async () => {
    const compartilhar = jasmine.createSpy('share').and.resolveTo();
    Object.defineProperty(navigator, 'share', { configurable: true, value: compartilhar });
    const dados = { title: 'HQ #1', text: 'Conheça esta edição', url: 'https://hqhub.test/edicoes/1' };

    await expectAsync(service.compartilhar(dados)).toBeResolvedTo('compartilhado');
    expect(compartilhar).toHaveBeenCalledOnceWith(dados);
    Object.defineProperty(navigator, 'share', { configurable: true, value: undefined });
  });

  it('copia somente a URL quando Web Share API não está disponível', async () => {
    Object.defineProperty(navigator, 'share', { configurable: true, value: undefined });
    const escrever = jasmine.createSpy('writeText').and.resolveTo();
    Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: escrever } });

    await expectAsync(service.compartilhar({ title: 'HQ', text: 'Texto', url: 'https://hqhub.test/edicoes/2' }))
      .toBeResolvedTo('copiado');
    expect(escrever).toHaveBeenCalledOnceWith('https://hqhub.test/edicoes/2');
  });
});
