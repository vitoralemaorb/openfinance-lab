CREATE TABLE customer (
    id          UUID         NOT NULL,
    cpf         VARCHAR(11)  NOT NULL,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(254) NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL,

    CONSTRAINT pk_customer PRIMARY KEY (id),
    CONSTRAINT uk_customer_cpf UNIQUE (cpf),
    CONSTRAINT ck_customer_cpf_digits CHECK ( cpf ~ '^[0-9]{11}$' )
);