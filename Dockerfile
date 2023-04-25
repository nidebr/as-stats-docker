FROM alpine:3.17 as builder
RUN apk add --no-cache perl perl-app-cpanminus make perl-dev musl-dev gcc && rm -rf /var/cache/apk/*
RUN cpanm File::Find::Rule@0.34 Net::sFlow@0.11 Text::Glob@0.11 Number::Compare@0.03 TryCatch@1.003002
RUN apk add --no-cache perl-doc && rm -rf /var/cache/apk/*
RUN cpanm Net::Patricia@1.22
ADD https://raw.githubusercontent.com/JackSlateur/perl-ip2as/master/ip2as.pm /usr/local/lib/perl5/site_perl/ip2as.pm

FROM alpine:3.17

RUN apk add --no-cache supervisor nginx bash curl perl rrdtool perl-rrd perl-dbi perl-dbd-sqlite git php81-fpm php81-sqlite3 ttf-dejavu tzdata perl-json-xs && rm -rf /var/cache/apk/*

WORKDIR /root/

RUN git clone https://github.com/manuelkasper/AS-Stats.git

RUN rm -Rf /var/www/localhost && \
    mv AS-Stats/www/* /var/www

### NGINX + PHP81-FPM
COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/
ADD nginx/asstats.conf /etc/nginx/sites-available/asstats.conf
RUN ln -s /etc/nginx/sites-available/asstats.conf /etc/nginx/sites-enabled/asstats.conf

EXPOSE 80

VOLUME ["/data/as-stats"]

ADD files/cron.txt /root
RUN cat /root/cron.txt >> /etc/crontabs/root && rm /root/cron.txt

ADD files/stats-day.sh /usr/sbin/stats-day
RUN chmod +x /usr/sbin/stats-day

ADD files/startup.sh /root
ADD files/supervisord.conf /etc/supervisord.conf

COPY --from=builder /usr/local /usr/local

RUN chmod +x /root/startup.sh
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]
