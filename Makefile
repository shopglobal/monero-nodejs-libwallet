NERO_BRANCH?="12.3.5-omega"
NERO_BUILD_TYPE?=Release

BOOST_VERSION=1.66.0
BOOST_DIRNAME=boost_1_66_0

PWD=${shell pwd}
BOOST_LIBS=chrono,date_time,filesystem,program_options,regex,serialization,system,thread
THREADS?=1

.PHONY: all
all: binding.gyp deps
	node_modules/.bin/node-pre-gyp configure build

.PHONY: clean
clean:
	rm -rf boost
	rm -rf electronero/build
	rm -rf ${BOOST_DIRNAME}
	rm -rf deps
	rm -rf build
	rm -rf lib

${BOOST_DIRNAME}.tar.bz2: 
	curl -L -o "${BOOST_DIRNAME}.tar.bz2" \
            http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST_DIRNAME}.tar.bz2/download

${BOOST_DIRNAME}: ${BOOST_DIRNAME}.tar.bz2
	tar xf ${BOOST_DIRNAME}.tar.bz2
	cd ${BOOST_DIRNAME} && ./bootstrap.sh --with-libraries=${BOOST_LIBS}

boost: ${BOOST_DIRNAME}
	cd ${BOOST_DIRNAME} && ./b2 -j4 cxxflags=-fPIC cflags=-fPIC -a link=static \
		threading=multi threadapi=pthread --prefix=${PWD}/boost install

.PHONY: deps
deps: boost electronero/build
	mkdir -p deps
	cp boost/lib/*.a deps

electronero:
	git clone --depth 1 --recurse-submodules -b ${NERO_BRANCH} https://github.com/electronero/electronero
	cp electronero/src/wallet/api/wallet2_api.h include
	
electronero/build: boost electronero
	mkdir -p electronero/build
	mkdir -p deps
	cd electronero/build && cmake -DBOOST_IGNORE_SYSTEM_PATHS=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_GUI_DEPS=ON \
		-DUSE_DEVICE_LEDGER=0 -DBUILD_TESTS=OFF -DSTATIC=ON \
		-DCMAKE_BUILD_TYPE=${NERO_BUILD_TYPE} \
		-DBOOST_ROOT=${PWD}/boost \
		-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true \
		-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${PWD}/deps \
		-DEMBEDDED_WALLET=1 \
		..

	cd electronero/build && make -j${THREADS} wallet_merged epee easylogging lmdb unbound VERBOSE=1
	cp electronero/build/lib/libwallet_merged.a ${PWD}/deps
