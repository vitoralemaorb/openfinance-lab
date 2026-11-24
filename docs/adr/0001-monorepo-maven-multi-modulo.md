# ADR-0001: Monorepo com Maven multi-módulo

- **Status:** Aceito
- **Data:** 2026-11-24

## Contexto

O openfinance-lab terá seis serviços: banco-orion, banco-vega,
auth-server, finance-hub, ai-gateway e finance-assistant.

Precisávamos decidir como organizar esse código. Os pontos que pesaram:

- O projeto é desenvolvido por uma pessoa só.
- Todos os serviços usam as mesmas versões de Java, Spring Boot e plugins.
- Mudanças de contrato entre serviços (ex.: o finance-hub consumindo
  a API do banco-orion) precisam ser feitas e revisadas juntas.
- É um portfólio: quem visitar o repositório deve enxergar a
  arquitetura inteira em um só lugar.

## Opções consideradas

1. **Um repositório por serviço (polyrepo):** cada serviço com seu
   próprio repositório, build e versão.
2. **Monorepo com Maven multi-módulo:** um repositório, um pom pai,
   e cada serviço como um módulo independente.
3. **Monólito:** uma única aplicação com todas as funcionalidades.

## Decisão

Usar a **opção 2: monorepo com Maven multi-módulo.**

O pom raiz herda do `spring-boot-starter-parent` e centraliza as versões (Java, Spring Boot, JaCoCo). Cada serviço é um
módulo com seu próprio
pom, gera seu próprio `.jar` e roda em um processo separado.

Monorepo não é monólito: os serviços continuam independentes.
Cada um tem seu banco de dados e eles se comunicam apenas por HTTP.

## Consequências

**Positivas**

- Um `git clone` e um `./mvnw verify` constroem e testam tudo.
- As versões são definidas uma vez, no pom raiz.
- Uma mudança que atravessa serviços cabe em um único PR.
- O README mostra a arquitetura completa em um só lugar.

**Negativas e como lidamos com elas**

- **Acoplamento acidental:** seria fácil um módulo importar classes de
  outro. Regra: um serviço nunca depende do código de outro serviço.
- **Build cada vez maior:** o CI vai compilar tudo em cada PR.
  Quando isso pesar, dá para construir só o módulo alterado (`-pl`).
- **Versão única:** todos os serviços compartilham a versão do projeto (hoje 0.1.0-SNAPSHOT), mesmo sem terem mudado.