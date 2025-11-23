# Original recipe created by recipetool then further modified for this character driver

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Source repository and init script for this driver
SRC_URI = "git://git@github.com/cu-ecen-aeld/assignments-3-and-later-skarl1192.git;protocol=ssh;branch=main \
           file://aesdchar-init \
           "

# Package version based on git and specific commit hash to build from
PV = "1.0+git${SRCPV}"
SRCREV = "218811e8e0882755fac91f436e5e014b9dc9bebc"

# Build from the aesd-char-driver directory where the kernel module source code is located
S = "${WORKDIR}/git/aesd-char-driver"

# Inherit module class for kernel module building and update-rc.d for init script installation
inherit module update-rc.d

# Configure init script for automatic kernel module loading at boot time
INITSCRIPT_PACKAGES = "${PN}"
INITSCRIPT_NAME = "aesdchar-init"
INITSCRIPT_PARAMS = "defaults"

# Pass the kernel build directory to the module Makefile for proper kernel module compilation
EXTRA_OEMAKE += "KERNELDIR=${STAGING_KERNEL_DIR}"

# Include the init script and module load/unload helper scripts in the final package
FILES:${PN} += "${sysconfdir}/init.d/aesdchar-init"
FILES:${PN} += "${bindir}/aesdchar_load ${bindir}/aesdchar_unload"

do_install:append () {
	# Create /etc/init.d directory and install init script
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/aesdchar-init ${D}${sysconfdir}/init.d/
	
	# Create /usr/bin directory and install module load/unload helper scripts
	install -d ${D}${bindir}
	install -m 0755 ${S}/aesdchar_load ${D}${bindir}/
	install -m 0755 ${S}/aesdchar_unload ${D}${bindir}/
}
