# ---------- Stage 1: Build React ----------
FROM node:20-alpine AS client-build
WORKDIR /app/client

COPY client/package*.json ./
RUN npm install

COPY client/ ./
RUN npm run build


# ---------- Stage 2: Build Server ----------
FROM node:20-alpine
WORKDIR /app

# install server deps
COPY server/package*.json ./
RUN npm install --production

# copy server code
COPY server/ ./

# copy React build ไป serve
COPY --from=client-build /app/client/build ./client/build

# env
ENV PORT=7000

EXPOSE 7000

CMD ["node", "server.js"]