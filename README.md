# Atividade Docker + CI — [SEU NOME]

> Preencha os campos `[...]` restantes e substitua os placeholders de print pelos seus, salvos em `docs/imagens/`.

**Aluno(a):** [nome completo] **Turma:** [turma] **Data:** [data] **Aplicação usada:** docker/getting-started-app — To-Do em Node.js

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

**Por que o multi-stage ajuda?** [Sua resposta em 1–2 frases — dica: pense em por que a imagem final não precisa do `npm` inteiro nem de cache de instalação, só do resultado.]

**Print 1** — `docker build` + `docker images`
`![Build e tamanho da imagem](docs/imagens/01-build-images.png)`

**Print 2** — aplicação rodando com tarefas cadastradas
`![App rodando](docs/imagens/02-app-rodando.png)`

## 3. Volumes e persistência

**Volume usado:** `todo-db` → montado em `/etc/todos` (container avulso, Parte 2) — no Compose, o volume equivalente é `todo-mysql-data` → `/var/lib/mysql`

**Print 3** — SEM volume: dados perdidos ao recriar o container
`![Sem volume](docs/imagens/03-sem-volume.png)`

**Print 4** — COM volume: dados preservados
`![Com volume](docs/imagens/04-com-volume.png)`

**Diferença entre `docker compose down` e `docker compose down -v`:** [Sua resposta em 1 frase]

## 4. Rede

**Rede criada:** `todo-net` **Serviços conectados:** app e mysql/db
**A porta do banco está exposta ao host?** Não — [justifique em 1 frase, ex.: só o app precisa falar com o banco; expor a porta ao host aumentaria a superfície de ataque sem necessidade]

**Por que o app consegue chamar o host `mysql`/`db` sem saber o IP?** [Sua resposta em 1 frase — dica: pense no que vimos na Aula 03 sobre resolução de nomes dentro de uma rede Docker]

**Print 5** — `docker network inspect`
`![Network inspect](docs/imagens/05-network-inspect.png)`

**Print 6** — dados dentro do MySQL (`select * from todo_items;`)
`![Select no MySQL](docs/imagens/06-mysql-select.png)`

## 5. Docker Compose

**Serviços:** app, db **Rede:** `todo-net` · **Volume:** `todo-mysql-data`
**Healthcheck em:** db (`mysqladmin ping`) · **depends_on com:** `condition: service_healthy`
**Variáveis sensíveis:** carregadas via `.env` (não versionado). Modelo em `.env.example`.

**Print 7** — `docker compose ps`
`![Compose ps](docs/imagens/07-compose-ps.png)`

## 6. Integração Contínua (GitHub Actions)

**Arquivo do workflow:** `.github/workflows/ci.yml` **Gatilhos:** push e pull_request
**O que o pipeline faz:**
1. Valida o `compose.yaml` (`docker compose config`)
2. Builda a imagem do serviço `app`
3. Sobe a stack (`docker compose up -d`)
4. Aguarda a app responder e testa criar uma tarefa via API (smoke test do CRUD)
5. Derruba a stack (`docker compose down -v`, sempre, mesmo se algo falhar)

**Print 8** — execução verde ✅
`![CI verde](docs/imagens/08-ci-verde.png)`

## 7. Quebra proposital do CI

**O que eu quebrei:** [descreva a alteração exata que você fez — ex.: trocar `node src/index.js` por `node src/indexx.js` no Dockerfile]
**Erro que apareceu no log:** [cole a mensagem principal]
**Como o CI reagiu:** [em qual step falhou e por quê]
**Como eu corrigi:** [o que foi alterado]

**Link do Pull Request:** [URL]

**Print 9** — execução vermelha ❌ + log do erro
`![CI vermelho](docs/imagens/09-ci-vermelho.png)`

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
- [ ] CI verde (confirmar na aba Actions do GitHub após o push)
- [ ] PR com CI vermelho documentado
- [ ] Todos os 9 prints no README
