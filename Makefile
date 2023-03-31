

WORKDIR := ${PWD}
BUILDROOT := ${WORKDIR}/buildroot
CT_NG := ${WORKDIR}/crosstool-ng
TESTDIR := ${BUILDROOT}/output/images/test

.PHONY: buildroot

download: dwnld_br dwnld_ct

dwnld_br:
	if [ ! -d ${BUILDROOT} ]; \
	then \
		git clone git://git.buildroot.net/buildroot; \
	fi

dwnld_ct:
	if [ ! -d ${CT_NG} ]; \
	then \
		git clone https://github.com/crosstool-ng/crosstool-ng; \
	fi


crosstool_build:
	
	if [ ! -f '${CT_NG}/ct-ng' ]; \
	then \
		cd ${CT_NG} && ./bootstrap; \
		cd ${CT_NG} && ./configure; \
		cd ${CT_NG} && make &&  make install; \
	fi

crosstool_config:
	export CT_TOOLCHAIN=${WORKDIR}/x-tools; \
	cp ${WORKDIR}/config_crosstool ${CT_NG}/.config; \
	cd ${CT_NG} && ./ct-ng build 

	
	
buildroot_ct:
	export CT_TOOLCHAIN=${WORKDIR}/x-tools; \
	cp ${WORKDIR}/config_buildroot_ext_crosstool ${BUILDROOT}/.config; \
	make -C ${BUILDROOT};



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


container: 
	cp  ${BUILDROOT}/output/images/rootfs.tar . 
	gzip rootfs.tar 
	podman build -t  lighttpd  -f Containerfile .

run: 
	podman run -i -t lighttpd:latest sh 

clean: clean_ct clean_br

clean_ct:
	${CT_NG}/ct-ng clean

clean_br:
	make clean -C ${BUILDROOT}


distclean:
	${CT_NG}/ct-ng distclean
	make distclean -C ${BUILDROOT}


all: download install crosstool buildroot_ct test
