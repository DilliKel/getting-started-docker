# Atividade Docker + CI — Kelvin Araújo Ferreira

> Preencha os placeholders de print restantes, salvos em `docs/imagens/`.

**Aluno(a):** Kelvin Araújo Ferreira **Turma:** Noturno **Data:** 24/07/2026 **Aplicação usada:** docker/getting-started-app — To-Do em Node.js

## 1. Como executar este projeto

```bash
git clone [URL do seu repositório]
cd meu-projeto-docker
cp .env.example .env
docker compose up -d --build
```

Acesse: http://localhost:3000

Para derrubar: `docker compose down` (mantém dados) ou `docker compose down -v` (apaga dados).

## 2. Imagem e Dockerfile multi-stage

**Estágios utilizados:** `builder` (instala as dependências com `npm ci --omit=dev`) e o estágio final (copia apenas `node_modules` + `src`, sem ferramentas de build).
**Imagem base:** `node:20-alpine`
**Usuário de execução:** `node` (não-root, já vem pronto na imagem `node:alpine`)
**Tamanho final da imagem:** ~58MB

**Por que o multi-stage ajuda?** Porque o estágio final só recebe o `node_modules` já pronto e o código-fonte — nada das ferramentas de build, cache do npm ou arquivos temporários do estágio `builder` vai parar na imagem final. Isso deixa a imagem menor (menos superfície de ataque, menos coisa pra escanear em busca de vulnerabilidade) e mais rápida de baixar/subir em produção.

**Print 1** — `docker build` + `docker images`
![Build e tamanho da imagem](docs/imagens/print1.png)

**Print 2** — aplicação rodando com tarefas cadastradas
![App rodando](docs/imagens/print2.png)

## 3. Volumes e persistência

**Volume usado:** `todo-db` → montado em `/etc/todos` (container avulso, Parte 2) — no Compose, o volume equivalente é `todo-mysql-data` → `/var/lib/mysql`

**Print 3** — SEM volume: dados perdidos ao recriar o container
![Sem volume](docs/imagens/print3.png)

**Print 4** — COM volume: dados preservados
![Com volume](docs/imagens/print4.png)

**Diferença entre `docker compose down` e `docker compose down -v`:** `down` para e remove os containers e a rede, mas mantém os volumes nomeados (os dados sobrevivem); `down -v` faz tudo isso **e também apaga os volumes**, perdendo os dados de vez.

## 4. Rede

**Rede criada:** `todo-net` **Serviços conectados:** app e mysql/db
**A porta do banco está exposta ao host?** Não — só o `app` precisa conversar com o banco, e essa comunicação já acontece dentro da rede Docker (`todo-net`); publicar a porta 3306 no host abriria o MySQL pra qualquer coisa rodando na máquina (ou na rede, dependendo do firewall), sem necessidade nenhuma.

**Por que o app consegue chamar o host `mysql`/`db` sem saber o IP?** Porque containers na mesma rede Docker (definida pelo usuário, seja via `docker network create` ou automaticamente pelo Compose) resolvem uns aos outros pelo nome — o Docker mantém um DNS interno que traduz o nome do serviço/container pro IP real, então o app só precisa saber o nome (`mysql` ou `db`), nunca o IP.

**Print 5** — `docker network inspect` (em duas partes, para caber tudo)
![Network inspect - parte 1](docs/imagens/print5-1.png)
![Network inspect - parte 2](docs/imagens/print5-2.png)

**Print 6** — dados dentro do MySQL (`select * from todo_items;`)
![Select no MySQL](docs/imagens/print6.png)

## 5. Docker Compose

**Serviços:** app, db **Rede:** `todo-net` · **Volume:** `todo-mysql-data`
**Healthcheck em:** db (`mysqladmin ping`) · **depends_on com:** `condition: service_healthy`
**Variáveis sensíveis:** carregadas via `.env` (não versionado). Modelo em `.env.example`.

**Print 7** — `docker compose ps`
![Compose ps](docs/imagens/print7.png)

## 6. Integração Contínua (GitHub Actions)

**Arquivo do workflow:** `.github/workflows/ci.yml` **Gatilhos:** push e pull_request
**O que o pipeline faz:**
1. Valida o `compose.yaml` (`docker compose config`)
2. Builda a imagem do serviço `app`
3. Sobe a stack (`docker compose up -d`)
4. Aguarda a app responder e testa criar uma tarefa via API (smoke test do CRUD)
5. Derruba a stack (`docker compose down -v`, sempre, mesmo se algo falhar)

**Print 8** — execução verde ✅
![CI verde](docs/imagens/print8.png)

## 7. Quebra proposital do CI

**O que eu quebrei:** troquei `CMD ["node", "src/index.js"]` por `CMD ["node", "src/indexx.js"]` no `Dockerfile` (arquivo que não existe).
**Erro que apareceu no log:** `Error: Cannot find module '/app/src/indexx.js'`
**Como o CI reagiu:** o job passou pelo build normalmente (o Docker não valida se o arquivo do `CMD` existe na hora de buildar), mas falhou no step **"Aguardar a aplicação responder"** — o container do `app` subia e morria na hora (`MODULE_NOT_FOUND`), então o `curl` nunca conseguia conectar em `http://localhost:3000/items`, e depois das 30 tentativas o step retornava `exit 1`.
**Como eu corrigi:** voltei o `CMD` para o caminho certo (`src/index.js`), na mesma branch `quebra-proposital`, com um segundo commit.

**Link do Pull Request:** https://github.com/DilliKel/getting-started-docker/pull/1

**Print 9** — execução vermelha ❌ + log do erro
![CI vermelho](docs/imagens/print9.png)

## 8. Dificuldades e aprendizados

[3 a 5 linhas: o que travou, como resolveu, o que ficou mais claro sobre containers depois da atividade]

## 9. Checklist de autoavaliação

- [x] Dockerfile multi-stage funcionando
- [x] `.dockerignore` presente
- [x] Container não roda como root
- [x] Volume nomeado + persistência demonstrada
- [x] Rede nomeada + banco não exposto ao host
- [x] `compose.yaml` sobe tudo com um comando
- [x] `.env` no `.gitignore` e `.env.example` versionado
- [x] CI verde
- [x] PR com CI vermelho documentado ([#1](https://github.com/DilliKel/getting-started-docker/pull/1), merged)
- [x] Todos os 9 prints no README
