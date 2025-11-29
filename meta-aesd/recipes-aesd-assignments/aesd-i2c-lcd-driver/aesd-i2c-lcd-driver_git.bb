# Recipe for aesd-lcd-driver
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# 1. Source Configuration
SRC_URI = "git://git@github.com/cu-ecen-aeld/assignments-3-and-later-skarl1192.git;protocol=ssh;branch=main \
           file://aesdlcd-test.sh"
PV = "1.0+git${SRCPV}"
SRCREV = "${AUTOREV}"
# Source directory configuration
# Build from the aesd-i2c-lcd-driver directory where the kernel module source code is located
S = "${WORKDIR}/git/aesd-i2c-lcd-driver"

# 2. Inherit classes
# module: compiles the kernel driver
# update-rc.d: handles the start/stop init script installation
# deploy: allows us to publish the .dtbo
inherit module update-rc.d deploy

# 3. Dependencies
DEPENDS += "dtc-native"
RDEPENDS:${PN} += "kernel-module-aesdlcd-driver"

# 4. Init Script Config
# This registers the script to run at boot
INITSCRIPT_PACKAGES = "${PN}"
INITSCRIPT_NAME = "aesdlcd-start-stop.sh"
INITSCRIPT_PARAMS = "defaults"

EXTRA_OEMAKE += "KERNELDIR=${STAGING_KERNEL_DIR}"

# 5. Files to Package
FILES:${PN} += "${sysconfdir}/init.d/aesdlcd-start-stop.sh"
FILES:${PN} += "${bindir}/aesdlcd_load.sh"
FILES:${PN} += "${bindir}/aesdlcd_unload.sh"
FILES:${PN} += "${bindir}/aesdlcd-test.sh"
FILES:${PN} += "${bindir}/aesdlcd-health-check.sh"
FILES:${PN} += "/boot/overlays/aesd-lcd-overlay.dtbo"

do_install:append () {
    # A. Install Init Script
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${S}/aesd_lcd-start-stop ${D}${sysconfdir}/init.d/aesdlcd-start-stop.sh

    # B. Install Load/Unload Helper Scripts
    install -d ${D}${bindir}
    install -m 0755 ${S}/aesd_lcd_load ${D}${bindir}/aesdlcd_load.sh
    install -m 0755 ${S}/aesd_lcd_unload ${D}${bindir}/aesdlcd_unload.sh
    install -m 0755 ${WORKDIR}/aesdlcd-test.sh ${D}${bindir}/
    install -m 0755 ${WORKDIR}/aesdlcd-health-check.sh ${D}${bindir}/

    # C. Compile and Install Overlay
    dtc -O dtb -o ${S}/aesd-lcd-overlay.dtbo -b 0 -@ ${S}/aesd-lcd-overlay.dts
    
    install -d ${D}/boot/overlays
    install -m 0644 ${S}/aesd-lcd-overlay.dtbo ${D}/boot/overlays/aesd-lcd-overlay.dtbo
}

do_deploy() {
    install -d ${DEPLOYDIR}/overlays
    install -m 0644 ${S}/aesd-lcd-overlay.dtbo ${DEPLOYDIR}/overlays/aesd-lcd-overlay.dtbo
}

addtask deploy after do_install before do_build