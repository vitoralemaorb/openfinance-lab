# Versionamento

Regras de versionamento do `openfinance-lab`. Seções futuras: banco de dados (Flyway) e produção.

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
git switch main && git pull              # parte da main atualizada
git switch -c feat/nome-da-tarefa        # cria o branch da tarefa
# ... trabalha e faz commits ...
git push -u origin feat/nome-da-tarefa   # envia o branch
# abre o PR no GitHub, revisa e faz o squash merge
git switch main && git pull              # traz o resultado do merge
```

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
