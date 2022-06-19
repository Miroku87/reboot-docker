@echo off

set APP_NAME=reboot-docker
set PWD=%cd%

set DOCKER_NAME=%APP_NAME%_%1%
set DOCKER_INTERACTIVE_FLAG=-it
set DOCKER_DETATCH_FLAG=-d
set DOCKER_PORTS_FLAG=-p 9000:9000
set DOCKER_VOLUMES_FLAG=-v %PWD%:/%APP_NAME%:Z -w /%APP_NAME%
set DOCKER_NAME_FLAG=--name %DOCKER_NAME%
set DOCKER_IMAGE=node:14.9.0
set DOCKER_RUN_CMD=docker run --rm %DOCKER_VOLUMES_FLAG% %DOCKER_NAME_FLAG%
set DOCKER_STOP_CMD=docker stop %DOCKER_NAME%

	
IF "%1%"=="dev" (
	docker-compose rm -f
	docker-compose up --build
)

IF "%1%"=="local" (
	SET BUILD_TYPE=local
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="local-client" (
	SET BUILD_TYPE=local
	SET BUILD_WHAT=client
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="local-server" (
	SET BUILD_TYPE=local
	SET BUILD_WHAT=server
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="preprod" (
	SET BUILD_TYPE=preprod
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="preprod-client" (
	SET BUILD_TYPE=preprod
	SET BUILD_WHAT=client
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="preprod-server" (
	SET BUILD_TYPE=preprod
	SET BUILD_WHAT=server
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="prod" (
	SET BUILD_TYPE=prod
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="prod-client" (
	SET BUILD_TYPE=prod
	SET BUILD_WHAT=client
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)

IF "%1%"=="prod-server" (
	SET BUILD_TYPE=prod
	SET BUILD_WHAT=server
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)