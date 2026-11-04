import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { Serie } from '../../core/modelos';
import { ImportacaoEdicaoPaniniComponent } from './importacao-edicao-panini.component';

describe('ImportacaoEdicaoPaniniComponent', () => {
  let api: jasmine.SpyObj<ApiService>;
  let componente: ImportacaoEdicaoPaniniComponent;

  beforeEach(() => {
    api = jasmine.createSpyObj<ApiService>('ApiService', ['listarSeries']);
    TestBed.configureTestingModule({ providers: [{ provide: ApiService, useValue: api }] });
    componente = TestBed.runInInjectionContext(() => new ImportacaoEdicaoPaniniComponent());
  });

  it('carrega todas as páginas de coleções brasileiras encontradas', async () => {
    const primeiras = Array.from({ length: 100 }, (_, indice) =>
      serie(indice + 1, `Coleção ${indice + 1}`),
    );
    const osVingadores = serie(1490, 'Os Vingadores');
    api.listarSeries.and.callFake((_busca, pagina) => {
      const numeroPagina = pagina ?? 0;
      return of({
        itens: numeroPagina === 0 ? primeiras : [osVingadores, primeiras[0]],
        pagina: numeroPagina,
        tamanho: 100,
        totalItens: 101,
        totalPaginas: 2,
      });
    });
    componente.buscaColecao = 'Os Vingadores';

    await componente.buscarColecoes();

    expect(api.listarSeries).toHaveBeenCalledTimes(2);
    expect(api.listarSeries.calls.argsFor(0)).toEqual([
      'Os Vingadores',
      0,
      100,
      '',
      'BRASILEIRA',
    ]);
    expect(api.listarSeries.calls.argsFor(1)).toEqual([
      'Os Vingadores',
      1,
      100,
      '',
      'BRASILEIRA',
    ]);
    expect(componente.colecoes().length).toBe(101);
    expect(componente.colecoes().some((item) => item.id === osVingadores.id)).toBeTrue();
    expect(componente.buscandoColecoes()).toBeFalse();
    expect(componente.colecoesConsultadas()).toBeTrue();
  });
});

function serie(id: number, titulo: string): Serie {
  return { id, titulo } as Serie;
}
