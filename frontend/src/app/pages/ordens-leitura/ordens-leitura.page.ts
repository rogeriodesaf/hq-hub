import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { ApiService } from '../../core/api.service';
import { AutenticacaoService } from '../../core/autenticacao.service';
import { ItemOrdemLeitura, OrdemLeituraDetalhe, OrdemLeituraResumo } from '../../core/modelos';

@Component({
  selector: 'app-ordens-leitura-page',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <main class="pagina">
      <header class="cabecalho">
        <div><span class="rotulo">GUIAS HQ-HUB</span><h1>Ordens de leitura</h1>
          <p>Acompanhe grandes jornadas na sequência certa e marque seu progresso.</p></div>
        <a class="botao secundario" [routerLink]="modoPublico ? '/entrar' : '/painel'">{{ modoPublico ? 'Conhecer o HQ-HUB' : 'Voltar' }}</a>
      </header>

      @if (!selecionada()) {
        <section class="lista-ordens">
          @for (ordem of ordens(); track ordem.id) {
            <button class="ordem" type="button" (click)="abrir(ordem)">
              <div><span class="selo">ORDEM CRONOLÓGICA</span><h2>{{ ordem.titulo }}</h2><p>{{ ordem.descricao }}</p></div>
              <strong>{{ ordem.itensLidos }} / {{ ordem.totalItens }} lidas</strong>
              <div class="barra"><span [style.width.%]="percentual(ordem)"></span></div>
            </button>
          }
        </section>
      } @else {
        <section class="topo-ordem">
          @if (!modoPublico) { <button class="voltar" type="button" (click)="selecionada.set(null)">← Todas as ordens</button> }
          <h2>{{ selecionada()!.titulo }}</h2><p>{{ selecionada()!.descricao }}</p>
          <div class="acoes-guia">
            @if (!modoPublico) { <div class="progresso"><strong>{{ selecionada()!.itensLidos }} de {{ selecionada()!.totalItens }}</strong> edições lidas</div> }
            <button class="compartilhar" type="button" (click)="compartilharGuia()">Compartilhar guia</button>
            @if (ehColecaoMarvelDeluxe()) {
              @if (autenticado()) {
                <button class="adicionar-colecao" type="button" (click)="adicionarColecaoCompleta()" [disabled]="adicionandoColecao()">
                  {{ adicionandoColecao() ? 'Adicionando coleção...' : 'Adicionar toda a coleção à minha estante' }}
                </button>
              } @else {
                <a class="adicionar-colecao link-botao" routerLink="/entrar">Entrar para adicionar à estante</a>
              }
            }
          </div>
          @if (mensagem()) { <p class="mensagem">{{ mensagem() }}</p> }
          @if (!modoPublico) {
            <nav class="filtros">
              <button [class.ativo]="filtro() === 'todas'" (click)="filtro.set('todas')">Todas</button>
              <button [class.ativo]="filtro() === 'nao-lidas'" (click)="filtro.set('nao-lidas')">Não lidas</button>
              <button [class.ativo]="filtro() === 'lidas'" (click)="filtro.set('lidas')">Lidas</button>
            </nav>
          }
        </section>
        <div class="secoes-guia">
          @for (secao of secoesFiltradas(); track secao.titulo) {
            <section class="secao-guia" [class.recolhida]="secaoRecolhida(secao.titulo)">
              <button class="cabecalho-secao" type="button" (click)="alternarSecao(secao.titulo)"
                [attr.aria-expanded]="!secaoRecolhida(secao.titulo)" [attr.aria-controls]="idSecao(secao.titulo)">
                <span>{{ secao.numero }}</span>
                <div><h2>{{ secao.titulo }}</h2><p>{{ secao.itens.length }} edições nesta etapa</p></div>
                <span class="indicador-secao" aria-hidden="true">⌄</span>
              </button>
              @if (!secaoRecolhida(secao.titulo)) {
                <div class="conteudo-secao" [id]="idSecao(secao.titulo)">
                  <div class="corpo-secao">
                    @if (destaqueSecao(secao.titulo); as destaque) {
                      <div class="destaque-secao" [class.somente-texto]="!destaque.imagem">
                        @if (destaque.imagem) { <img [src]="destaque.imagem" [alt]="destaque.alt" loading="lazy" /> }
                        <p>{{ destaque.descricao }}</p>
                      </div>
                    }
                    <div class="grade">
                      @for (item of secao.itens; track item.id) {
                        <article class="item" [class.lido]="item.lido">
                          <span class="posicao">{{ item.posicao }}</span>
                          <div class="capa"><img [src]="item.urlCapa || 'assets/capa-reserva.svg'" [alt]="item.titulo" loading="lazy" /></div>
                          <div class="dados"><h3>
                            @if (item.edicaoId) {
                              <a class="link-edicao" [routerLink]="['/catalogo']" [queryParams]="{ edicaoId: item.edicaoId }">{{ item.titulo }}</a>
                            } @else { {{ item.titulo }} }
                          </h3><p>{{ item.detalhe || 'Guia cronológico' }}</p>
                            @if (item.ano) { <p class="ano-item">{{ item.ano }}</p> }
                            @if (item.statusIdentificacao === 'PENDENTE_REVISAO') { <small>Identificação pendente de revisão</small> }
                            @if (item.observacao) { <p class="observacao-item">{{ item.observacao }}</p> }
                          </div>
                          @if (!modoPublico) {
                            <button class="marcar" type="button" [disabled]="alterando() === item.id" (click)="alternar(item)">
                              {{ item.lido ? '✓ Lida' : 'Marcar como lida' }}
                            </button>
                          }
                          @if (ehColecaoMarvelDeluxe() && item.edicaoId) {
                            @if (autenticado()) {
                              <button class="adicionar-item" type="button" [disabled]="adicionandoColecao() || adicionandoEdicoes().has(item.edicaoId!)" (click)="adicionarEdicao(item)">
                                {{ adicionandoEdicoes().has(item.edicaoId!) ? 'Adicionando...' : 'Adicionar à minha estante' }}
                              </button>
                            } @else {
                              <a class="adicionar-item link-botao" routerLink="/entrar">Adicionar à minha estante</a>
                            }
                          }
                        </article>
                      }
                    </div>
                  </div>
                </div>
              }
            </section>
          }
        </div>
      }
    </main>`,
  styles: [`
    .pagina{width:min(1240px,calc(100% - 28px));margin:auto;padding:28px 0 64px}.cabecalho{display:flex;justify-content:space-between;gap:24px;align-items:start;margin-bottom:28px}.rotulo,.selo{color:#ee7d20;font-size:.73rem;font-weight:800;letter-spacing:.12em}.cabecalho h1,.topo-ordem h2{margin:6px 0;font-size:clamp(2rem,5vw,3.5rem)}p{color:var(--texto-suave);margin:0}.lista-ordens{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px}.ordem{text-align:left;border:1px solid var(--borda);border-radius:24px;padding:26px;background:linear-gradient(145deg,var(--superficie),var(--superficie-2));color:var(--texto);cursor:pointer}.ordem h2{font-size:1.55rem;margin:8px 0}.ordem strong{display:block;margin-top:28px}.barra{height:8px;background:var(--borda);border-radius:9px;margin-top:10px;overflow:hidden}.barra span{display:block;height:100%;background:#ee7d20}.topo-ordem{margin-bottom:24px}.voltar,.filtros button{border:0;background:transparent;color:var(--texto-suave);cursor:pointer}.acoes-guia{display:flex;align-items:center;flex-wrap:wrap;gap:14px;margin:18px 0}.progresso{margin:0}.compartilhar{padding:10px 16px;border:0;border-radius:12px;background:#ee7d20;color:#20150c;font-weight:800;cursor:pointer}.mensagem{margin:0 0 14px;color:#247c4b}.filtros{display:flex;gap:8px}.filtros button{padding:9px 14px;border-radius:999px;background:var(--superficie-2)}.filtros button.ativo{background:#ee7d20;color:#18120d}.secoes-guia{display:grid;gap:42px}.secao-guia{scroll-margin-top:24px}.cabecalho-secao{display:flex;align-items:center;gap:14px;margin-bottom:18px;padding-bottom:14px;border-bottom:1px solid var(--borda)}.cabecalho-secao>span{display:grid;place-items:center;flex:0 0 42px;height:42px;border-radius:50%;background:#ee7d20;color:#20150c;font-weight:900}.cabecalho-secao h2{margin:0 0 3px;font-size:clamp(1.25rem,3vw,1.8rem)}.cabecalho-secao p{font-size:.86rem}.grade{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:18px}.item{position:relative;display:flex;flex-direction:column;border:1px solid var(--borda);border-radius:18px;background:var(--superficie);overflow:hidden}.item.lido{border-color:#41a66b}.posicao{position:absolute;z-index:1;top:9px;left:9px;background:#111d;color:#fff;border-radius:999px;padding:6px 10px;font-weight:800}.capa{aspect-ratio:2/3;background:var(--superficie-2)}.capa img{width:100%;height:100%;object-fit:cover}.dados{padding:14px;flex:1}.dados h3{font-size:1rem;margin:0 0 6px}.dados p,.dados small{font-size:.82rem}.dados small{color:#ee7d20}.marcar{margin:0 12px 12px;padding:11px;border:0;border-radius:12px;background:#ee7d20;color:#20150c;font-weight:800;cursor:pointer}.lido .marcar{background:#247c4b;color:#fff}@media(max-width:600px){.cabecalho{display:block}.cabecalho .botao{display:inline-block;margin-top:16px}.grade{grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.dados{padding:10px}.marcar{margin:0 8px 8px;font-size:.78rem;padding:9px 5px}.cabecalho-secao{align-items:flex-start}}
    .secoes-guia{gap:18px}.cabecalho-secao{width:100%;margin:0;padding:14px;border:1px solid var(--borda);border-radius:16px;background:var(--superficie);color:var(--texto);text-align:left;cursor:pointer;transition:border-color .2s ease,transform .2s ease,background .2s ease}.cabecalho-secao:hover,.cabecalho-secao:focus-visible{border-color:#ee7d20;background:var(--superficie-2);transform:translateY(-2px)}.cabecalho-secao>div{flex:1}.indicador-secao{font-size:1.55rem;transition:transform .25s ease}.recolhida .indicador-secao{transform:rotate(-90deg)}.conteudo-secao{padding-top:18px}.conteudo-secao>.corpo-secao{min-height:0;overflow:hidden}.item{transition:transform .25s ease,box-shadow .25s ease,border-color .25s ease}.item:hover,.item:focus-within{transform:translateY(-7px) scale(1.015);border-color:#ee7d20;box-shadow:0 16px 34px #0004}.capa{overflow:hidden}.capa img{transition:transform .4s ease,filter .4s ease}.item:hover .capa img,.item:focus-within .capa img,.item:active .capa img{transform:scale(1.065);filter:saturate(1.12) contrast(1.04)}@media(prefers-reduced-motion:reduce){.cabecalho-secao,.indicador-secao,.item,.capa img{transition:none}}
    .ano-item{margin-top:5px;font-weight:700}.observacao-item{margin-top:7px;font-size:.76rem;line-height:1.45;white-space:pre-line}.link-edicao{color:inherit;text-decoration-color:#ee7d20;text-decoration-thickness:2px;text-underline-offset:3px}.link-edicao:hover,.link-edicao:focus-visible{color:#ee7d20}.adicionar-colecao,.adicionar-item{padding:10px 16px;border:0;border-radius:12px;background:#ee7d20;color:#20150c;font-weight:800;cursor:pointer}.adicionar-colecao:disabled,.adicionar-item:disabled{opacity:.6;cursor:wait}.adicionar-item{margin:0 12px 12px}.link-botao{display:inline-block;text-align:center;text-decoration:none}
    .destaque-secao{display:grid;grid-template-columns:minmax(240px,520px) 1fr;align-items:center;gap:24px;margin-bottom:22px;padding:18px;border:1px solid var(--borda);border-radius:18px;background:var(--superficie)}.destaque-secao.somente-texto{grid-template-columns:1fr}.destaque-secao img{display:block;width:100%;border-radius:12px}.destaque-secao p{font-size:1rem;line-height:1.65;color:var(--texto)}@media(max-width:760px){.destaque-secao{grid-template-columns:1fr;padding:12px;gap:14px}.destaque-secao p{font-size:.92rem}}
  `]
})
export class OrdensLeituraPage implements OnInit {
  private api = inject(ApiService);
  private rota = inject(ActivatedRoute);
  private autenticacao = inject(AutenticacaoService);
  readonly autenticado = this.autenticacao.autenticado;
  ordens = signal<OrdemLeituraResumo[]>([]); selecionada = signal<OrdemLeituraDetalhe | null>(null);
  filtro = signal<'todas' | 'lidas' | 'nao-lidas'>('todas'); alterando = signal<number | null>(null); mensagem = signal('');
  secoesAbertas = signal<Set<string>>(new Set());
  adicionandoEdicoes = signal<Set<number>>(new Set());
  adicionandoColecao = signal(false);
  modoPublico = false;
  ngOnInit(){
    const slug = this.rota.snapshot.paramMap.get('slug');
    this.modoPublico = !!slug;
    if (slug) {
      this.api.obterOrdemLeituraPublica(slug).subscribe(v => this.selecionada.set(v));
      return;
    }
    this.api.listarOrdensLeitura().subscribe(v => this.ordens.set(v));
  }
  abrir(o: OrdemLeituraResumo){ this.api.obterOrdemLeitura(o.slug).subscribe(v => this.selecionada.set(v)); }
  percentual(o: OrdemLeituraResumo){ return o.totalItens ? o.itensLidos * 100 / o.totalItens : 0; }
  itensFiltrados(){ const o=this.selecionada(); if(!o)return[]; return o.itens.filter(i=>this.filtro()==='todas'||(this.filtro()==='lidas'?i.lido:!i.lido)); }
  secoesFiltradas(){
    const ordem = this.selecionada();
    const titulos = [...new Set((ordem?.itens || []).map(item => item.secao || 'Ordem de Leitura Mutante'))];
    const grupos = new Map<string, ItemOrdemLeitura[]>();
    for (const item of this.itensFiltrados()) {
      const titulo = item.secao || 'Ordem de Leitura Mutante';
      grupos.set(titulo, [...(grupos.get(titulo) || []), item]);
    }
    return [...grupos.entries()].map(([titulo, itens]) => ({ numero: titulos.indexOf(titulo) + 1, titulo, itens }));
  }
  secaoRecolhida(titulo: string){ return !this.secoesAbertas().has(titulo); }
  alternarSecao(titulo: string){ const abertas=new Set(this.secoesAbertas()); abertas.has(titulo)?abertas.delete(titulo):abertas.add(titulo); this.secoesAbertas.set(abertas); }
  idSecao(titulo: string){ return `secao-${titulo.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,'-')}`; }
  destaqueSecao(titulo: string){
    if (titulo === 'A saída de Chris Claremont e a X-Force') {
      return {
        imagem: 'assets/x-men-1-jim-lee.webp',
        alt: 'Os X-Men na fase desenhada por Jim Lee',
        descricao: 'Nos anos 90, após 16 anos com os Mutantes, Chris Claremont abandona os roteiros. Nesta época, surge uma nova equipe: a X-Force, oriunda dos antigos Novos Mutantes. Esta equipe é liderada pelo viajante do tempo Cable, um poderoso mutante do futuro. Seguem as sagas a partir desta época.'
      };
    }
    if (titulo === 'Fase Grant Morrison: Novos X-Men') {
      return {
        imagem: '',
        alt: '',
        descricao: 'Junto com o sucesso do filme live-action dos Mutantes nos anos 2000, o renomado roteirista Grant Morrison assumiu os quadrinhos dos mutantes, em uma fase memorável da equipe.'
      };
    }
    if (titulo === 'Fase Joss Whedon') {
      return {
        imagem: '',
        alt: '',
        descricao: 'Esta fase trouxe de volta o tom mais heroico dos X-Men, bem como os uniformes coloridos. É uma fase curta, mas muito boa, repleta de aventura e nostalgia.'
      };
    }
    if (titulo === 'Fase da dizimação mutante') {
      return {
        imagem: '',
        alt: '',
        descricao: 'A partir daqui, entramos com tudo nos eventos da dizimação mutante e na separação dos membros. É uma fase importantíssima para a leitura.'
      };
    }
    if (titulo === 'FABULOSOS X-MEN E NOVÍSSIMOS X-MEN') {
      return {
        imagem: '',
        alt: '',
        descricao: 'Logo após Vingadores vs. X-Men, as histórias dos X-Men foram ramificadas em duas revistas que se alternavam: Os Fabulosos X-Men e Novíssimos X-Men.'
      };
    }
    return null;
  }
  alternar(item: ItemOrdemLeitura){ this.alterando.set(item.id); this.api.atualizarProgressoOrdem(item.id,!item.lido).subscribe({next:v=>{const o=this.selecionada();if(!o)return;const itens=o.itens.map(i=>i.id===v.id?v:i);this.selecionada.set({...o,itens,itensLidos:itens.filter(i=>i.lido).length});},error:()=>this.alterando.set(null),complete:()=>this.alterando.set(null)}); }
  ehColecaoMarvelDeluxe(){ return this.selecionada()?.slug === 'colecao-marvel-deluxe-capa-preta'; }
  adicionarEdicao(item: ItemOrdemLeitura){
    if(!item.edicaoId || !this.autenticado())return;
    this.adicionandoEdicoes.update(ids=>new Set(ids).add(item.edicaoId!));
    this.mensagem.set('');
    this.api.cadastrarItemColecao({
      edicaoId:item.edicaoId,estadoConservacao:'MUITO_BOM',dataAquisicao:null,
      precoPago:null,statusLeitura:'NAO_LIDO',observacoes:null
    }).subscribe({
      next:()=>this.mensagem.set(`${item.titulo} foi adicionada à sua estante.`),
      error:erro=>{
        this.mensagem.set(erro?.error?.mensagem || 'Esta edição já está na sua estante ou não pôde ser adicionada.');
        this.finalizarAdicaoEdicao(item.edicaoId!);
      },
      complete:()=>this.finalizarAdicaoEdicao(item.edicaoId!)
    });
  }
  async adicionarColecaoCompleta(){
    if(!this.autenticado() || this.adicionandoColecao())return;
    const seriesIds=[...new Set((this.selecionada()?.itens || [])
      .map(item=>item.serieId).filter((id):id is number=>id!==null))];
    this.adicionandoColecao.set(true);
    this.mensagem.set('Adicionando a coleção Marvel Deluxe à sua estante...');
    try{
      const resultados=await Promise.all(seriesIds.map(serieId=>firstValueFrom(this.api.cadastrarSerieNaColecao({
        serieId,estadoConservacao:'MUITO_BOM',dataAquisicao:null,precoPago:null,
        statusLeitura:'NAO_LIDO',observacoes:null
      }))));
      const adicionadas=resultados.reduce((total,item)=>total+item.adicionadas,0);
      const existentes=resultados.reduce((total,item)=>total+item.jaExistentes,0);
      this.mensagem.set(`${adicionadas} revista(s) adicionada(s) à estante. ${existentes} já existente(s) foram ignorada(s).`);
    }catch{
      this.mensagem.set('Não foi possível adicionar toda a coleção agora. Tente novamente.');
    }finally{
      this.adicionandoColecao.set(false);
    }
  }
  private finalizarAdicaoEdicao(edicaoId:number){
    this.adicionandoEdicoes.update(ids=>{const atual=new Set(ids);atual.delete(edicaoId);return atual;});
  }
  async compartilharGuia(){
    const ordem=this.selecionada(); if(!ordem)return;
    const link=ordem.slug === 'ordem-de-leitura-mutante'
      ? 'https://hqhub-backend.onrender.com/api/compartilhar/guias/xmen?v=2'
      : `https://hqhub-backend.onrender.com/api/compartilhar/guias/${encodeURIComponent(ordem.slug)}?v=2`;
    const dados={title:ordem.titulo,text:`Confira o guia de leitura ${ordem.titulo} no HQ-HUB`,url:link};
    try {
      if(navigator.share){await navigator.share(dados);return;}
      await navigator.clipboard.writeText(link);
      this.mensagem.set('Link público copiado.');
    } catch(erro){if(!(erro instanceof DOMException&&erro.name==='AbortError'))this.mensagem.set('Não foi possível compartilhar agora.');}
  }
}
