

WORKDIR := ${PWD}
BUILDROOT := ${WORKDIR}/buildroot
CT_NG := ${WORKDIR}/crosstool-ng
TESTDIR := ${BUILDROOT}/output/images/test


download:
	
	git clone git://git.buildroot.net/buildroot
	git clone https://github.com/crosstool-ng/crosstool-ng
	${CT_NG}/bootstrap && ${CT_NG}/configure && make -C ${CT_NG} && sudo make install -C ${CT_NG}
build:
	
	cp ${WORKDIR}/config_crosstool ${CT_NG}/.config
	cp ${WORKDIR}/config_buildroot ${BUILDROOT}/.config
	cd ${CT_NG} && ./ct-ng build
	make all -C ${BUILDROOT}


test:
	#mkdir ${TESTDIR}
	tar -xf ${BUILDROOT}/output/images/rootfs.tar -C ${TESTDIR}
	sudo chroot ${TESTDIR} touch test
	EXIT_CODE=$$?;\
	echo "exit: $$EXIT_CODE"
	


clean:
	${CT_NG}/ct-ng clean
	make clean -C ${BUILDROOT}


distclean:
	${CT_NG}/ct-ng distclean
	make distclean -C ${BUILDROOT}

all: download build test
