-- V3: cria a tabela de transações das contas do banco-orion.
CREATE TABLE account_transaction
(
    id          UUID           NOT NULL,
    account_id  UUID           NOT NULL,
    type        VARCHAR(10)    NOT NULL,
    amount      NUMERIC(19, 2) NOT NULL,
    category    VARCHAR(30)    NOT NULL,
    description VARCHAR(140)   NOT NULL,
    booked_at   TIMESTAMPTZ    NOT NULL,

    CONSTRAINT pk_account_transaction PRIMARY KEY (id),
    CONSTRAINT fk_account_transaction_account FOREIGN KEY (account_id) REFERENCES account (id),
    CONSTRAINT ck_account_transaction_type CHECK (type IN ('CREDIT', 'DEBIT')),
    CONSTRAINT ck_account_transaction_amount_positive CHECK (amount > 0)
);

CREATE INDEX idx_account_transaction_account_id_booked_at
    ON account_transaction (account_id, booked_at);