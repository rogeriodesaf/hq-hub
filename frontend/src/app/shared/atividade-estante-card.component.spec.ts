import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { PostagemFeed } from '../core/modelos';
import { AtividadeEstanteCardComponent } from './atividade-estante-card.component';

describe('AtividadeEstanteCardComponent', () => {
  let fixture: ComponentFixture<AtividadeEstanteCardComponent>;

  const postagem: PostagemFeed = {
    id: 10,
    usuario: { id: 2, nome: 'Alex Alves' } as PostagemFeed['usuario'],
    conteudo: 'Adicionou à estante.',
    urlImagem: null,
    atividadeEstante: {
      tipo: 'ADICIONOU_COLECAO',
      quantidade: 1,
      edicoes: [{ edicaoId: 42, titulo: 'X-Men: Tesouros Ocultos (Omnibus)', urlCapa: null }],
    },
    imagens: [],
    colecaoDestaque: null,
    catalogoDestaque: null,
    relatedVideos: [],
    partnerChannel: null,
    fixada: false,
    totalCurtidas: 0,
    curtidaPeloUsuario: false,
    comentarios: [],
    dataCriacao: new Date().toISOString(),
    dataAtualizacao: new Date().toISOString(),
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AtividadeEstanteCardComponent],
      providers: [provideRouter([])],
    }).compileComponents();
    fixture = TestBed.createComponent(AtividadeEstanteCardComponent);
    fixture.componentRef.setInput('postagem', postagem);
    fixture.detectChanges();
  });

  it('exibe a atividade compacta e o link da edição', () => {
    const texto = fixture.nativeElement.textContent;
    expect(texto).toContain('Alex Alves adicionou à estante');
    expect(texto).toContain('X-Men: Tesouros Ocultos (Omnibus)');
    expect(texto).toContain('Ver edição');
    expect(fixture.nativeElement.querySelector('a.edicao').getAttribute('href')).toContain('edicaoId=42');
  });

  it('mantém o campo de comentário recolhido até a ação do usuário', () => {
    expect(fixture.nativeElement.querySelector('.comentarios')).toBeNull();
    const botoes = [...fixture.nativeElement.querySelectorAll('.acoes button')] as HTMLButtonElement[];
    botoes.find((botao) => botao.textContent?.includes('Comentar'))!.click();
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('.comentarios input')).not.toBeNull();
  });
});
