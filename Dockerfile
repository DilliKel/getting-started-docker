# ──────────────────────────────────────────────
# Estágio 1 — builder: instala as dependências
# ──────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copia só os arquivos de dependência primeiro — o npm ci só reroda
# quando package.json/package-lock.json mudam, não a cada mudança no código.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ──────────────────────────────────────────────
# Estágio 2 — final: runtime enxuto, sem ferramentas de build
# ──────────────────────────────────────────────
FROM node:20-alpine

WORKDIR /app

# Copia apenas o node_modules já instalado (do builder) + o código-fonte
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

# O app grava o banco SQLite em /etc/todos por padrão — como container
# roda com usuário não-root, essa pasta precisa existir com dono certo
# antes de trocar de usuário (senão dá EACCES na hora de criar o arquivo).
RUN mkdir -p /etc/todos && chown -R node:node /etc/todos

# Usuário não-root (a imagem node:alpine já vem com o usuário "node" pronto)
USER node

EXPOSE 3000

CMD ["node", "src/index.js"]
