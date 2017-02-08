#!/bin/bash

# needs $BISON_VERSION

if [ "$TRAVIS_OS_NAME" = "osx" ]
then SED_OPT="''";
else SED_OPT="";
fi

SED() {
	if [ "$TRAVIS_OS_NAME" = "osx" ]
	then echo "sed -i ''";
	else echo "sed -i";
	fi
}
brew_dependencies() {
	brew install libsndfile # needed for soundpipe
	brew install valgrind   # needed for test
	brew install lua        # need for importing soundpipe
}

install_bison() {
	wget "http://ftp.gnu.org/gnu/bison/$BISON_VERSION.tar.gz"
	tar -xzf bison-3.0.4.tar.gz
	pushd "$BISON_VERSION"
    ./configure --prefix="$PWD/../bison"
    make install
    popd
}

install_bats() {
	git clone https://github.com/sstephenson/bats.git
#	export PATH=$PATH:bats/bin
}

install_soundpipe() {
	git clone -b dev https://github.com/paulbatchelor/Soundpipe.git
	pushd Soundpipe
# use double (or not)
	[ "$GW_FLOAT_TYPE" = "double" ] && $(SED) 's/#USE_DOUBLE/USE_DOUBLE/' config.def.mk
	make
	popd
}

configure_Gwion() {
# use double (or not)
	[ "$GW_FLOAT_TYPE" = "double" ] && sed -i "$SED_OPT" 's/#USE_DOUBLE/USE_DOUBLE/' config.def.mk
# dummy driver
	$(SED) "s/CFLAGS+=-DD_FUNC=alsa_driver/CFLAGS+=-DD_FUNC=dummy_driver/" config.def.mk
# don't build default driver
	$(SED) "s/ALSA_D/#ALSA_D/" config.def.mk
# compile with local static soundpipe
	$(SED) "s/-lsoundpipe/Soundpipe\/libsoundpipe.a/" Makefile
}

prepare_directories() {
	mkdir -p "$GWION_DOC_DIR"
	mkdir -p "$GWION_API_DIR"
	mkdir -p "$GWION_TOK_DIR"
	mkdir -p "$GWION_TAG_DIR"
	mkdir -p "$GWION_PLUG_DIR"
}

#[ "$TRAVIS_OS_NAME" = "osx" ] && brew_dependencies
#install_bison
#install_bats
#install_soundpipe
#configure_Gwion
#prepare_directories
#exit 0
