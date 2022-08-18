FROM node:14

ARG VERSION=4.3.4

ENV NODE_ENV=production

RUN apt-get update && apt-get install libvips-dev -y && \
    yarn create strapi-app /opt/app --quickstart --no-run --ts && \
    cd /opt/app && \
    yarn install && yarn build

WORKDIR /opt/app

EXPOSE 1337

CMD ["yarn", "start"]
