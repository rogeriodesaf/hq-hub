// Consulta somente leitura; não publica dados nem modifica o catálogo.
import fs from 'node:fs';
const arquivos = [
  ...fs.readdirSync('docs/importacao').filter(f => /^saga-homem-aranha-1-serie.*json$/.test(f)).map(f => 'docs/importacao/' + f),
  ...fs.readdirSync('rascunhos-importacao').filter(f => /^a-saga-do-homem-aranha.*json$/.test(f)).map(f => 'rascunhos-importacao/' + f),
];
const edicoes = new Map();
for (const arquivo of arquivos) {
  const json = JSON.parse(fs.readFileSync(arquivo, 'utf8'));
  const volume = json.serieBrasileira.volume || 1;
  for (const edicao of json.edicoes) edicoes.set(`${volume}/${edicao.numero}`, { volume, edicao, arquivo });
}
const verificadas = [];
for (const { volume, edicao, arquivo } of edicoes.values()) {
  const historias = edicao.historias.filter(h => h.publicacaoOriginal?.serieOriginal === 'Amazing Spider-Man, The (1963)');
  if (!historias.length) continue;
  const numero = Number(edicao.numero);
  const url = `https://panini.com.br/a-saga-do-homem-aranha-${volume === 1 ? String(numero).padStart(2, '0') : `${numero}-${numero + 24}`}`;
  const resposta = await fetch(url);
  const html = await resposta.text();
  const conteudo = html.match(/data-th="Conte[^\"]*"[^>]*>([\s\S]*?)<\/td>/)?.[1]?.replace(/<[^>]+>/g, '').trim() || '';
  const trecho = conteudo.match(/(?:The )?Amazing Spider-Man \(1963\)\s+([^;.]*)/i)?.[1] || '';
  const numeros = new Set();
  for (const item of trecho.split(/[,/&]/)) {
    const m = item.trim().match(/^(\d+)(?:\s*[-–]\s*(\d+))?$/);
    if (m) for (let n = Number(m[1]); n <= Number(m[2] || m[1]); n++) numeros.add(n);
  }
  const linhas = historias.filter(h => numeros.has(Number(h.publicacaoOriginal.numeroOriginal)));
  console.error(`${volume}/${numero}: HTTP ${resposta.status}; ${linhas.length}/${historias.length}; ${conteudo}`);
  if (resposta.ok && linhas.length === historias.length) verificadas.push({ volume, numero, url, conteudo, arquivo, historias: linhas });
}
// Saída consumida pelo gerador de migração; a identidade e os números são verificáveis.
console.log(JSON.stringify(verificadas));
