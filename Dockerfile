# use an official Node.js runtime as the base image.  
 FROM node:alpine AS builder

# set working directory to app  
WORKDIR /app

# Copy the package.json file to the container  
COPY package*.json ./

#  Install the application dependencies in the container  
RUN npm install -frozen-lockfile

# Copy the remaining application files to the container  
COPY . .

#debugging 
RUN ls -la /app
RUN npm ci

# build app 
RUN npm run build

# Setting the environment variable to production  
ENV NODE_ENV=production

# Create a temporary image to copy only the .env file
FROM node:alpine AS envCopy
WORKDIR /app
COPY --from=builder /app/.env ./.env

# Running stage  
FROM node:alpine

# Setting the environment variables to the production 
ENV NODE_ENV=production

# Setting the working directory to /app. 
WORKDIR /app

# For better security, set a user to node. 
RUN chown -R node:node /app
USER node

# Copy the package.json and package-lock.json files to the container.
COPY package*.json ./

# Copying the built Next.js application from the build stage to the runtime stage.
COPY --from=builder /app/node_modules/ ./node_modules/

# Copying the .env file, public folder, and node_modules directory to the container. 
COPY --from=builder /app .
RUN if [ -e "/app/.env" ]; then cp /app/.env /app/.env; fi

# Exposing Port 3000 to allow public access 
EXPOSE 3000

# Specifying the command to run when the container starts 
CMD ["npm", "start"]