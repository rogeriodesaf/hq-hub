import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PaginacaoComponent } from './paginacao.component';

describe('PaginacaoComponent', () => {
  let fixture: ComponentFixture<PaginacaoComponent>;
  let component: PaginacaoComponent;

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [PaginacaoComponent] }).compileComponents();
    fixture = TestBed.createComponent(PaginacaoComponent);
    component = fixture.componentInstance;
  });

  it('mantem primeira, vizinhas e ultima pagina visiveis no meio da lista', () => {
    component.paginaAtual = 9;
    component.totalPaginas = 20;
    expect(component.paginasVisiveis).toEqual([0, null, 8, 9, 10, null, 19]);
  });

  it('permite saltar diretamente para outra pagina', () => {
    component.paginaAtual = 9;
    component.totalPaginas = 20;
    spyOn(component.paginaChange, 'emit');
    component.irPara(0);
    expect(component.paginaChange.emit).toHaveBeenCalledOnceWith(0);
  });

  it('nao emite a pagina atual nem paginas invalidas', () => {
    component.paginaAtual = 9;
    component.totalPaginas = 20;
    spyOn(component.paginaChange, 'emit');
    component.irPara(9);
    component.irPara(-1);
    component.irPara(20);
    expect(component.paginaChange.emit).not.toHaveBeenCalled();
  });
});
