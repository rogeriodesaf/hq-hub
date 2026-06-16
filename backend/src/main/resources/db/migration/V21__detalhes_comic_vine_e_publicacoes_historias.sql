alter table edicoes
    add column nome_volume varchar(255),
    add column data_cobertura date,
    add column data_disponibilidade_loja date,
    add column descricao_original varchar(4000),
    add column descricao_portugues varchar(4000),
    add column url_comic_vine varchar(1000),
    add column id_comic_vine varchar(100);

alter table historias
    add column titulo_portugues varchar(255),
    add column descricao_original varchar(4000),
    add column descricao_portugues varchar(4000);

alter table publicacoes_historias
    add column tipo_publicacao_historia varchar(50) not null default 'REPUBLICACAO',
    add column fonte_informacao varchar(255),
    add column url_fonte_informacao varchar(1000),
    add column usuario_criador_id bigint,
    add column status_validacao varchar(50) not null default 'PENDENTE',
    add constraint fk_publicacoes_historias_usuario_criador foreign key (usuario_criador_id) references usuarios(id);

create index idx_edicoes_id_comic_vine on edicoes(id_comic_vine);
create index idx_publicacoes_historias_validacao on publicacoes_historias(status_validacao);
