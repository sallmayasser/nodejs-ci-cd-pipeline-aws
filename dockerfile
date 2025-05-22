FROM node:12

WORKDIR /node

COPY ./node/package*.json ./

RUN npm install 

COPY ./node .

CMD ["node", "index.js"]
