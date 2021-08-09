#

## Build the baseimage that is used to build the packages
baseimage:
	docker build --pull --tag atlascloud/ceph-builder .
	docker push atlascloud/ceph-builder

## Build the actual ceph packages
build:
	# docker pull atlascloud/ceph-builder
	docker run --rm \
		--privileged \
		-e PACKAGER -e PACKAGER_PRIVKEY -e SIGNING_KEY \
		-e JOBS=5 -e RELEASE -e APORTS_DIR -e REPODEST \
		-v $(PWD):/home/build \
		-v $(PWD)/apkcache:/etc/apk/cache \
		-v $(PWD)/distfiles:/var/cache/distfiles \
		--name ceph-builder \
		ghcr.io/atlascloud/aports-builder:edge

		# /bin/sh -c "pwd ; sudo chown -R build:build /var/cache/distfiles /home/build/.ccache ; echo abuild -r ; sh"

## this is for local dev
build_shell:
	chown -R 1000:1000 distfiles
	docker run -it --rm \
		--privileged \
		-v $(PWD):/home/build \
		-v $(PWD)/apkcache:/etc/apk/cache \
		-v $(PWD)/distfiles:/var/cache/distfiles \
		--name ceph-builder \
		--entrypoint /bin/sh \
		--env-file .env \
		ghcr.io/atlascloud/aports-builder:edge
