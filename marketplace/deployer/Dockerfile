FROM golang:1.26.6-bookworm@sha256:116d58cbd88c1297624acc6e967a060012422bacf9930927e23fb719189c6f36 AS kubectl-builder

RUN git clone --branch v1.36.3 --depth 1 https://github.com/kubernetes/kubernetes.git /src/kubernetes \
    && cd /src/kubernetes \
    && make WHAT=cmd/kubectl \
    && install -D -m 0755 _output/bin/kubectl /out/kubectl

FROM golang:1.26.6-bookworm@sha256:116d58cbd88c1297624acc6e967a060012422bacf9930927e23fb719189c6f36 AS helm-builder

RUN git clone --branch v4.2.4 --depth 1 https://github.com/helm/helm.git /src/helm \
    && cd /src/helm \
    && go get oras.land/oras-go/v2@v2.6.2 \
    && make build \
    && install -D -m 0755 bin/helm /out/helm

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm/onbuild@sha256:6a6d705987be9dacb976540b02901250bf09324c2fdc641f64c014da696bd198

# The pinned Google deployer base currently ships kubectl and Helm binaries
# compiled with Go 1.26.5. Rebuild the same tool versions with Go 1.26.6 to
# incorporate the available standard-library security fixes.
COPY --from=kubectl-builder /out/kubectl /opt/kubectl/v1.36/kubectl
COPY --from=helm-builder /out/helm /usr/local/bin/helm

LABEL org.opencontainers.image.title="Auritas Storage Manager (ASM+) Marketplace deployer" \
      org.opencontainers.image.vendor="Auritas LLC" \
      org.opencontainers.image.version="1.0.0" \
      com.googleapis.cloudmarketplace.product.service.name="services/asm-plus.endpoints.auritas-asmplus-public.cloud.goog"
