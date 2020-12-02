FROM node:10

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
RUN npm install -g contentful-cli
COPY package.json /usr/src/app/
RUN npm install

# Copy files
COPY . .

# Building app
#RUN npm run build

EXPOSE 3000
CMD [ "npm","run", "start" ]
