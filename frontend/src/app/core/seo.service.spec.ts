import { TestBed } from '@angular/core/testing';
import { Meta, Title } from '@angular/platform-browser';

import { SeoService } from './seo.service';

describe('SeoService', () => {
  let meta: Meta;
  let service: SeoService;
  let title: Title;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SeoService);
    meta = TestBed.inject(Meta);
    title = TestBed.inject(Title);
  });

  it('configura guia público como indexável e canônico', () => {
    service.atualizar('/guia-de-leitura-app/batman-ordem-cronologica');

    expect(title.getTitle()).toBe('Ordem Cronológica do Batman | HQ-HUB');
    expect(meta.getTag('name="robots"')?.content).toContain('index, follow');
    expect(document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]')?.href).toBe(
      'https://hqhub.space/guia-de-leitura-app/batman-ordem-cronologica',
    );
  });

  it('impede a indexação de área privada', () => {
    service.atualizar('/colecao');

    expect(meta.getTag('name="robots"')?.content).toBe('noindex, nofollow');
  });
});
