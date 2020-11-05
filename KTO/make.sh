REPO	= 121.254.135.234:5000
NAME	= kto-coupon-admin

BOOTAPP		= $(NAME).jar
RELNO		=
PROFILE		= prod
SERVERPORT	=
SCOUTER_IP	= 180.70.96.228
PINPOINT_IP	= 180.70.96.47
GITPROD		= /webapp/baseimage/prod/kto-relno
PROJECT		= kto

.PHONY: build test clean push

build:
	if [ "$(PROFILE)" == "prod" ]; then \
	  if [ -z "$(RELNO)" ]; then \
	    relno=`curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" 2>/dev/null`; \
	  else \
	    relno=latest; \
	  fi; \
	else \
	 relno=$(PROFILE); \
	fi; \
	if docker images --format="{{.Repository}}:{{.Tag}}" | grep -q '^$(NAME):$${relno}$$' >/dev/null 2>&1; then \
	  echo "$(NAME):$${relno} is already exists"; \
	else \
	  if [ "$(PROFILE)" == "dev" ]; then \
	    docker build \
	      -t $(NAME):$${relno} \
	      -f Dockerfile-dev \
	      --build-arg bootapp=$(NAME).jar \
	      --build-arg relno=$${relno} \
	      --build-arg profile=$(PROFILE) \
	      --build-arg serverport=$(SERVERPORT) \
	      --build-arg scouter_ip=$(SCOUTER_IP) \
	      --build-arg pinpoint_ip=$(PINPOINT_IP) \
	    .; \
	  else \
	    docker build \
	      -t $(NAME):$${relno} \
	      --build-arg bootapp=$(NAME).jar \
	      --build-arg relno=$${relno} \
	      --build-arg profile=$(PROFILE) \
	      --build-arg serverport=$(SERVERPORT) \
	      --build-arg scouter_ip=$(SCOUTER_IP) \
	      .; \
	  fi; \
	fi; \
	docker images | fgrep $(NAME)

test: build
	if [ "$(PROFILE)" == "prod" ]; then \
	  if [ -z "$(RELNO)" ]; then \
	    relno=`curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" 2>/dev/null`; \
	  else \
	    relno=latest; \
	  fi; \
	else \
	 relno=$(PROFILE); \
	fi; \
	docker run -it \
	  --rm \
	  --name "TEST-$(NAME)" \
	  --hostname "TEST-$(NAME)" \
	  $(NAME):$${relno} \
	  /bin/bash

clean:
	if [ "$(PROFILE)" == "prod" ]; then \
	  if [ -z "$(RELNO)" ]; then \
	    relno=`curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" 2>/dev/null`; \
	  else \
	    relno=latest; \
	  fi; \
	else \
	 relno=$(PROFILE); \
	fi; \
	docker rmi \
	  $(NAME):$${relno} \
	  $(NAME):latest \
	  $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} \
	  $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):latest; \
	true

push:
	if [ "$(PROFILE)" == "prod" ]; then \
	  if [ -z "$(RELNO)" ]; then \
	    relno=`curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" 2>/dev/null`; \
	    docker tag $(NAME):$${relno} $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} && \
	    docker tag $(NAME):$${relno} $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):latest && \
	    docker push $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} && \
	    docker push $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):latest; \
	    if [ ! -d "$(GITPROD)/$(NAME)" ]; then \
	      mkdir -p $(GITPROD)/$(NAME); \
  	    fi; \
	    curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" -s  "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.json/raw?ref=master" > $(GITPROD)/$(NAME)/relno.json; \
	    curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" -s  "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" > $(GITPROD)/$(NAME)/relno.txt; \
	    commMsg=`curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.json/raw?ref=master" 2>/dev/null`; \
	    cd $(GITPROD); \
	    git add $(NAME) && \
	    git commit -m "$${commMsg}" && \
	    git push origin master; \
	  else \
	    relno=$(PROFILE); \
            docker tag $(NAME):$${relno} $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} && \
            docker tag $(NAME):$${relno} $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):latest && \
            docker push $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} && \
            docker push $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):latest; \
            if [ ! -d "$(GITPROD)/$(NAME)" ]; then \
              mkdir -p $(GITPROD)/$(NAME); \
            fi; \
            curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" -s  "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.json/raw?ref=master" > $(GITPROD)/$(NAME)/relno.json; \
            curl --header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" -s  "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.txt/raw?ref=master" > $(GITPROD)/$(NAME)/relno.txt; \
            commMsg=`header "PRIVATE-TOKEN:ztzizfpmsWNby4Fy7xvZ" "http://gitlab.interpark.com/api/v4/projects/1516/repository/files/data%2Frelno.json/raw?ref=master" 2>/dev/null`; \
            cd $(GITPROD); \
            git add $(NAME) && \
            git commit -m "$${commMsg}" && \
            git push origin master; \
	  fi; \
	else \
	  relno=$(PROFILE); \
	  docker tag $(NAME):$${relno} $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno} && \
	  docker push $(REPO)/$(PROJECT)/$(PROFILE)/$(NAME):$${relno}; \
	fi; \
