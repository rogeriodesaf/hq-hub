import { HistoriaLeitura, Usuario } from '../../core/modelos';

export interface GrupoHistorias {
  usuario: Usuario;
  historias: HistoriaLeitura[];
  naoVistas: boolean;
}

export function agruparHistorias(historias: HistoriaLeitura[], usuarioId: number | undefined, agora = Date.now()): GrupoHistorias[] {
  const grupos = new Map<number, GrupoHistorias>();
  for (const historia of historias) {
    if (new Date(historia.dataExpiracao).getTime() <= agora) continue;
    let grupo = grupos.get(historia.usuario.id);
    if (!grupo) {
      grupo = { usuario: historia.usuario, historias: [], naoVistas: false };
      grupos.set(historia.usuario.id, grupo);
    }
    grupo.historias.push(historia);
    grupo.naoVistas ||= !historia.visualizada;
  }
  return [...grupos.values()]
    .map((grupo) => ({
      ...grupo,
      historias: grupo.historias.sort((a, b) =>
        new Date(a.dataCriacao).getTime() - new Date(b.dataCriacao).getTime() || a.id - b.id),
    }))
    .sort((a, b) => {
      if (a.usuario.id === usuarioId) return -1;
      if (b.usuario.id === usuarioId) return 1;
      return new Date(b.historias.at(-1)!.dataCriacao).getTime()
        - new Date(a.historias.at(-1)!.dataCriacao).getTime();
    });
}

export function historiaAdjacente(grupo: GrupoHistorias | undefined, historiaId: number, deslocamento: number): HistoriaLeitura | null {
  const indice = grupo?.historias.findIndex((historia) => historia.id === historiaId) ?? -1;
  return indice < 0 ? null : grupo?.historias[indice + deslocamento] ?? null;
}
