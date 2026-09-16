import { HistoriaLeitura } from '../../core/modelos';
import { agruparHistorias, historiaAdjacente } from './historias-agrupamento';

describe('agrupamento de stories', () => {
  const agora = Date.parse('2026-09-16T12:00:00Z');
  const historia = (id: number, autorId: number, minuto: number, visualizada = false, expirada = false) => ({
    id,
    usuario: { id: autorId, nome: autorId === 1 ? 'Eu' : 'Amigo' },
    dataCriacao: new Date(agora - (20 - minuto) * 60_000).toISOString(),
    dataExpiracao: new Date(agora + (expirada ? -1 : 60_000)).toISOString(),
    visualizada,
  }) as unknown as HistoriaLeitura;

  it('mostra um grupo por autor, o próprio primeiro e stories em ordem', () => {
    const grupos = agruparHistorias([
      historia(3, 1, 3), historia(1, 2, 1, true), historia(2, 1, 2), historia(4, 2, 4),
    ], 1, agora);
    expect(grupos.map((grupo) => grupo.usuario.id)).toEqual([1, 2]);
    expect(grupos[0].historias.map((item) => item.id)).toEqual([2, 3]);
    expect(grupos[1].naoVistas).toBeTrue();
    expect(historiaAdjacente(grupos[0], 2, 1)?.id).toBe(3);
    expect(historiaAdjacente(grupos[0], 3, -1)?.id).toBe(2);
    expect(historiaAdjacente(grupos[0], 3, 1)).toBeNull();
  });

  it('fica cinza quando todos foram vistos e remove grupos expirados', () => {
    const grupos = agruparHistorias([historia(1, 2, 1, true), historia(2, 1, 2, false, true)], 1, agora);
    expect(grupos.length).toBe(1);
    expect(grupos[0].naoVistas).toBeFalse();
  });
});
