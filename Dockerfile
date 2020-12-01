FROM node

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
RUN npm install -g contentful-cli
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . .

EXPOSE 3000
CMD [ "npm","run", "start" ]
