# FROM node:18
FROM mhart/alpine-node

# Create app directory
WORKDIR /app

# Install app dependencies
COPY . .

RUN npm install

# Bundle app source

EXPOSE 3000

CMD [ "npm","start" ]
