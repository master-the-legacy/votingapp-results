FROM node:18-slim

# Tini as an alternative to tradicional linux process manager "init". https://github.com/krallin/tini
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# have nodemon available for local dev use (file watching). automatically restart the node application when file changes in the directory are detected
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci \
 && npm cache clean --force \
 && mv /app/node_modules /node_modules

# copy local files to /app, cuz the WORKDIR is /app
COPY . .

# Sets the environment variable PORT to 80. This specifies the port on which the Node.js application will listen
ENV PORT 80

# This does not publish the port, but serves as metadata for the person running the container.
EXPOSE 80

# The double dash (--) is a convention used in command-line interfaces to indicate the end of options and the beginning of positional arguments. In this case, it ensures that any subsequent arguments provided in the CMD instruction will be treated as arguments for the command executed by Tini.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
