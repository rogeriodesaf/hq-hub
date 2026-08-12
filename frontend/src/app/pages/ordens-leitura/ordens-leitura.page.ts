import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ApiService } from '../../core/api.service';
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
        <a class="botao secundario" routerLink="/painel">Voltar</a>
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
          <button class="voltar" type="button" (click)="selecionada.set(null)">← Todas as ordens</button>
          <h2>{{ selecionada()!.titulo }}</h2><p>{{ selecionada()!.descricao }}</p>
          <div class="progresso"><strong>{{ selecionada()!.itensLidos }} de {{ selecionada()!.totalItens }}</strong> edições lidas</div>
          <nav class="filtros">
            <button [class.ativo]="filtro() === 'todas'" (click)="filtro.set('todas')">Todas</button>
            <button [class.ativo]="filtro() === 'nao-lidas'" (click)="filtro.set('nao-lidas')">Não lidas</button>
            <button [class.ativo]="filtro() === 'lidas'" (click)="filtro.set('lidas')">Lidas</button>
          </nav>
        </section>
        <section class="grade">
          @for (item of itensFiltrados(); track item.id) {
            <article class="item" [class.lido]="item.lido">
              <span class="posicao">{{ item.posicao }}</span>
              <div class="capa"><img [src]="item.urlCapa || 'assets/capa-reserva.svg'" [alt]="item.titulo" loading="lazy" /></div>
              <div class="dados"><h3>{{ item.titulo }}</h3><p>{{ item.detalhe || 'Ordem de Leitura Mutante' }}</p>
                @if (!item.vinculadoCatalogo) { <small>Catálogo em revisão</small> }
              </div>
              <button class="marcar" type="button" [disabled]="alterando() === item.id" (click)="alternar(item)">
                {{ item.lido ? '✓ Lida' : 'Marcar como lida' }}
              </button>
            </article>
          }
        </section>
      }
    </main>`,
  styles: [`
    .pagina{width:min(1240px,calc(100% - 28px));margin:auto;padding:28px 0 64px}.cabecalho{display:flex;justify-content:space-between;gap:24px;align-items:start;margin-bottom:28px}.rotulo,.selo{color:#ee7d20;font-size:.73rem;font-weight:800;letter-spacing:.12em}.cabecalho h1,.topo-ordem h2{margin:6px 0;font-size:clamp(2rem,5vw,3.5rem)}p{color:var(--texto-suave);margin:0}.lista-ordens{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px}.ordem{text-align:left;border:1px solid var(--borda);border-radius:24px;padding:26px;background:linear-gradient(145deg,var(--superficie),var(--superficie-2));color:var(--texto);cursor:pointer}.ordem h2{font-size:1.55rem;margin:8px 0}.ordem strong{display:block;margin-top:28px}.barra{height:8px;background:var(--borda);border-radius:9px;margin-top:10px;overflow:hidden}.barra span{display:block;height:100%;background:#ee7d20}.topo-ordem{margin-bottom:24px}.voltar,.filtros button{border:0;background:transparent;color:var(--texto-suave);cursor:pointer}.progresso{margin:18px 0}.filtros{display:flex;gap:8px}.filtros button{padding:9px 14px;border-radius:999px;background:var(--superficie-2)}.filtros button.ativo{background:#ee7d20;color:#18120d}.grade{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:18px}.item{position:relative;display:flex;flex-direction:column;border:1px solid var(--borda);border-radius:18px;background:var(--superficie);overflow:hidden}.item.lido{border-color:#41a66b}.posicao{position:absolute;z-index:1;top:9px;left:9px;background:#111d;color:#fff;border-radius:999px;padding:6px 10px;font-weight:800}.capa{aspect-ratio:2/3;background:var(--superficie-2)}.capa img{width:100%;height:100%;object-fit:cover}.dados{padding:14px;flex:1}.dados h3{font-size:1rem;margin:0 0 6px}.dados p,.dados small{font-size:.82rem}.dados small{color:#ee7d20}.marcar{margin:0 12px 12px;padding:11px;border:0;border-radius:12px;background:#ee7d20;color:#20150c;font-weight:800;cursor:pointer}.lido .marcar{background:#247c4b;color:#fff}@media(max-width:600px){.cabecalho{display:block}.cabecalho .botao{display:inline-block;margin-top:16px}.grade{grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.dados{padding:10px}.marcar{margin:0 8px 8px;font-size:.78rem;padding:9px 5px}}
  `]
})
export class OrdensLeituraPage implements OnInit {
  private api = inject(ApiService);
  ordens = signal<OrdemLeituraResumo[]>([]); selecionada = signal<OrdemLeituraDetalhe | null>(null);
  filtro = signal<'todas' | 'lidas' | 'nao-lidas'>('todas'); alterando = signal<number | null>(null);
  ngOnInit(){ this.api.listarOrdensLeitura().subscribe(v => this.ordens.set(v)); }
  abrir(o: OrdemLeituraResumo){ this.api.obterOrdemLeitura(o.slug).subscribe(v => this.selecionada.set(v)); }
  percentual(o: OrdemLeituraResumo){ return o.totalItens ? o.itensLidos * 100 / o.totalItens : 0; }
  itensFiltrados(){ const o=this.selecionada(); if(!o)return[]; return o.itens.filter(i=>this.filtro()==='todas'||(this.filtro()==='lidas'?i.lido:!i.lido)); }
  alternar(item: ItemOrdemLeitura){ this.alterando.set(item.id); this.api.atualizarProgressoOrdem(item.id,!item.lido).subscribe({next:v=>{const o=this.selecionada();if(!o)return;const itens=o.itens.map(i=>i.id===v.id?v:i);this.selecionada.set({...o,itens,itensLidos:itens.filter(i=>i.lido).length});},error:()=>this.alterando.set(null),complete:()=>this.alterando.set(null)}); }
}
