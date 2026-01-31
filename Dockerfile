# ---------- BUILD STAGE ----------
FROM node:16.17.0-alpine as builder

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

RUN yarn build


# ---------- RUNTIME STAGE ----------
FROM nginx:stable-alpine

# Remove default nginx config (this image DOES have nginx)
RUN rm /etc/nginx/conf.d/default.conf

# Copy SPA nginx config
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy build output
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
