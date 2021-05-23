

WORKDIR := ${PWD}
BUILDROOT := ${WORKDIR}/buildroot
CT_NG := ${WORKDIR}/crosstool-ng
TESTDIR := ${BUILDROOT}/output/images/test

.PHONY: buildroot

download:
	if [ ! -d ${BUILDROOT} ]; \
	then \
		git clone git://git.buildroot.net/buildroot; \
	fi
	if [ ! -d ${CT_NG} ]; \
	then \
		git clone https://github.com/crosstool-ng/crosstool-ng; \
	fi


install: download
	
	if [ ! -f '${CT_NG}/ct-ng' ]; \
	then \
		cd ${CT_NG} && ./bootstrap; \
		cd ${CT_NG} && ./configure; \
		cd ${CT_NG} && make && sudo make install; \
	fi

buildroot:
	cp ${WORKDIR}/config_buildroot_crosstool ${BUILDROOT}/.config;
	make -C ${BUILDROOT};
	
	
buildroot_ct:
	export CT_TOOLCHAIN=${WORKDIR}/x-tools; \
	cp ${WORKDIR}/config_buildroot_ext_crosstool ${BUILDROOT}/.config; \
	make -C ${BUILDROOT};

crosstool: install
	export CT_TOOLCHAIN=${WORKDIR}/x-tools;	\
	cp ${WORKDIR}/config_crosstool ${CT_NG}/.config; \
	cd ${CT_NG} && ./ct-ng build
	#make -C ${BUILDROOT}; \
	#if [ $$? -ne 0 ]; then \
	#	rm ${BUILDROOT}/output/target/etc/ld.so.conf; \
	#	make -C ${BUILDROOT}; \
	#fi


test:
	if [ -d ${TESTDIR} ]; then \
		rm -rf ${TESTDIR}; \
	fi
	mkdir ${TESTDIR}
	tar -xf ${BUILDROOT}/output/images/rootfs.tar -C ${TESTDIR}
	sudo chroot ${TESTDIR} touch test
	if [ $$? -eq 0 ]; then \
		echo "Test OK"; \
	else \
		echo "Test failed"; \
	fi

clean:
	${CT_NG}/ct-ng clean
	make clean -C ${BUILDROOT}


distclean:
	${CT_NG}/ct-ng distclean
	make distclean -C ${BUILDROOT}


all: download install crosstool buildroot_ct test clean buildroot test
