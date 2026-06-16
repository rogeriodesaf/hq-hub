ALTER TABLE editoras
    ADD COLUMN fonte_externa VARCHAR(100),
    ADD COLUMN id_externo VARCHAR(255),
    ADD COLUMN url_origem VARCHAR(1000);

ALTER TABLE series
    ADD COLUMN fonte_externa VARCHAR(100),
    ADD COLUMN id_externo VARCHAR(255),
    ADD COLUMN url_origem VARCHAR(1000);

ALTER TABLE edicoes
    ADD COLUMN fonte_externa VARCHAR(100),
    ADD COLUMN id_externo VARCHAR(255),
    ADD COLUMN url_origem VARCHAR(1000);

CREATE UNIQUE INDEX uk_editoras_origem_externa
    ON editoras (fonte_externa, id_externo)
    WHERE fonte_externa IS NOT NULL AND id_externo IS NOT NULL;

CREATE UNIQUE INDEX uk_series_origem_externa
    ON series (fonte_externa, id_externo)
    WHERE fonte_externa IS NOT NULL AND id_externo IS NOT NULL;

CREATE UNIQUE INDEX uk_edicoes_origem_externa
    ON edicoes (fonte_externa, id_externo)
    WHERE fonte_externa IS NOT NULL AND id_externo IS NOT NULL;
