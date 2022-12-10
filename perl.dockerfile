FROM alpine:3.17 as builder

RUN apk add --no-cache build-base curl

ARG ver

RUN curl https://www.cpan.org/src/5.0/perl-$ver.tar.xz | tar xJ

RUN cd perl-$ver                                \
 && ./Configure                                 \
    -Accflags='-DNO_MATHOMS -DPERL_DISABLE_PMC' \
    -des                                        \
    -Darchlib=/usr/lib/perl                     \
    -Dinc_version_list=none                     \
    -Dman1dir=none                              \
    -Dman3dir=none                              \
    -Dprefix=/usr                               \
    -Dprivlib=/usr/lib/perl                     \
    -Dsitearch=/usr/lib/perl                    \
    -Dsitelib=/usr/lib/perl                     \
    -Dusedevel                                  \
    -Dvendorarch=/usr/lib/perl                  \
 && make install -j`nproc`                      \
 && mv /usr/bin/perl$ver /usr/bin/perl          \
 && strip /usr/bin/perl

FROM scratch

# TODO probably need an /etc/passwd?

COPY --from=0 /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=0 /usr/bin/perl            /usr/bin/
COPY --from=0 /usr/lib/perl            /usr/lib/perl

CMD ["perl", "-v"]
