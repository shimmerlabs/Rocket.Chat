FROM node:12.22.1 AS build

RUN apt-get update && \
    apt-get -y install curl git && \
    curl https://install.meteor.com | sed s/--progress-bar/-sL/g | /bin/sh

COPY . /app

WORKDIR /app

RUN meteor npm install
RUN cd ./ee/server/services && npm install
RUN meteor build --server-only --directory /tmp/build --allow-superuser

FROM node:12.22.1-buster-slim AS prod

WORKDIR /app

COPY --from=build /tmp/build /app

RUN cd /app/bundle/programs/server && npm install

ENV NODE_ENV=production
ENV NOD_VERSION=12.22.1
ENV RC_VERSION=3.14.0

ENV DEPLOY_METHOD=docker-official MONGO_URL=mongodb://db:27017/meteor HOME=/tmp PORT=3000 ROOT_URL=http://localhost:3000 Accounts_AvatarStorePath=/app/uploads

EXPOSE 3000

WORKDIR /app/bundle

CMD ["node", "main.js"]



