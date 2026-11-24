# Versionamento

Regras de versionamento do `openfinance-lab`. Seção futura: produção.

## 1. Código (Git)

### Branch `main`

- Protegida: recebe mudanças **somente via Pull Request**.
- Merge sempre por **squash**: cada PR vira um único commit na `main`.
- Branches da tarefa são apagados automaticamente após o merge.

### Nome dos branches

Formato: `tipo/descricao-curta`, em minúsculas e com hífen.

```
feat/banco-orion
fix/expiracao-consentimento
docs/versionamento
```

### Commits (Conventional Commits)

Formato: `tipo(escopo): descrição`. O escopo é o serviço afetado e é opcional.

| Tipo | Quando usar | Exemplo |
| --- | --- | --- |
| `feat` | Nova funcionalidade | `feat(banco-orion): adiciona endpoint de saldo` |
| `fix` | Correção de bug | `fix(auth-server): corrige expiração do consentimento` |
| `docs` | Somente documentação | `docs: adiciona regras de versionamento` |
| `test` | Somente testes | `test(banco-orion): cobre acesso negado entre clientes` |
| `refactor` | Mudança interna sem alterar comportamento | `refactor(finance-hub): extrai cliente HTTP` |
| `chore` | Configuração, build, dependências | `chore: atualiza Spring Boot para 4.1.2` |

Descrição no imperativo, em português, curta e sem ponto final.

### Pull Requests

- **Um assunto por PR.** Se a descrição precisa de "e também", provavelmente são dois PRs.
- **Título no padrão de commit**: ele vira a mensagem do commit na `main`.
- Antes do merge: build e testes passando, código revisado no próprio diff.

### Fluxo de uma tarefa

```bash
git tarefa feat/nome-da-tarefa   # sincroniza a main, cria e publica o branch
# ... trabalha e faz commits ...
git push                       # envia os commits
# abre o PR no GitHub, revisa e faz o squash merge
git finaliza                   # volta para a main, sincroniza e apaga o branch local
```

### Aliases do projeto

Configure uma vez por máquina:

```bash
git config --global alias.tarefa '!f() { if [ -z "$1" ]; then echo "Uso: git tarefa tipo/nome-da-branch"; return 1; fi; git switch main && git pull --prune && git switch -c "$1" && git push -u origin "$1"; }; f'

git config --global alias.finaliza '!f() { atual=$(git branch --show-current); if [ "$atual" = "main" ]; then echo "Voce ja esta na main. Nada para finalizar."; return 1; fi; git switch main && git pull --prune || return 1; if git ls-remote --exit-code --heads origin "$atual" >/dev/null 2>&1; then echo "A branch $atual ainda existe no GitHub. O PR ja foi mergeado? Nada foi apagado."; return 1; fi; git branch -D "$atual" && echo "Branch $atual apagada. Main atualizada."; }; f'
```

- `git finaliza` só apaga o branch local se ele já sumiu do GitHub, ou seja, se o PR foi mergeado.
- Usa `-D` porque, com squash merge, o Git local não reconhece o branch como mergeado.

### Descrição do PR

Todo PR abre com o template de `.github/pull_request_template.md`: o quê, por quê, como testar e checklist.

## 2. Versão do projeto (SemVer)

Formato `MAIOR.MENOR.CORREÇÃO`:

| Parte | Muda quando | Exemplo |
| --- | --- | --- |
| MAIOR | Há mudança incompatível | `1.0.0` → `2.0.0` |
| MENOR | Entra funcionalidade compatível | `0.1.0` → `0.2.0` |
| CORREÇÃO | Entra só correção | `0.1.0` → `0.1.1` |

- `0.x.y`: projeto em desenvolvimento; qualquer coisa pode mudar.
- `-SNAPSHOT`: versão em construção no `pom.xml` (ex.: `0.1.0-SNAPSHOT`).
- Ao concluir cada fase, a versão é fechada (sem `-SNAPSHOT`) e marcada com uma tag Git `vX.Y.Z`.

| Marco | Versão |
| --- | --- |
| Fase 1 concluída (bancos e consentimento) | `v0.1.0` |
| Fase 2 concluída (agregador e eventos) | `v0.2.0` |
| Fase 3 concluída (IA governada) | `v0.3.0` |
| Fase 4 concluída (deploy) | `v1.0.0` |

## 3. Contrato da API

O contrato é o que quem consome a API enxerga: rotas, campos, tipos, códigos de status e regras de erro.

### Onde fica a versão

A versão maior fica na URL, como no Open Finance Brasil:

```
/open-banking/accounts/v1/accounts
/api/v1/overview
```

### O que NÃO muda a versão (compatível)

- Adicionar um endpoint novo.
- Adicionar um campo novo na resposta.
- Adicionar um parâmetro **opcional** na requisição.
- Adicionar um valor novo num enum de resposta, desde que documentado.

### O que exige nova versão (`v1` → `v2`)

- Remover ou renomear um campo ou endpoint.
- Mudar o tipo de um campo (ex.: texto para número).
- Tornar obrigatório algo que era opcional.
- Mudar o significado de um campo ou o código de status de uma situação.

### Regras de convivência

- **Quem consome ignora campos desconhecidos.** Assim, campos novos nunca quebram ninguém.
- Ao lançar a `v2`, a `v1` continua funcionando por um período de depreciação, sinalizado pelo cabeçalho de resposta `Sunset` com a data de desligamento.
- Toda mudança de contrato entra no mesmo PR que atualiza a documentação da API.


## 4. Banco de dados (Flyway)

O Flyway é o **único** responsável por criar e alterar tabelas. O Hibernate apenas valida se as entidades batem com o banco (`ddl-auto: validate`).

### Onde ficam as migrações

Cada serviço tem as suas, em `src/main/resources/db/migration/`.

### Nome dos arquivos

Formato: `V<versão>__<descrição>.sql`, com **dois** underlines.

| Arquivo | Leitura |
| --- | --- |
| `V1__cria_tabela_customer.sql` | Versão 1, cria a tabela de clientes |
| `V2__cria_tabela_account.sql` | Versão 2, cria a tabela de contas |
| `V3__adiciona_coluna_type_em_account.sql` | Versão 3, altera uma tabela existente |

- Versões inteiras e sequenciais, por serviço: `V1`, `V2`, `V3`.
- Descrição em português, minúsculas, começando por um verbo.

### Regras

- **Migração aplicada nunca é editada.** O Flyway guarda um checksum de cada arquivo; alterar um já aplicado impede a aplicação de subir. Para corrigir, crie uma nova versão.
- **Uma mudança por migração.** Facilita revisar e entender o histórico.
- **Antes de criar, confira a última versão**, inclusive em branches abertas. Duas migrações com o mesmo número geram erro.
- **A migração entra no mesmo PR** que o código que depende dela.

### Convenção de nomes

| Elemento | Padrão | Exemplo |
| --- | --- | --- |
| Tabela | singular, inglês, `snake_case` | `customer`, `account` |
| Coluna | `snake_case` | `created_at` |
| Chave primária | `pk_<tabela>` | `pk_account` |
| Chave estrangeira | `fk_<tabela>_<referência>` | `fk_account_customer` |
| Unicidade | `uk_<tabela>_<coluna>` | `uk_customer_cpf` |
| Índice | `idx_<tabela>_<colunas>` | `idx_account_transaction_account_id` |
| Checagem | `ck_<tabela>_<regra>` | `ck_account_balance_positive` |

- **Toda restrição tem nome explícito.** Nada de nomes gerados automaticamente: são ilegíveis e diferentes em cada banco.
- **Evite palavras reservadas do SQL** como nome de tabela: `user` vira `app_user`, `transaction` vira `account_transaction`.

### Tipos padrão

| Dado | Tipo no PostgreSQL | Tipo no Java |
| --- | --- | --- |
| Identificador | `UUID` | `UUID` |
| Dinheiro | `NUMERIC(19,2)` | `BigDecimal` |
| Data e hora | `TIMESTAMPTZ` (sempre em UTC) | `Instant` |
| Texto curto | `VARCHAR(n)` | `String` |
| Estado (enum) | `VARCHAR(n)` | `enum` com `@Enumerated(EnumType.STRING)` |

### Exemplo

```sql
CREATE TABLE account (
    id          UUID          NOT NULL,
    customer_id UUID          NOT NULL,
    balance     NUMERIC(19,2) NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL,
    CONSTRAINT pk_account PRIMARY KEY (id),
    CONSTRAINT fk_account_customer FOREIGN KEY (customer_id) REFERENCES customer (id)
);
```