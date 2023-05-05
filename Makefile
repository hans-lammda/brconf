

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

CC_TOP = ${WORKDIR}/x-tools
CROSS_COMP_PATH        = $(CC_TOP)/x86_64-pc-linux-musl
CROSS_COMP_PREFIX      = x86_64-pc-linux-musl-
CROSS_COMPILE          = $(CROSS_COMP_PATH)/bin/$(CROSS_COMP_PREFIX)
CROSS_COMPILER_CFLAGS  = -I$(CROSS_COMP_DIR)/include  -ffreestanding -mgeneral-regs-only -nostdinc  -ffunction-sections -fdata-sections  -fno-stack-protector --no-common

CROSS_COMPILE = 
CC                     = $(CROSS_COMPILE)gcc
LD                     = $(CROSS_COMPILE)ld
OBJCOPY                = $(CROSS_COMPILE)objcopy

hello_static: 
	$(CC) hello.c --static -o hello_static

hello_musl: 
	$(CC) hello.c  -o hello_musl

dl:
	gcc -rdynamic -o dl dl.c -ldl
good:
	gcc -shared -fPIC -o hello_lib.so good_lib.c
bad:
	gcc -shared -fPIC -o hello_lib.so bad_lib.c

plugin: dl good 

clean_code: 
	rm -f hello hello_static hello_musl dl  hello_lib.so


