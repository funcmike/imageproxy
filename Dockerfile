# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM golang:1.19 as build
LABEL maintainer="Krzysztof Majk <funcmike@atamari.pl>"

# Install webp dev libs.
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y libwebp-dev

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

ARG TARGETOS
ARG TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go install -v ./cmd/imageproxy

FROM debian:bullseye-slim

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y libwebp6 ca-certificates

COPY --from=build /go/bin/imageproxy /app/imageproxy

CMD ["-addr", "0.0.0.0:8080"]
ENTRYPOINT ["/app/imageproxy"]

EXPOSE 8080
