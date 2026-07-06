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
  perfil: 'USUARIO' | 'COLABORADOR' | 'ADMINISTRADOR';
  bio: string | null;
  fotoPerfilUrl: string | null;
  fotoPerfilThumbnailUrl: string | null;
  token: string;
  tipoToken: string;
  expiraEm: number;
  mensagem: string;
}

export interface Usuario {
  id: number;
  nome: string;
  email: string;
  perfil: 'USUARIO' | 'COLABORADOR' | 'ADMINISTRADOR';
  bio: string | null;
  fotoPerfilUrl: string | null;
  fotoPerfilThumbnailUrl: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface ColecaoResumo {
  totalItens: number;
  totalSeries: number;
  totalEditoras: number;
  valorTotalPago: number;
}

export interface ConfiguracaoColecao {
  id: number;
  visibilidadeColecao: 'PRIVADA' | 'AMIGOS' | 'PUBLICA';
  exibirValorColecao: boolean;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface ColecaoCompartilhada {
  usuario: Usuario;
  visibilidadeColecao: 'PRIVADA' | 'AMIGOS' | 'PUBLICA';
  exibirValorColecao: boolean;
  itens: ItemColecao[];
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
  descricaoOriginal: string | null;
  descricaoPortugues: string | null;
  descricaoExibicao: string | null;
  nomeVolume: string | null;
  dataCobertura: string | null;
  dataDisponibilidadeLoja: string | null;
  dataPublicacao: string | null;
  urlCapa: string | null;
  codigoBarras: string | null;
  quantidadePaginas: number | null;
  precoCapa: number | null;
  formato: string | null;
  fonteExterna: string | null;
  idExterno: string | null;
  urlOrigem: string | null;
  urlComicVine: string | null;
  idComicVine: string | null;
  serie: SerieResumo | null;
}

export type StatusCapaEdicao = 'PENDENTE' | 'APROVADA' | 'REJEITADA';
export type OrigemCapaEdicao = 'COMIC_VINE' | 'UPLOAD_MANUAL' | 'URL_MANUAL' | 'IMPORTACAO_JSON';

export interface CapaEdicao {
  id: number;
  edicaoId: number;
  urlImagem: string;
  publicIdCloudinary: string | null;
  enviadoPorUsuarioId: number | null;
  enviadoPorNome: string | null;
  status: StatusCapaEdicao;
  origem: OrigemCapaEdicao;
  observacao: string | null;
  dataEnvio: string;
  dataAprovacao: string | null;
  aprovadoPorUsuarioId: number | null;
  aprovadoPorNome: string | null;
}

export interface ResultadoImportacaoCapas {
  total: number;
  sucessos: number;
  erros: number;
  itens: Array<{
    idEdicao: number | null;
    urlImagem: string | null;
    sucesso: boolean;
    mensagem: string;
    capa: CapaEdicao | null;
  }>;
}

export interface LinkEdicao {
  id: number;
  edicaoId: number;
  tipo: 'AMAZON' | 'COMPRA' | 'REFERENCIA' | 'WIKIPEDIA' | 'GUIA_DOS_QUADRINHOS' | 'OUTRO';
  titulo: string;
  url: string;
  observacoes: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface ResultadoPesquisaCatalogo {
  id: number | null;
  idExterno: string | null;
  fonte: 'HQ_HUB' | 'COMIC_VINE';
  titulo: string | null;
  numero: string | null;
  nomeVolume: string | null;
  serieVolume: number | null;
  urlCapa: string | null;
  dataPublicacao: string | null;
  jaCadastrada: boolean;
  urlOrigem: string | null;
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

export interface PessoaComicVine {
  idExterno: string;
  nome: string | null;
  descricao: string | null;
  descricaoOriginal: string | null;
  dataNascimento: string | null;
  pais: string | null;
  genero: string | null;
  aliases: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
}

export interface EdicaoComicVine {
  idExterno: string;
  numero: string | null;
  titulo: string | null;
  nomeVolume: string | null;
  editora: string | null;
  idVolume: string | null;
  dataCapa: string | null;
  dataVenda: string | null;
  descricao: string | null;
  descricaoOriginal: string | null;
  descricaoPortugues: string | null;
  descricaoExibicao: string | null;
  urlOrigem: string | null;
  urlImagem: string | null;
  creditos: CreditoComicVine[];
  personagens: string[];
  conteudos: string[];
}

export interface ItemColecao {
  id: number;
  edicao: Edicao;
  estadoConservacao: string;
  dataAquisicao: string | null;
  precoPago: number | null;
  statusLeitura: string;
  observacoes: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface CadastroItemColecao {
  edicaoId: number;
  estadoConservacao: string;
  dataAquisicao: string | null;
  precoPago: number | null;
  statusLeitura: string;
  observacoes: string | null;
  suprimirRevisaoCatalogo?: boolean;
}

export interface EstanteEdicao {
  itemColecaoId: number;
  edicaoId: number;
  numero: string;
  titulo: string | null;
  urlCapa: string | null;
  estadoConservacao: string;
  statusLeitura: string;
  dataAquisicao: string | null;
  precoPago: number | null;
}

export interface EstanteSerie {
  serieId: number;
  titulo: string;
  volume: number | null;
  edicoes: EstanteEdicao[];
}

export interface EstanteEditora {
  editoraId: number;
  nome: string;
  series: EstanteSerie[];
}

export interface GrupoDuplicidadeEdicao {
  chave: string;
  edicaoMantida: Edicao;
  edicoesDescartadas: Edicao[];
  pontuacaoMantida: number;
}

export interface ResultadoDeduplicacaoEdicoes {
  gruposAnalisados: number;
  gruposMesclados: number;
  edicoesRemovidas: number;
  referenciasAtualizadas: number;
  grupos: GrupoDuplicidadeEdicao[];
}

export interface GrupoDuplicidadeSerie {
  chave: string;
  serieMantida: Serie;
  seriesDescartadas: Serie[];
  pontuacaoMantida: number;
}

export interface ResultadoDeduplicacaoSeries {
  gruposAnalisados: number;
  gruposMesclados: number;
  seriesRemovidas: number;
  edicoesMescladas: number;
  referenciasAtualizadas: number;
  grupos: GrupoDuplicidadeSerie[];
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

export type TipoAnuncio = 'VENDA' | 'TROCA' | 'VENDA_E_TROCA';
export type StatusAnuncio = 'ATIVO' | 'PAUSADO' | 'ENCERRADO' | 'REMOVIDO';
export type EstadoConservacao = 'NOVO' | 'EXCELENTE' | 'MUITO_BOM' | 'BOM' | 'REGULAR' | 'RUIM';

export interface Anuncio {
  id: number;
  edicaoId: number;
  tituloEdicao: string;
  nomeAnunciante: string;
  anunciante: Usuario;
  itemColecao: ItemColecao;
  tipoAnuncio: TipoAnuncio;
  preco: number | null;
  estadoConservacao: EstadoConservacao;
  descricao: string | null;
  cidade: string | null;
  estado: string | null;
  exibirWhatsapp: boolean;
  contatoWhatsapp: string | null;
  linkContatoWhatsapp: string | null;
  status: StatusAnuncio;
  avisoResponsabilidade: string;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface CadastroAnuncio {
  itemColecaoId: number;
  tipoAnuncio: TipoAnuncio;
  preco: number | null;
  estadoConservacao: EstadoConservacao;
  descricao: string | null;
  cidade: string | null;
  estado: string | null;
  contatoWhatsapp: string | null;
  exibirWhatsapp: boolean;
}

export interface ContatoAnuncio {
  anuncioId: number;
  contatoWhatsapp: string;
  mensagem: string;
  linkWhatsapp: string;
  avisoResponsabilidade: string;
}

export interface CadastroCompraPlanejada {
  edicaoId: number;
  mes: number;
  ano: number;
  prioridade: string;
  status: string;
  precoEstimado: number | null;
  linkCompra: string | null;
  observacoes: string | null;
}

export interface CalculoInflacao {
  valorOriginal: number;
  valorCorrigido: number;
  fatorCorrecao: number;
  percentualAcumulado: number;
  dataReferencia: string;
  dataCalculo: string;
  indice: string;
  observacao: string;
}

export interface RespostaAssistente {
  resposta: string;
  origem: string;
  dados: unknown;
}

export interface AssistenteFaqItem {
  id: string;
  intencao: string;
  modulo: string;
  pergunta: string;
  variacoes: string[];
  resposta: string;
  tags: string[];
  acaoSugerida: string;
}

export interface AssistenteFaqBase {
  schemaVersion: string;
  idioma: string;
  geradoEm: string;
  descricao: string;
  itens: AssistenteFaqItem[];
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

export type TipoConteudoEdicao =
  | 'HISTORIA'
  | 'POSTER'
  | 'GALERIA'
  | 'MATERIAL_EDITORIAL'
  | 'EXTRA'
  | 'CAPA'
  | 'PINUP'
  | 'EDITORIAL'
  | 'CHECKLIST'
  | 'ENTREVISTA'
  | 'MATERIA'
  | 'PROPAGANDA'
  | 'OUTRO';

export type StatusPublicacaoHistoria = 'COMPLETA' | 'PARCIAL' | 'CORTADA' | 'ADAPTADA' | 'DESCONHECIDA';
export type TipoPublicacaoHistoria = 'ORIGINAL' | 'REPUBLICACAO' | 'PUBLICACAO_BRASILEIRA' | 'PUBLICACAO_ESTRANGEIRA';

export interface Historia {
  id: number;
  titulo: string;
  tituloOriginal: string | null;
  tituloPortugues: string | null;
  tituloExibicao: string | null;
  descricao: string | null;
  descricaoOriginal: string | null;
  descricaoPortugues: string | null;
  descricaoExibicao: string | null;
  quantidadePaginas: number | null;
  tipo: TipoConteudoEdicao;
  fonteExterna: string | null;
  idExterno: string | null;
  urlOrigem: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface ConteudoEdicao {
  id: number;
  edicao: Edicao;
  historia: Historia;
  ordem: number;
  tituloUsado: string | null;
  paginaInicio: number | null;
  paginaFim: number | null;
  quantidadePaginas: number | null;
  tipo: TipoConteudoEdicao;
  observacoes: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface PublicacaoHistoria {
  id: number;
  historia: Historia;
  edicaoOriginal: Edicao;
  edicaoPublicada: Edicao;
  status: StatusPublicacaoHistoria;
  tipoPublicacaoHistoria: TipoPublicacaoHistoria;
  fonteInformacao: string | null;
  urlFonteInformacao: string | null;
  statusValidacao: string | null;
  tituloUsado: string | null;
  paginasPublicadas: number | null;
  paginasCortadas: number | null;
  fonteExterna: string | null;
  urlOrigem: string | null;
  observacoes: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface CruzamentoEdicao {
  edicaoOriginal: Edicao;
  edicaoComparada: Edicao;
  conteudosOriginais: ConteudoEdicao[];
  historiasIncluidas: PublicacaoHistoria[];
  conteudosFora: ConteudoEdicao[];
  totalConteudosOriginais: number;
  totalHistoriasIncluidas: number;
  totalConteudosFora: number;
}

export type TipoContribuicaoCatalogo =
  | 'CAPA_EDICAO'
  | 'DADOS_EDICAO'
  | 'PUBLICACAO_BRASILEIRA'
  | 'LINK_GUIA_DOS_QUADRINHOS'
  | 'OUTRA_INFORMACAO';

export type StatusContribuicaoCatalogo = 'PENDENTE' | 'APROVADA' | 'APLICADA' | 'RECUSADA';

export interface ContribuicaoCatalogo {
  id: number;
  usuario: Usuario;
  edicao: Edicao;
  tipo: TipoContribuicaoCatalogo;
  status: StatusContribuicaoCatalogo;
  urlCapaSugerida: string | null;
  edicaoDestinoId: number | null;
  tipoPublicacaoRelacionada: string | null;
  fonteExterna: string | null;
  urlFonte: string | null;
  dadosSugeridosJson: string | null;
  observacoes: string | null;
  mensagemRevisao: string | null;
  revisor: Usuario | null;
  dataRevisao: string | null;
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface ResultadoImportacaoCatalogo {
  serieId: number;
  serieTitulo: string;
  editorasCriadas: number;
  seriesCriadas: number;
  edicoesCriadas: number;
  edicoesAtualizadas: number;
  historiasCriadas: number;
  conteudosCriados: number;
  publicacoesCriadas: number;
  itensReaproveitados: number;
  avisos: string[];
}

export interface GeracaoRascunhoImportacao {
  urlGuia: string;
  urlPaniniInicial: string | null;
  quantidade: number;
  tituloSerie: string;
  fase: string | null;
  editora: string;
  volume: number | null;
}

export interface Amizade {
  id: number;
  solicitante: Usuario;
  solicitado: Usuario;
  status: string;
  dataSolicitacao: string;
  dataResposta: string | null;
}

export interface ComentarioFeed {
  id: number;
  usuario: Usuario;
  texto: string;
  dataCriacao: string;
}

export interface ComentarioColecao {
  id: number;
  usuario: Usuario;
  texto: string;
  dataCriacao: string;
}

export interface InteracaoSocialColecao {
  totalCurtidas: number;
  curtidaPeloUsuario: boolean;
  comentarios: ComentarioColecao[];
}

export interface InteracaoItemColecao extends InteracaoSocialColecao {
  itemColecaoId: number;
}

export interface InteracoesColecaoUsuario {
  usuarioId: number;
  colecao: InteracaoSocialColecao;
  itens: InteracaoItemColecao[];
}

export interface ImagemFeed {
  urlImagem: string;
  urlThumbnail: string;
  nomeArquivo: string;
  tipoMime: string;
  tamanhoBytes: number;
  largura: number | null;
  altura: number | null;
  ordem: number | null;
}

export interface ColecaoFeed {
  itemColecaoId: number;
  serieId: number;
  titulo: string;
  editora: string;
  quantidadeEdicoes: number;
  urlCapa: string | null;
  concluida: boolean;
}

export interface CatalogoFeed {
  serieId: number;
  titulo: string;
  editora: string;
  quantidadeEdicoes: number;
  urlCapa: string | null;
}

export interface PostagemFeed {
  id: number;
  usuario: Usuario;
  conteudo: string;
  urlImagem: string | null;
  imagens: ImagemFeed[];
  colecaoDestaque: ColecaoFeed | null;
  catalogoDestaque: CatalogoFeed | null;
  totalCurtidas: number;
  curtidaPeloUsuario: boolean;
  comentarios: ComentarioFeed[];
  dataCriacao: string;
  dataAtualizacao: string;
}

export interface MensagemDireta {
  id: number;
  remetente: Usuario;
  destinatario: Usuario;
  texto: string;
  lida: boolean;
  dataCriacao: string;
}

export interface ConversaDireta {
  usuario: Usuario;
  ultimaMensagem: MensagemDireta;
  naoLidas: number;
  dataUltimaMensagem: string;
}

export interface PerfilResumo {
  id: number;
  nome: string;
  bio: string | null;
  fotoPerfilUrl: string | null;
  fotoPerfilThumbnailUrl: string | null;
}

export interface EstatisticasPublicasColecao {
  totalItens: number;
  totalSeries: number;
  totalEditoras: number;
  totalLidos: number;
  totalNaoLidos: number;
  valorTotalPago: number;
}
