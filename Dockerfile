FROM node:8.9-alpine
LABEL Description="This image is used to start the hc-frontend-nuxt" Vendor="Human-Connection gGmbH" Version="1.0" Maintainer="Human-Connection gGmbH (developer@human-connection.org)"

# update unix packages
RUN apk update && apk upgrade
RUN apk add git
RUN rm -rf /var/cache/apk/*

# copy the project
RUN mkdir -p /var/www/
COPY . /var/www/
WORKDIR /var/www/

# expose the app port
EXPOSE 3000

# set environment variables
ENV HOST=0.0.0.0

# buld application
ENV NODE_ENV=production
RUN yarn install --frozen-lockfile
RUN ./node_modules/.bin/nuxt build
RUN ./node_modules/.bin/backpack build

# install env substition
RUN yarn add --global envsub

RUN chmod +x entrypoint.sh
RUN chmod +x on-build.sh
RUN chmod +x on-deploy.sh

RUN on.build.sh

ENTRYPOINT ["./entrypoint.sh"]

# start the application in a autohealing cluster
#CMD NODE_ENV=production ./node_modules/.bin/nuxt build && ./node_modules/.bin/backpack build && pm2 start build/main.js -n frontend -i 2 --attach
#CMD NODE_ENV=production ./node_modules/.bin/nuxt build && ./node_modules/.bin/backpack build && node build/main.js
