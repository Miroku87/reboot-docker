@echo off

set APP_NAME=reboot-docker
set PWD=%cd%
	
IF "%1%"=="dev" (
	docker-compose rm -f
	docker-compose up --build
)

IF NOT "%1%"=="dev" (
	SET BUILD_TYPE=%1%
	SET BUILD_WHAT=%2%
	docker-compose rm -f
	docker-compose -f ./docker-compose-build.yml up --build
)
