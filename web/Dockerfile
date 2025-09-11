FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force
RUN npm install
COPY . .
COPY ../.env .
RUN npm run build
EXPOSE 4321
CMD ["node", "./dist/server/entry.mjs"]
