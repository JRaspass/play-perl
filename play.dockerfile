FROM alpine:3.17

RUN apk add --no-cache build-base perl-app-cpanminus perl-dev

COPY cpanfile .

RUN cpanm --cpanfile cpanfile --installdeps --notest .

COPY assets   ./assets
COPY public   ./public
COPY app.psgi .

CMD ["plackup"]
