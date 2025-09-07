
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production

COPY . .

RUN npm run build

FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 4321

USER node

CMD ["npm", "run", "start"]
