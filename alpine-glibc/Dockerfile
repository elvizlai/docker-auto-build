FROM sdrzlyz/alpine

# https://github.com/sgerrand/alpine-pkg-glibc
# Here we install GNU libc (aka glibc) and set en_US.UTF-8 locale as default.
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && ALPINE_GLIBC_PACKAGE_VERSION="2.35-r1" \
    && ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" \
    && wget \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && apk add --no-cache --force-overwrite "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    && apk add --no-cache --force-overwrite "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && apk fix --force-overwrite alpine-baselayout-data \
    && apk del glibc-bin glibc-i18n \
    && rm -rf "/etc/apk/keys/sgerrand.rsa.pub" \
    "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
    /usr/glibc-compat/share/i18n/charmaps/UTF-8 \
    /var/cache/apk/* \
    /tmp/*

# trick to suppress warning for line 19: https://github.com/sgerrand/alpine-pkg-glibc/issues/119
# adding --force-overwrite https://github.com/sgerrand/alpine-pkg-glibc/issues/185