#

## Build the baseimage that is used to build ceph packages
baseimage:
	docker build --pull --tag atlascloud/ceph-builder .

## Build the actual ceph packages
build:
	docker pull atlascloud/ceph-builder
	docker run -it --rm \
		--privileged \
		-v $(PWD):/home/build \
		-v $(PWD)/distfiles:/var/cache/distfiles \
		--name ceph-builder \
		atlascloud/ceph-builder \
		abuild -r

		# /bin/sh -c "pwd ; sudo chown -R build:build /var/cache/distfiles /home/build/.ccache ; echo abuild -r ; sh"
