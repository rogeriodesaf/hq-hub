-- Amazing Spider-Man (1963), Marvel Comics, corresponde exclusivamente ao volume 2127.
-- Fonte: https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/
-- Artigo e ano fazem parte dos aliases do Guia, não de uma nova coleção.
CREATE TABLE correspondencias_series_externas (
    fonte_externa VARCHAR(100) NOT NULL,
    id_volume VARCHAR(100) NOT NULL,
    titulo_catalogo VARCHAR(255) NOT NULL,
    editora VARCHAR(255) NOT NULL,
    ano_inicio INTEGER NOT NULL,
    url_fonte VARCHAR(1000) NOT NULL,
    PRIMARY KEY (fonte_externa, id_volume, titulo_catalogo, editora, ano_inicio)
);

INSERT INTO correspondencias_series_externas VALUES
    ('COMICVINE', '2127', 'Amazing Spider-Man, The (1963)', 'Marvel Comics', 1963,
     'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/'),
    ('COMICVINE', '2127', 'The Amazing Spider-Man', 'Marvel Comics', 1963,
     'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/'),
    ('COMICVINE', '2127', 'Amazing Spider-Man', 'Marvel Comics', 1963,
     'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/'),
    ('COMICVINE', '2127', 'Amazing Spider-Man (1963)', 'Marvel Comics', 1963,
     'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/'),
    ('COMICVINE', '2127', 'The Amazing Spider-Man (1963)', 'Marvel Comics', 1963,
     'https://comicvine.gamespot.com/the-amazing-spider-man/4050-2127/');
