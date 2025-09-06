FROM node:20-alpine

WORKDIR /usr/src/app

RUN npm install -g peer

EXPOSE 9000

CMD ["peerjs", "--port", "9000", "--path", "/signal-server"]
