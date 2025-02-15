
default:

buildx-setup:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx use default
	docker buildx rm nubuilder
	docker buildx create --name nubuilder
	docker buildx use nubuilder
	docker buildx ls

docker-base-armv7:
	docker buildx build \
		--pull --push \
		--build-arg BAZEL_OPTS="--cpu=armhf" \
		--build-arg JOBS="16" \
		--platform linux/arm/v7 \
		-f docker/Dockerfile.base \
		--tag docker.io/snowzach/doods2:base-armv7l .

docker-base-arm64v8:
	docker buildx build \
		--pull --push \
		--build-arg BAZEL_OPTS="--cpu=aarch64" \
		--build-arg JOBS="16" \
		--platform linux/arm64/v8 \
		-f docker/Dockerfile.base \
		--tag docker.io/snowzach/doods2:base-aarch64 .

docker-base-amd64:
	docker buildx build \
		--pull --push \
		--build-arg BAZEL_OPTS="--config=avx_linux" \
		--build-arg JOBS="16" \
		--platform linux/amd64 \
		-f docker/Dockerfile.base \
		--tag docker.io/snowzach/doods2:base-amd64 .

docker-base-amd64-noavx:
	docker buildx build \
		--pull --push \
		--build-arg BAZEL_OPTS="" \
		--build-arg JOBS="16" \
		--platform linux/amd64 \
		-f docker/Dockerfile.base \
		--tag docker.io/snowzach/doods2:base-amd64-noavx .

docker-base-amd64-gpu:
	docker buildx build \
		--pull --push \
		-f docker/Dockerfile.base.amd64-gpu \
		--tag docker.io/snowzach/doods2:base-amd64-gpu .

docker-base: docker-base-armv7 docker-base-arm64v8 docker-base-amd64-noavx docker-base-amd64 docker-base-amd64-gpu

docker-armv7:
	docker buildx build \
		--pull --push \
		--build-arg TAG="armv7l" \
		-f docker/Dockerfile \
		--tag docker.io/snowzach/doods2:armv7l .

docker-arm64v8:
	docker buildx build \
		--pull --push \
		--build-arg TAG="aarch64" \
		-f docker/Dockerfile \
		--tag docker.io/snowzach/doods2:aarch64 .

docker-amd64:
	docker buildx build \
		--pull --push \
		--build-arg TAG="amd64" \
		-f docker/Dockerfile \
		--tag docker.io/snowzach/doods2:amd64 .

docker-amd64-noavx:
	docker buildx build \
		--pull --push \
		--build-arg TAG="amd64-noavx" \
		-f docker/Dockerfile \
		--tag docker.io/snowzach/doods2:amd64-noavx .

docker-amd64-gpu:
	docker buildx build \
		--pull --push \
		--build-arg TAG="amd64-gpu" \
		-f docker/Dockerfile \
		--tag docker.io/snowzach/doods2:amd64-gpu .

docker: docker-armv7 docker-arm64v8 docker-amd64 docker-amd64-noavx docker-amd64-gpu
	docker manifest push --purge docker.io/snowzach/doods2:latest
	docker manifest create \
		docker.io/snowzach/doods2:latest \
		docker.io/snowzach/doods2:armv7l \
		docker.io/snowzach/doods2:aarch64 \
		docker.io/snowzach/doods2:amd64-noavx
	docker manifest push docker.io/snowzach/doods2:latest

docker-config:
	# Build the base config image
	docker buildx build --pull --push -f docker/Dockerfile.base.config --tag docker.io/snowzach/doods2:base-config .

