import { TestBed } from '@angular/core/testing';
import { ActivatedRoute, convertToParamMap, provideRouter } from '@angular/router';
import { of, throwError } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AnuncioPublico } from '../../core/modelos';
import { ClassificadosPublicosPage } from './classificados-publicos.page';

describe('ClassificadosPublicosPage', () => {
  const anuncio = {
    id: 15, tituloEdicao: 'A Saga dos X-Men #2', urlFotoExemplar: 'https://img.example/exemplar.jpg',
    urlCapa: 'https://img.example/capa.jpg', nomeAnunciante: 'Ana', tipoAnuncio: 'VENDA',
    preco: 29.9, estadoConservacao: 'MUITO_BOM', descricao: null, cidade: null, estado: null,
    linkContatoWhatsapp: null, dataCriacao: new Date().toISOString(),
  } as AnuncioPublico;

  async function criar(disponivel: boolean) {
    await TestBed.configureTestingModule({
      imports: [ClassificadosPublicosPage],
      providers: [
        provideRouter([]),
        { provide: ActivatedRoute, useValue: { queryParamMap: of(convertToParamMap({ anuncioId: '15' })) } },
        { provide: ApiService, useValue: {
          listarAnunciosPublicos: () => of(disponivel ? [anuncio] : []),
          buscarAnuncioPublico: () => disponivel ? of(anuncio) : throwError(() => new Error('404')),
        } },
      ],
    }).compileComponents();
    const fixture = TestBed.createComponent(ClassificadosPublicosPage);
    fixture.detectChanges();
    return fixture;
  }

  it('abre diretamente o anúncio público com foto real', async () => {
    const fixture = await criar(true);
    const detalhe = fixture.nativeElement.querySelector('#anuncio-selecionado') as HTMLElement;
    expect(detalhe.textContent).toContain('A Saga dos X-Men #2');
    expect(detalhe.querySelector('img')?.getAttribute('src')).toBe('https://img.example/exemplar.jpg');
    fixture.destroy();
  });

  it('informa quando o anúncio não está mais disponível', async () => {
    const fixture = await criar(false);
    expect(fixture.nativeElement.textContent).toContain('Anúncio indisponível');
    fixture.destroy();
  });
});
