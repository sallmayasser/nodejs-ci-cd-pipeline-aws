FROM node:12

COPY ./node /node

WORKDIR /node
RUN npm install
CMD ["node", "/node/index.js"]