## Como rodar

**Pré-requisitos:** Java 25, Git e Docker. O Maven não precisa ser instalado: o projeto usa o Maven Wrapper (`mvnw`).

```bash
git clone https://github.com/vitoralemaorb/openfinance-lab.git
cd openfinance-lab

cp .env.example .env     # cria o arquivo de variáveis (defina uma senha)
docker compose up -d     # sobe o PostgreSQL do banco-orion
docker compose ps        # aguarde o status "healthy"

./mvnw verify                                                # compila e roda os testes
java -jar banco-orion/target/banco-orion-0.1.0-SNAPSHOT.jar  # sobe o banco-orion
```

Com o serviço no ar, `http://localhost:8080/actuator/health` deve responder `{"status":"UP"}`.

Os testes sobem a aplicação inteira e se conectam ao banco, então o container precisa estar `healthy` antes do `verify`.

Para desligar o banco: `docker compose down` (os dados ficam guardados no volume). Para apagar também os dados: `docker compose down -v`.

No Windows, sem Git Bash, use `mvnw.cmd verify`.

## Estrutura

```
openfinance-lab/
├── pom.xml              ← POM pai: Spring Boot, Java e versão do projeto
├── mvnw, .mvn/          ← Maven Wrapper
├── docker-compose.yaml  ← infraestrutura local (PostgreSQL)
├── .env.example         ← modelo das variáveis de ambiente
├── banco-orion/         ← primeiro serviço
├── docs/                ← documentação do projeto
└── .github/             ← template de Pull Request
```

Cada serviço é um módulo Maven que herda do `pom.xml` da raiz, que por sua vez herda do `spring-boot-starter-parent`. As credenciais ficam no `.env`, que nunca vai para o Git.