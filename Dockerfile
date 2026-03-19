# Stage 1: Minify JS, CSS, and HTML
FROM node:alpine AS build

RUN npm install -g terser html-minifier-terser

WORKDIR /src
COPY . .

# Minify JS files (skip webfontplayer.min.js - already minified)
RUN terser accelonome.js -o accelonome.js --compress --mangle && \
    terser sounds.js -o sounds.js --compress --mangle && \
    terser worker.js -o worker.js --compress --mangle

# Minify HTML (also minifies inline CSS and JS)
RUN html-minifier-terser index.html \
    --collapse-whitespace \
    --remove-comments \
    --minify-css true \
    --minify-js true \
    -o index.html

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=build /src/index.html /usr/share/nginx/html/
COPY --from=build /src/accelonome.js /usr/share/nginx/html/
COPY --from=build /src/sounds.js /usr/share/nginx/html/
COPY --from=build /src/worker.js /usr/share/nginx/html/
COPY --from=build /src/webfontplayer.min.js /usr/share/nginx/html/
COPY --from=build /src/favicon.ico /usr/share/nginx/html/
COPY --from=build /src/header_icon.png /usr/share/nginx/html/
COPY --from=build /src/header.png /usr/share/nginx/html/
COPY --from=build /src/assets/ /usr/share/nginx/html/assets/

EXPOSE 80
