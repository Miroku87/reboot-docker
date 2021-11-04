.PHONY: dev
dev:
	docker-compose rm -f && docker-compose up --build

.PHONY: local
local:
	export BUILD_TYPE=local && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: local-client
local-client:
	export BUILD_TYPE=local && export BUILD_WHAT=client && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: local-server
local-server:
	export BUILD_TYPE=local && export BUILD_WHAT=server && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: preprod
preprod:
	export BUILD_TYPE=preprod && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: preprod-client
preprod-client:
	export BUILD_TYPE=preprod && export BUILD_WHAT=client && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: preprod-server
preprod-server:
	export BUILD_TYPE=preprod && export BUILD_WHAT=server && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: prod
prod:
	export BUILD_TYPE=prod && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: prod-client
prod-client:
	export BUILD_TYPE=prod && export BUILD_WHAT=client && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build

.PHONY: prod-server
prod-server:
	export BUILD_TYPE=prod && export BUILD_WHAT=server && docker-compose rm -f && docker-compose -f ./docker-compose-build.yml up --build
