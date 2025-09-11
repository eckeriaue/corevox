FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force
RUN npm install
COPY . .
EXPOSE 4321
CMD ["sh", "-c", "npm run build && node ./dist/server/entry.mjs"]
