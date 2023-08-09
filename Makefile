IMAGE_VERSION = 1.2
PUBLISHER = simonello
OS = linux
ARCH = amd64
URL = "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries"
PROJECT = ol7-gitlab-runner

all: download build tag

clean: clean_image clean_images

.SILENT:
download:
	if [ ! -f bin/gitlab-runner-${OS}-${ARCH} ]; then cd bin && curl -LJO "${URL}/gitlab-runner-${OS}-${ARCH}"; else echo "gitlab-runner-${OS}-${ARCH} already downloaded"; fi;

clean_image:
	docker image rm $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) -f
	docker image rm $(PUBLISHER)/$(PROJECT):latest -f

clean_images:
	docker rmi $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION)
	docker rmi $(PUBLISHER)/$(PROJECT):latest

build :
	docker build --no-cache -t $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) . 

tag:
	docker image tag $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION)
	docker image tag $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION) $(PUBLISHER)/$(PROJECT):latest

push:
	docker push $(PUBLISHER)/$(PROJECT):$(IMAGE_VERSION)
	docker push $(PUBLISHER)/$(PROJECT):latest
