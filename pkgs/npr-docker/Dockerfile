FROM docker.io/nixos/nix:latest

RUN mkdir -p /npr-work/

RUN nix-env -iA nixpkgs.nixpkgs-review

COPY entrypoint.sh /entrypoint.sh

WORKDIR /npr-work/

ENV GITHUB_USER="null@null.null"
ENV GITHUB_EMAIL="null"
ENV NPR_FLAGS="rev --print-result HEAD"

ENTRYPOINT /entrypoint.sh

