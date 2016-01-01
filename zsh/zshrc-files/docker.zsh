#### 4.1 Docker
###### Docker-Quickstart
	docker-quickstart () {
		docker-machine start default;
		docker-machine env default;
		eval "$(docker-machine env default)";
		clear;
	}

