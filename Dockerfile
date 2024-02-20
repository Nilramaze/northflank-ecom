ARG NODE_VERSION=16.14.0

# Setup the build container.
FROM node:${NODE_VERSION}-alpine AS build

WORKDIR /home/node

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN yarn install

# Install dependencies.
COPY package*.json .

RUN yarn install

# Copy the source files.
COPY src src
COPY tsconfig.json .
COPY tsconfig.server.json .

# Build the application.
RUN yarn build && yarn cache clean

# Setup the runtime container.
FROM node:${NODE_VERSION}-alpine

WORKDIR /home/node

# Copy the built application.
COPY --from=build /home/node /home/node

# Expose the service's port.
EXPOSE 3000

# Run the service.
CMD ["yarn", "run", "serve"]