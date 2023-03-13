# --- Build stage---

FROM debian:bullseye-slim AS builder

ARG CGO=0
ENV CGO_ENABLED=${CGO}

# --- Installing tools ---
RUN apt update && apt upgrade -y
RUN apt install -y git wget gcc libc6-dev

# --- Installing Go ---
RUN wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz && rm -rf *.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# --- Hugo compilation ---
RUN git clone https://github.com/gohugoio/hugo.git \
&& cd hugo \
&& go build
# will see if theese flags are needed after if CGO_ENABLED=0 is set. Looks like, those are not needed, compiled binary on Alpine runs.
# -ldflags '-extldflags "-static"'

# --- Production stage ---
FROM alpine:3.14

# Looks like gcompat is not needed
# RUN apk update && \
#    apk add --no-cache gcompat

# --- Copying built Hugo binary from build stage ---
COPY --from=builder /hugo /usr/bin/

# --- Adding non root SYSTEM user ---
RUN adduser -S hugo
USER hugo

# --- Fin. Is ENTRYPOINT command run as HUGO or ROOT user?  ---
ENTRYPOINT [ "hugo" ]
CMD [ "version" ]


