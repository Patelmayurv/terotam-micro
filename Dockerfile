################################# CM #########################################

# === Build stage ===
FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final runtime stage ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
USER appuser
EXPOSE 3004
#CMD ["npx", "pm2-runtime", "dist/index.js", "--name", "complain-service"]
CMD ["node", "dist/index.js"]

########################### puppter #########################################


FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Install minimal runtime dependencies for Puppeteer + PM2
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    jemalloc \
    &&  rm -rf /tmp/* /var/cache/apk/*

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
USER appuser
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_HEADLESS=new \
    PUPPETEER_DISABLE_SANDBOX=false
EXPOSE 3006
#CMD ["pm2-runtime", "dist/index.js", "--name", "puppeteer-service"]
CMD ["node", "dist/index.js"]

#################################### PM ##############################


FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3002
#CMD ["pm2-runtime", "dist/index.js", "--name", "pm-service"]
CMD ["node", "dist/index.js"]

############################### GM ####################################


FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3003
#CMD ["pm2-runtime", "dist/index.js", "--name", "gm-service"]
CMD ["node", "dist/index.js"]


########################### Asset #############################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3005
#CMD ["pm2-runtime", "dist/index.js", "--name", "asset-service"]
CMD ["node", "dist/index.js"]

################################## bulk ##################


FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates

USER appuser
EXPOSE 3008
#CMD ["pm2-runtime", "dist/index.js", "--name", "bulk-service"]
CMD ["node", "dist/index.js"]

######################### dashbaord ######################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist


USER appuser
EXPOSE 3014
#CMD ["pm2-runtime", "dist/index.js", "--name", "dashbaord-service"]
CMD ["node", "dist/index.js"]

########################### sca ############################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox 

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3007
#CMD ["pm2-runtime", "dist/index.js", "--name", "sca-service"]
CMD ["node", "dist/index.js"]


############################ master ##########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlfiles ./htmlfiles
COPY --chown=appuser:appgroup --from=build /app/htmlfiles ./htmlfiles
COPY --chown=appuser:appgroup --from=build /app/nodemon.json ./nodemon.json

USER appuser
EXPOSE 3012
#CMD ["pm2-runtime", "dist/index.js", "--name", "master-service"]
CMD ["node", "dist/index.js"]

################################ qr code ###########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox
# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json
USER appuser
EXPOSE 3018
#CMD ["pm2-runtime", "dist/index.js", "--name", "publicqr-service"]
CMD ["node", "dist/index.js"]


################### cron #####################################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3001
#CMD ["pm2-runtime", "dist/index.js", "--name", "cron-service"]
CMD ["node", "dist/index.js"]


######################### invoice ################################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json

USER appuser
EXPOSE 3001
#CMD ["pm2-runtime", "dist/index.js", "--name", "invoice-service"]
CMD ["node", "dist/index.js"]


########################### middleware #########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json

USER appuser
EXPOSE 3011
#CMD ["pm2-runtime", "dist/index.js", "--name", "middleware-service"]
CMD ["node", "dist/index.js"]


################### store #########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
USER appuser
EXPOSE 3010
#CMD ["pm2-runtime", "dist/index.js", "--name", "store-service"]
CMD ["node", "dist/index.js"]


################# utlity ########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json

USER appuser
EXPOSE 3016
#CMD ["pm2-runtime", "dist/index.js", "--name", "utility-service"]
CMD ["node", "dist/index.js"]


########################## cronread ##########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json


USER appuser
EXPOSE 3013
#CMD ["pm2-runtime", "dist/index.js", "--name", "cronread-service"]
CMD ["node", "dist/index.js"]


################### main #########################

FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json
COPY --chown=appuser:appgroup --from=build /app/terotam_firebase_adminsdk.json ./terotam_firebase_adminsdk.json
COPY --chown=appuser:appgroup --from=build /app/addNewDeptsVendotr.js ./addNewDeptsVendotr.js
COPY --chown=appuser:appgroup --from=build /app/gulpfile.js ./gulpfile.js
USER appuser
EXPOSE 3000
#CMD ["pm2-runtime", "dist/index.js", "--name", "main-service"]
CMD ["node", "dist/index.js"]


####################### puppter ###################

FROM node:22-alpine AS build
WORKDIR /app
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Install minimal runtime dependencies for Puppeteer + PM2
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    jemalloc \
    && rm -rf /var/cache/apk/*

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox
# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
USER appuser

# Expose port
EXPOSE 3006
# Environment variables
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_HEADLESS=new \
    PUPPETEER_DISABLE_SANDBOX=false

# Run with pm2-runtime
#CMD ["pm2-runtime", "dist/index.js", "--name", "puppeteer-service"]
CMD ["node", "dist/index.js"]


################################# Device #####################


FROM node:22-alpine AS build
WORKDIR /app

# Install dependencies (production only)
RUN apk add --no-cache --virtual .build-deps python3 make g++ libc6-compat cairo-dev jpeg-dev pango-dev giflib-dev
COPY package*.json ./
RUN npm ci --legacy-peer-deps 
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build
RUN npm prune --omit=dev --legacy-peer-deps \
    && apk del .build-deps \
    && npm cache clean --force \
    && rm -rf src/*.ts tests docs *.md \
    && rm -rf /tmp/* /var/cache/apk/*

# === Final lightweight runtime ===
FROM node:22-alpine
WORKDIR /app

# Create non-root user/group, app dir, and install PM2 in one layer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    mkdir -p /var/www/terotam-sandbox && \
    chown -R appuser:appgroup /var/www/terotam-sandbox

# Copy production deps + built app with correct ownership
COPY --chown=appuser:appgroup --from=build /app/package*.json ./
COPY --chown=appuser:appgroup --from=build /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=build /app/dist ./dist
COPY --chown=appuser:appgroup --from=build /app/htmlTemplates ./htmlTemplates
COPY --chown=appuser:appgroup --from=build /app/certs ./certs
COPY --chown=appuser:appgroup --from=build /app/gulpfile.js ./gulpfile.js
COPY --chown=appuser:appgroup --from=build /app/tsconfig.json ./tsconfig.json
USER appuser
EXPOSE 3017
#CMD ["pm2-runtime", "dist/index.js", "--name", "main-service"]
CMD ["node", "dist/index.js"]
