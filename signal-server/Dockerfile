# Signal server Dockerfile
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci --production

COPY . .

FROM node:20-alpine

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app .

RUN npm install -g peer

EXPOSE 9000

USER node

CMD ["peerjs", "--port", "9000", "--path", "/signal-server"]
