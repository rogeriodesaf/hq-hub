export interface PaginaResposta<T> {
  itens: T[];
  pagina: number;
  tamanho: number;
  totalItens: number;
  totalPaginas: number;
}

export interface UsuarioAutenticado {
  id: number;
  nome: string;
  email: string;
  token: string;
  tipoToken: string;
  expiraEm: number;
  mensagem: string;
}

export interface ColecaoResumo {
  totalItens: number;
  totalSeries: number;
  totalEditoras: number;
  valorTotalPago: number;
}

export interface EditoraResumo {
  id: number;
  nome: string;
}

export interface SerieResumo {
  id: number;
  titulo: string;
  volume: number | null;
  editora: EditoraResumo | null;
}

export interface Serie {
  id: number;
  titulo: string;
  descricao: string | null;
  anoInicio: number | null;
  anoFim: number | null;
  volume: number | null;
  ordemCronologica: number | null;
  fonteExterna: string | null;
  idExterno: string | null;
  urlOrigem: string | null;
  editora: EditoraResumo | null;
}

export interface Edicao {
  id: number;
  numero: string;
  titulo: string | null;
  descricao: string | null;
  dataPublicacao: string | null;
  urlCapa: string | null;
  codigoBarras: string | null;
  quantidadePaginas: number | null;
  precoCapa: number | null;
  fonteExterna: string | null;
  idExterno: string | null;
  urlOrigem: string | null;
  serie: SerieResumo | null;
}

export interface VolumeComicVine {
  idExterno: string;
  titulo: string;
  editora: string | null;
  anoInicio: number | null;
  quantidadeEdicoes: number | null;
  descricao: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
}

export interface CreditoComicVine {
  idExterno: string | null;
  nome: string | null;
  papel: string | null;
  urlOrigem: string | null;
}

export interface EdicaoComicVine {
  idExterno: string;
  numero: string | null;
  titulo: string | null;
  nomeVolume: string | null;
  idVolume: string | null;
  dataCapa: string | null;
  dataVenda: string | null;
  descricao: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
  creditos: CreditoComicVine[];
  personagens: string[];
}

export interface EstanteEdicao {
  itemColecaoId: number;
  edicaoId: number;
  numero: string;
  titulo: string | null;
  urlCapa: string | null;
  estadoConservacao: string;
}

export interface EstanteSerie {
  serieId: number;
  titulo: string;
  edicoes: EstanteEdicao[];
}

export interface EstanteEditora {
  editoraId: number;
  nome: string;
  series: EstanteSerie[];
}

export interface CompraPlanejada {
  id: number;
  edicao: Edicao;
  mes: number;
  ano: number;
  status: string;
  prioridade: string;
  precoEstimado: number | null;
  linkCompra: string | null;
  observacoes: string | null;
}

export interface RespostaAssistente {
  resposta: string;
  origem: string;
  dados: unknown;
}

export interface PublicacaoRelacionada {
  id: number;
  edicaoOrigem: Edicao;
  edicaoDestino: Edicao;
  tipo: string;
  fonteExterna: string | null;
  urlOrigem: string | null;
  observacoes: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}
