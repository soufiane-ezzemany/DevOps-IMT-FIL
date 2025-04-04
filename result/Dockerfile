FROM node:18-slim
WORKDIR /usr/local/app
COPY package.json package-lock.json ./
RUN npm install -g nodemon 
RUN npm ci && npm cache clean --force
RUN mv /usr/local/app/node_modules /node_modules
ENV PORT=3001
EXPOSE $PORT
COPY . .
CMD ["nodemon", "server.js"]