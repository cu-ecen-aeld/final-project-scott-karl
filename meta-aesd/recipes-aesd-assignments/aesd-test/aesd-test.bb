LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://final-project-full-test.sh"

PV = "1.0"

S = "${WORKDIR}"

# This recipe depends on the packages that provide the scripts called by final-project-full-test.sh
RDEPENDS:${PN} += "aesd-char-driver aesd-socket-server-app"

FILES:${PN} += "${bindir}/final-project-full-test.sh"

do_install () {
	install -d ${D}${bindir}
	install -m 0755 ${S}/final-project-full-test.sh ${D}${bindir}/
}
