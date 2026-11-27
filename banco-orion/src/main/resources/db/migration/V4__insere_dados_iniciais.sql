-- V4: insere os dados iniciais do banco-orion (clientes, contas e transações fictícias).
INSERT INTO customer (id, cpf, name, email, created_at)
VALUES ('10000000-0000-0000-0000-000000000001', '52998224725', 'Ana Souza', 'ana.souza@email.com',
        '2026-08-01 09:00:00-03'),
       ('10000000-0000-0000-0000-000000000002', '39053344705', 'Bruno Lima', 'bruno.lima@email.com',
        '2026-08-03 14:30:00-03'),
       ('10000000-0000-0000-0000-000000000003', '11144477735', 'Carla Mendes', 'carla.mendes@email.com',
        '2026-08-05 11:15:00-03');

INSERT INTO account (id, customer_id, branch, number, type, balance, currency, created_at)
VALUES ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '0001', '10001-1', 'CHECKING',
        0, 'BRL', '2026-08-01 09:10:00-03'),
       ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '0001', '10001-2', 'SAVINGS', 0,
        'BRL', '2026-08-01 09:15:00-03'),
       ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', '0001', '10002-1', 'CHECKING',
        0, 'BRL', '2026-08-03 14:40:00-03'),
       ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000002', '0001', '10002-2', 'SAVINGS', 0,
        'BRL', '2026-08-03 14:45:00-03'),
       ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000003', '0001', '10003-1', 'CHECKING',
        0, 'BRL', '2026-08-05 11:20:00-03');

-- Salários: um por mês, em cada conta corrente.
INSERT INTO account_transaction (id, account_id, type, amount, category, description, booked_at)
SELECT gen_random_uuid(), s.account_id, 'CREDIT', s.amount, 'SALARY', 'Salário', m.month + INTERVAL '4 days 8 hours'
FROM (VALUES ('20000000-0000-0000-0000-000000000001'::uuid, 5200.00),
             ('20000000-0000-0000-0000-000000000003'::uuid, 4300.00),
             ('20000000-0000-0000-0000-000000000005'::uuid, 3900.00)) AS s (account_id, amount)
         CROSS JOIN (VALUES (TIMESTAMPTZ '2026-09-01 00:00:00-03'),
                            (TIMESTAMPTZ '2026-10-01 00:00:00-03'),
                            (TIMESTAMPTZ '2026-11-01 00:00:00-03')) AS m (month);


-- Transferências mensais para a poupança: a saída da corrente...
INSERT INTO account_transaction (id, account_id, type, amount, category, description, booked_at)
SELECT gen_random_uuid(), p.checking_id, 'DEBIT', p.amount, 'TRANSFER', 'Transferência para a poupança', m.month + INTERVAL '5 days 10 hours'
FROM (VALUES
          ('20000000-0000-0000-0000-000000000001'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, 500.00),
          ('20000000-0000-0000-0000-000000000003'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, 300.00)
     ) AS p (checking_id, savings_id, amount)
         CROSS JOIN (VALUES
                         (TIMESTAMPTZ '2026-09-01 00:00:00-03'),
                         (TIMESTAMPTZ '2026-10-01 00:00:00-03'),
                         (TIMESTAMPTZ '2026-11-01 00:00:00-03')
) AS m (month);

-- ...e a entrada correspondente na poupança.
INSERT INTO account_transaction (id, account_id, type, amount, category, description, booked_at)
SELECT gen_random_uuid(), p.savings_id, 'CREDIT', p.amount, 'TRANSFER', 'Transferência da conta corrente', m.month + INTERVAL '5 days 10 hours'
FROM (VALUES
          ('20000000-0000-0000-0000-000000000001'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, 500.00),
          ('20000000-0000-0000-0000-000000000003'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, 300.00)
     ) AS p (checking_id, savings_id, amount)
         CROSS JOIN (VALUES
                         (TIMESTAMPTZ '2026-09-01 00:00:00-03'),
                         (TIMESTAMPTZ '2026-10-01 00:00:00-03'),
                         (TIMESTAMPTZ '2026-11-01 00:00:00-03')
) AS m (month);


-- Despesas do dia a dia: 55 por conta corrente, entre 01/09 e 26/11.
-- O setseed fixa a "semente" do random(): os valores parecem aleatórios,
-- mas são sempre os mesmos em qualquer ambiente.
SELECT setseed(0.42);

INSERT INTO account_transaction (id, account_id, type, amount, category, description, booked_at)
SELECT gen_random_uuid(),
       a.id,
       'DEBIT',
       round((e.min_amount + random() * (e.max_amount - e.min_amount))::numeric, 2),
       e.category,
       e.description,
       TIMESTAMPTZ '2026-09-01 08:00:00-03' + random() * INTERVAL '86 days'
FROM account a
         CROSS JOIN generate_series(1, 55) AS g (n)
         CROSS JOIN LATERAL (
    SELECT *
    FROM (VALUES
              ('GROCERIES',   'Compra no Supermercado Bom Preço', 40, 350),
              ('RESTAURANTS', 'Restaurante Sabor da Casa',        25, 120),
              ('TRANSPORT',   'Corrida de aplicativo',            12,  45),
              ('HEALTH',      'Farmácia Saúde Já',                15, 180),
              ('LEISURE',     'Cinema Estrela',                   20,  90),
              ('BILLS',       'Conta de energia',                120, 260)
         ) AS opcoes (category, description, min_amount, max_amount)
    WHERE g.n > 0
    ORDER BY random()
    LIMIT 1
    ) AS e
WHERE a.type = 'CHECKING';

-- 6. Saldo: créditos menos débitos de cada conta, para o saldo sempre bater com o extrato.
UPDATE account a
SET balance = (
    SELECT COALESCE(SUM(CASE WHEN t.type = 'CREDIT' THEN t.amount ELSE -t.amount END), 0)
    FROM account_transaction t
    WHERE t.account_id = a.id
);

