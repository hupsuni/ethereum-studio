FROM node:12-buster
ARG BUILD

RUN apt update && apt dist-upgrade -y && apt autoremove -y

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./
COPY lerna*.json ./
COPY packages/editor/package*.json ./packages/editor/
COPY packages/web-server/package*.json ./packages/web-server/
COPY packages/editor/templates ./packages/editor/templates
COPY packages/editor/scripts/postinstall.js ./packages/editor/scripts/postinstall.js
COPY packages/editor/scripts/generate-templates.js ./packages/editor/scripts/generate-templates.js
RUN mkdir -p /app/packages/editor/src/assets/static/json
RUN mkdir -p /app/packages/editor/src/assets/static/json/templates

# Bundle app source
COPY . .

RUN npm update --force
RUN npm -g update
RUN npm i --force

# If you are building your code for production
RUN npm audit fix --force
RUN npx lerna bootstrap --hoist

# Install web3
RUN npm install @types/web3 --force
RUN npm install dotenv dotenv-expand fs-extra webpack

# RUN npm install web3 --force
RUN npm run build

EXPOSE 80
EXPOSE 8080
EXPOSE 3000
EXPOSE 4000

CMD [ "npm", "run", "start:prod" ]
