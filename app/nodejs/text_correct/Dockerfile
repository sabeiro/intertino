FROM node:18

COPY .. /app
WORKDIR /app


RUN npm install

# Bundle app source

EXPOSE 3000

CMD [ "./build/entrypoint.sh" ]
