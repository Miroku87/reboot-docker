.PHONY: local
local:
	export BUILD_TYPE=local && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: preprod
preprod:
	export BUILD_TYPE=preprod && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: prod
prod:
	export BUILD_TYPE=prod && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build
