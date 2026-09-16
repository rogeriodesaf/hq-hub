import { signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';

import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { HistoriaLeitura } from '../../core/modelos';
import { PainelPage } from './painel.page';

describe('PainelPage stories', () => {
  let fixture: ComponentFixture<PainelPage>;
  const usuario = { id: 1, nome: 'Eu', fotoPerfilThumbnailUrl: null };
  const historia = (id: number, autor = usuario, minuto = id, visualizada = false) => ({
    id,
    usuario: autor,
    urlImagem: 'https://imagem/exemplo.jpg',
    texto: null,
    tituloHq: null,
    visualizada,
    comentarios: [],
    totalCurtidas: 0,
    totalVisualizacoes: 0,
    curtidaPeloUsuario: false,
    dataCriacao: new Date(Date.now() - (10 - minuto) * 60_000).toISOString(),
    dataExpiracao: new Date(Date.now() + 60_000).toISOString(),
  }) as unknown as HistoriaLeitura;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PainelPage],
      providers: [
        provideRouter([]),
        { provide: AutenticacaoService, useValue: { usuario: signal(usuario) } },
        { provide: ApiService, useValue: {
          listarFeed: () => of([]),
          listarAnuncios: () => of([]),
          listarUsuarios: () => of([]),
          listarHistorias: () => of([]),
          removerHistoria: () => of(null),
          listarVisualizacoesHistoria: () => of([{ usuario: { id: 2, nome: 'Amigo', fotoPerfilThumbnailUrl: null }, dataVisualizacao: new Date().toISOString() }]),
          visualizarHistoria: (id: number) => of({ ...fixture.componentInstance.historias().find((item) => item.id === id)!, visualizada: true }),
        } },
      ],
    }).compileComponents();
    fixture = TestBed.createComponent(PainelPage);
    fixture.detectChanges();
  });

  afterEach(() => fixture.destroy());

  it('abre o perfil de quem visualizou e fecha o story', () => {
    fixture.componentInstance.historias.set([historia(1)]);
    fixture.componentInstance.abrirGrupoProprio();
    fixture.componentInstance.alternarVisualizacoes(fixture.componentInstance.historias()[0]);
    fixture.detectChanges();
    const perfil = fixture.nativeElement.querySelector('.historia-visualizacao-link') as HTMLAnchorElement;
    expect(perfil.getAttribute('href')).toBe('/usuario/2');
    expect(perfil.getAttribute('aria-label')).toBe('Ver perfil de Amigo');
    perfil.click();
    expect(fixture.componentInstance.historiaAberta()).toBeNull();
  });

  it('agrupa dois stories próprios no mesmo avatar e mantém o + independente', () => {
    fixture.componentInstance.historias.set([historia(2), historia(1)]);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelectorAll('.historias-faixa .historia-atalho').length).toBe(1);
    fixture.componentInstance.historias.update((itens) => [...itens, historia(3)]);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelectorAll('.historias-faixa .historia-atalho').length).toBe(1);
    expect(fixture.componentInstance.grupoProprio()?.historias.length).toBe(3);
    const adicionar = fixture.nativeElement.querySelector('.historia-adicionar') as HTMLButtonElement;
    adicionar.click();
    fixture.detectChanges();
    expect(fixture.componentInstance.criadorHistoriaAberto()).toBeTrue();
    expect(fixture.componentInstance.historiaAberta()).toBeNull();
  });

  it('abre criação ao tocar no avatar quando não há story próprio', () => {
    (fixture.nativeElement.querySelector('.historia-atalho') as HTMLButtonElement).click();
    expect(fixture.componentInstance.criadorHistoriaAberto()).toBeTrue();
  });

  it('navega dentro do autor e atualiza a borda após visualização', () => {
    const amigo = { id: 2, nome: 'Amigo', fotoPerfilThumbnailUrl: null };
    fixture.componentInstance.historias.set([historia(3, amigo), historia(2, amigo), historia(1)]);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('.historias-faixa .visualizada')).toBeNull();
    fixture.componentInstance.abrirHistoria(historia(2, amigo));
    expect(fixture.componentInstance.sequenciaHistoria().map((item) => item.id)).toEqual([2, 3]);
    fixture.componentInstance.avancarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(3);
    fixture.componentInstance.voltarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(2);
    fixture.componentInstance.historias.update((itens) => itens.map((item) => ({ ...item, visualizada: true })));
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('.historias-faixa .visualizada')).not.toBeNull();
  });

  it('continua automaticamente no próximo autor e volta ao anterior', () => {
    const amigo = { id: 2, nome: 'Amigo', fotoPerfilThumbnailUrl: null };
    const outro = { id: 3, nome: 'Outro', fotoPerfilThumbnailUrl: null };
    fixture.componentInstance.historias.set([historia(3, amigo), historia(2, amigo), historia(1), historia(4, outro, 0)]);
    fixture.detectChanges();
    fixture.componentInstance.abrirGrupoProprio();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(1);
    fixture.componentInstance.avancarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(2);
    fixture.componentInstance.avancarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(3);
    expect(fixture.componentInstance.temProximaHistoria(fixture.componentInstance.historiaAberta()!)).toBeTrue();
    fixture.componentInstance.avancarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(4);
    fixture.componentInstance.voltarHistoria();
    expect(fixture.componentInstance.historiaAberta()?.id).toBe(3);
    fixture.componentInstance.avancarHistoria();
    fixture.componentInstance.avancarHistoria();
    expect(fixture.componentInstance.historiaAberta()).toBeNull();
  });

  it('remove o grupo vazio após excluir o último story e mantém Sua história', () => {
    fixture.componentInstance.historias.set([historia(1)]);
    fixture.detectChanges();
    spyOn(window, 'confirm').and.returnValue(true);
    fixture.componentInstance.removerHistoria(fixture.componentInstance.historias()[0]);
    fixture.detectChanges();
    expect(fixture.componentInstance.grupoProprio()).toBeUndefined();
    expect(fixture.nativeElement.querySelectorAll('.historias-faixa .historia-atalho').length).toBe(1);
    expect(fixture.nativeElement.querySelector('.historias-faixa').textContent).toContain('Sua história');
  });
});
