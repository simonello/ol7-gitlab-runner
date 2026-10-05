IMAGE_VERSION = 1.3
PUBLISHER = simonello
OS = linux
ARCH = amd64
URL = https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries
PROJECT = ol7-gitlab-runner

all: download build tag

.SILENT:
download:
	if [ ! -f bin/gitlab-runner-${OS}-${ARCH} ]; then \
		cd bin && curl -fLJO ${URL}/gitlab-runner-${OS}-${ARCH} && \
		chmod +x gitlab-runner-${OS}-${ARCH} && ./check || \
		{ echo "download or checksum failed - removing binary"; \
		rm -f gitlab-runner-${OS}-${ARCH}; exit 1; }; \
	else \
		echo "gitlab-runner-${OS}-${ARCH} already downloaded"; \
	fi;

clean:
	-docker image rm -f $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) \
	$(PUBLISHER)/$(PROJECT):latest

build :
	docker build --no-cache -t $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) --ulimit nofile=1024000:1024000  .

tag:
	docker image tag $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) $(PUBLISHER)/$(PROJECT):latest

push:
	docker push $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION)
	docker push $(PUBLISHER)/$(PROJECT):latest
