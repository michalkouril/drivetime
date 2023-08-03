.PHONY: build test shell clean isochrones

build:
	http_proxy=
	https_proxy=
	[ -f ../sysproxy.sh ] && . ../sysproxy.sh
	docker build -t drivetime .  --build-arg http_proxy="$(http_proxy)" --build-arg https_proxy="$(https_proxy)"

isochrones:
	http_proxy=
	https_proxy=
	[ -f ../sysproxy.sh ] && . ../sysproxy.sh
	docker run --rm -v `pwd`:`pwd` -w /app  --entrypoint=R  -e ISO_DATADIR=`pwd`/isochrones -e CENTERS_FILENAME=`pwd`/ctsa_centers.csv -e http_proxy="$(http_proxy)" -e https_proxy="$(https_proxy)" -e no_proxy=10.200.42.250 drivetime R -e 'source("download_isochrones.R")'

test:
	http_proxy=
	https_proxy=
	[ -f ../sysproxy.sh ] && . ../sysproxy.sh
	docker run --rm -v `pwd`:`pwd` -w /app   -e OUTPUT_FILENAME=`pwd`/output.csv -e ISO_DATADIR=`pwd`/isochrones -e CENTERS_FILENAME=`pwd`/ctsa_centers.csv -e http_proxy="$(http_proxy)" -e https_proxy="$(https_proxy)" -e no_proxy=10.200.42.250 drivetime `pwd`/patients.csv

shell:
	http_proxy=
	https_proxy=
	[ -f ../sysproxy.sh ] && . ../sysproxy.sh
	docker run -it --rm --entrypoint=/bin/bash -v `pwd`:`pwd` -w /app   -e ISO_DATADIR=`pwd`/isochrones -e CENTERS_FILENAME=`pwd`/ctsa_centers.csv -e http_proxy="$(http_proxy)" -e https_proxy="$(https_proxy)" -e no_proxy=10.200.42.250 drivetime

	# docker run --rm -it --entrypoint=/bin/bash -v "${PWD}/test":/tmp drivetime

clean:
	docker system prune -f
