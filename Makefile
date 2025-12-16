REGISTRY ?= your-registry
TAG      ?= 6

IMG_PHP   := $(REGISTRY)/limesurvey-phpfpm:$(TAG)
IMG_NGINX := $(REGISTRY)/limesurvey-nginx:$(TAG)

CHART_DIR := charts/limesurvey
RELEASE   ?= limesurvey
NAMESPACE ?= default

.PHONY: build push deploy upgrade template

build:
	docker build -t $(IMG_PHP) images/phpfpm
	docker build -t $(IMG_NGINX) images/nginx

push:
	docker push $(IMG_PHP)
	docker push $(IMG_NGINX)

deploy:
	helm install $(RELEASE) $(CHART_DIR) -n $(NAMESPACE) --create-namespace \
	  --set images.php.repository=$(REGISTRY)/limesurvey-phpfpm --set images.php.tag=$(TAG) \
	  --set images.nginx.repository=$(REGISTRY)/limesurvey-nginx --set images.nginx.tag=$(TAG)

upgrade:
	helm upgrade $(RELEASE) $(CHART_DIR) -n $(NAMESPACE) \
	  --set images.php.repository=$(REGISTRY)/limesurvey-phpfpm --set images.php.tag=$(TAG) \
	  --set images.nginx.repository=$(REGISTRY)/limesurvey-nginx --set images.nginx.tag=$(TAG)

template:
	helm template $(RELEASE) $(CHART_DIR) -n $(NAMESPACE)
