// node este-arquivo.cjs /caminho/node_modules/@electric-sql/pglite/dist/index.cjs
const { readFileSync } = require('node:fs');
const assert = require('node:assert/strict');
const { PGlite } = require(process.argv[2]);
const pasta = 'docs/importacao/rascunhos/batman-capas-20260905/';
const antes = JSON.parse(readFileSync(pasta + 'antes.json', 'utf8'));
const capas = JSON.parse(readFileSync(pasta + 'capas-revisadas.json', 'utf8'));
const sql = readFileSync('backend/src/main/resources/db/migration/V357__preencher_capas_referencias_guia_batman.sql', 'utf8');
const normalizar = readFileSync('backend/src/main/resources/db/migration/V55__travar_identidade_catalogo.sql', 'utf8').split('$$ LANGUAGE SQL IMMUTABLE;')[0] + '$$ LANGUAGE SQL IMMUTABLE;';
(async () => {
  const db = new PGlite();
  await db.exec(normalizar);
  await db.exec(`CREATE TABLE ordens_leitura (id bigint PRIMARY KEY, slug text UNIQUE);
    CREATE TABLE itens_ordem_leitura (id bigint PRIMARY KEY, ordem_leitura_id bigint REFERENCES ordens_leitura,
      posicao integer NOT NULL, titulo_referencia varchar(300), edicao_id bigint, url_capa_referencia varchar(1000),
      UNIQUE (ordem_leitura_id, posicao));
    INSERT INTO ordens_leitura VALUES (2, 'batman-ordem-cronologica'), (999, 'outro-guia');`);
  for (const x of antes.itens) {
    await db.query('INSERT INTO itens_ordem_leitura VALUES ($1,2,$2,$3,$4,$5)', [x.id,x.posicao,x.titulo,x.edicaoId,x.urlCapa]);
  }
  const protegidos = capas.slice(0, 4);
  await db.exec('BEGIN');
  await db.query('UPDATE itens_ordem_leitura SET ordem_leitura_id=999 WHERE id=$1', [protegidos[0].itemId]);
  await db.query("UPDATE itens_ordem_leitura SET titulo_referencia='Outro titulo' WHERE id=$1", [protegidos[1].itemId]);
  await db.query('UPDATE itens_ordem_leitura SET edicao_id=12345 WHERE id=$1', [protegidos[2].itemId]);
  await db.query("UPDATE itens_ordem_leitura SET url_capa_referencia='https://exemplo/capa-preservada.jpg' WHERE id=$1", [protegidos[3].itemId]);
  const resultadoProtecao = await db.exec(sql);
  assert.equal(resultadoProtecao[0].affectedRows, capas.length - 4);
  await db.exec('ROLLBACK');
  const resultado = await db.exec(sql);
  assert.equal(resultado[0].affectedRows, capas.length);
  const repeticao = await db.exec(sql);
  assert.equal(repeticao[0].affectedRows, 0);
  const depois = (await db.query('SELECT * FROM itens_ordem_leitura ORDER BY posicao')).rows;
  assert.equal(depois.length, antes.itens.length);
  for (const a of antes.itens) {
    const d = depois.find(x => Number(x.id) === a.id);
    const nova = capas.find(x => x.itemId === a.id);
    assert.equal(d.posicao, a.posicao);
    assert.equal(d.titulo_referencia, a.titulo);
    assert.equal(d.edicao_id === null ? null : Number(d.edicao_id), a.edicaoId);
    assert.equal(d.url_capa_referencia, nova ? nova.produto.urlCapa : a.urlCapa);
  }
  console.log(`OK PostgreSQL/PGlite: ${capas.length} capas, ${depois.length} posicoes preservadas; repeticao sem alteracoes; protecoes contra outro guia, titulo divergente, edicao vinculada e capa existente.`);
  await db.close();
})().catch(e => { console.error(e); process.exitCode = 1; });
