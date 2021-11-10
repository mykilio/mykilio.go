BIN_DIR		:= ./bin
CMD_DIR		:= ./cmd

SVC_TARGETS	:= $(addprefix $(BIN_DIR)/,$(patsubst $(CMD_DIR)/%/,%,$(dir $(wildcard $(CMD_DIR)/*/))))
SVC_SOURCES	:= $(shell find . -name "*.go")

LDFLAGS		?= -s -w

VERSION		?= dev
PROFILES	?= audit,status,gateway-http,mail


.PHONY: all up clean

# Compile all microservices.
all: $(SVC_TARGETS)

# Compile a single microservice. Below you may find extra options you
# may set to configure the build process.
# - Setting LDFLAGS= will disable stripping.
# - Setting UPXFLAGS= will enable binary compression via UPX.
$(SVC_TARGETS): $(BIN_DIR)/%: $(SVC_SOURCES)
	@mkdir -p $(@D)
	CGO_ENABLED=0 go build -o $@ -ldflags "-X main.name=$(@F) -X main.version=$(VERSION) $(LDFLAGS)" $(CMD_DIR)/$(@F)
ifdef UPX
	upx $(UPX) $@
endif

# Build all microservices and run them locally via `docker-compose`.
# Using buildkit significantly enhances the build speed.
# TODO: Create `k3d` setup.
up:
	COMPOSE_PROFILES=nats,prometheus,grafana,$(PROFILES) COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker-compose -f deployments/docker-compose.yml --env-file .env \
	up --build --remove-orphans

# Clean up previously compiled binaries.
clean:
	-@rm -rvf $(SVC_TARGETS)
