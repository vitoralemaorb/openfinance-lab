CREATE TABLE account (
    id          UUID            NOT NULL,
    customer_id UUID            NOT NULL,
    branch      VARCHAR(4)      NOT NULL,
    number      VARCHAR(20)     NOT NULL,
    type        VARCHAR(20)     NOT NULL,
    balance     NUMERIC(19, 2)  NOT NULL,
    currency    VARCHAR(3)      NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL,

    CONSTRAINT pk_account PRIMARY KEY (id),
    CONSTRAINT fk_account_customer FOREIGN KEY (customer_id) REFERENCES customer (id),
    CONSTRAINT uk_account_branch_number UNIQUE (branch, number),
    CONSTRAINT ck_account_type CHECK (type IN ('CHECKING', 'SAVINGS')),
    CONSTRAINT ck_account_balance_non_negative CHECK (balance >= 0)
);

CREATE INDEX idx_account_customer_id ON account (customer_id);