# Build stage
FROM alpine:3.13 as builder
WORKDIR /tmp/download
RUN wget https://github.com/AdguardTeam/AdGuardHome/releases/latest//download/AdGuardHome_linux_amd64.tar.gz && \
    tar -zxvf AdGuardHome_linux_amd64.tar.gz
    
# EXEC stage
FROM alpine:3.13

RUN apk --no-cache --update add ca-certificates libcap tzdata && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /opt/adguardhome/conf /opt/adguardhome/work && \
    chown -R nobody: /opt/adguardhome

COPY --from=builder /tmp/download/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

RUN setcap 'cap_net_bind_service=+eip' /opt/adguardhome/AdGuardHome

EXPOSE 53/tcp 53/udp 80/tcp 3000/tcp

WORKDIR /opt/adguardhome/work

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]

CMD [ \
	"--no-check-update", \
	"-c", "/opt/adguardhome/conf/AdGuardHome.yaml", \
	"-h", "0.0.0.0", \
	"-w", "/opt/adguardhome/work" \
]