ALTER TABLE postagens_feed
    ADD COLUMN IF NOT EXISTS canal_parceiro_nome VARCHAR(200),
    ADD COLUMN IF NOT EXISTS canal_parceiro_url VARCHAR(1000),
    ADD COLUMN IF NOT EXISTS canal_parceiro_thumbnail VARCHAR(1000);
