import { TestBed } from '@angular/core/testing';

import { CompartilhamentoService } from './compartilhamento.service';

describe('CompartilhamentoService', () => {
  let service: CompartilhamentoService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CompartilhamentoService);
  });

  it('gera o link publico curto de uma edicao', () => {
    expect(service.urlEdicao(42)).toBe('https://hqhub.space/e/42?origem=compartilhamento');
  });

  it('gera links compartilháveis no domínio público', () => {
    expect(service.urlSerie(7)).toBe('https://hqhub.space/colecao/serie/7?origem=compartilhamento');
    expect(service.urlPostagem(9)).toBe('https://hqhub.space/hq/9?origem=compartilhamento');
    expect(service.urlAnuncio(11)).toMatch(/^https:\/\/hqhub\.space\/classificados\/anuncio\/11\?origem=compartilhamento&v=\d+$/);
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

  it('copia a mensagem de apoio junto com o link quando solicitado', async () => {
    Object.defineProperty(navigator, 'share', { configurable: true, value: undefined });
    const escrever = jasmine.createSpy('writeText').and.resolveTo();
    Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: escrever } });

    await expectAsync(service.compartilhar({
      title: 'HQ #1',
      text: 'Apoie o Coleciona HQ. Publicidade · link de associado Amazon.',
      url: 'https://hqhub.test/edicoes/1',
    }, true)).toBeResolvedTo('copiado');
    expect(escrever).toHaveBeenCalledOnceWith('Apoie o Coleciona HQ. Publicidade · link de associado Amazon.\nhttps://hqhub.test/edicoes/1');
  });

  it('copia a mensagem de apoio quando o compartilhamento nativo falha', async () => {
    const compartilhar = jasmine.createSpy('share').and.rejectWith(new Error('compartilhamento bloqueado'));
    const escrever = jasmine.createSpy('writeText').and.resolveTo();
    Object.defineProperty(navigator, 'share', { configurable: true, value: compartilhar });
    Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: escrever } });

    await expectAsync(service.compartilhar({
      title: 'HQ #1',
      text: 'Apoie o Coleciona HQ.',
      url: 'https://hqhub.test/edicoes/1',
    }, true)).toBeResolvedTo('copiado');
    expect(escrever).toHaveBeenCalledOnceWith('Apoie o Coleciona HQ.\nhttps://hqhub.test/edicoes/1');
  });
});
