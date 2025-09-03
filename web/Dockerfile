# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

RUN npm run build

# Runtime stage
FROM node:22-alpine

WORKDIR /app

RUN adduser -D -h /app corevox

COPY --from=builder /app/dist /app/dist
COPY package*.json ./

RUN npm ci --omit=dev

USER corevox

EXPOSE 80

CMD ["npm", "run", "start"]
