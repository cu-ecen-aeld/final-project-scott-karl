# License configuration for this socket server application
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Remote repository
SRC_URI = "git://git@github.com/cu-ecen-aeld/assignments-3-and-later-skarl1192.git;protocol=ssh;branch=main \
           file://aesdsocket-test.sh"

# Package version based on git and specific commit hash to build from
PV = "1.0+git${SRCPV}"
SRCREV = "${AUTOREV}"

# Build from the server directory in the git repository where aesdsocket source code is located
S = "${WORKDIR}/git/server"

# Specify that the aesdsocket binary will be installed to /usr/bin in the final image
FILES:${PN} += "${bindir}/aesdsocket \
                ${bindir}/aesdsocket-test.sh \
                ${sysconfdir}/init.d/aesdsocket-start-stop"

# Link with pthread and real-time libraries required by the socket server application
TARGET_LDFLAGS += "-pthread -lrt"

# sockettest.sh uses bash
RDEPENDS:${PN} += "bash"

# Inherit update-rc.d class to handle init script installation and configuration
inherit update-rc.d

# Flag this package as one which uses init scripts
INITSCRIPT_PACKAGES = "${PN}"
# Specify the name of the init script file for the socket server
INITSCRIPT_NAME = "aesdsocket-start-stop"
# Start socket server in runlevels 2,3,4,5 with priority 99, stop in 0,1,6 with priority 01
INITSCRIPT_PARAMS = "defaults 99"

do_configure () {
	# Copy local test script to source directory to overwrite git file
	cp ${WORKDIR}/aesdsocket-test.sh ${S}/
}

do_compile () {
	# Runs make in the ${S} directory to compile aesdsocket
	oe_runmake
}

do_install () {
	# TODO: Install your binaries/scripts here.
	# Be sure to install the target directory with install -d first
	# Yocto variables ${D} and ${S} are useful here, which you can read about at 
	# https://docs.yoctoproject.org/ref-manual/variables.html?highlight=workdir#term-D
	# and
	# https://docs.yoctoproject.org/ref-manual/variables.html?highlight=workdir#term-S
	# See example at https://github.com/cu-ecen-aeld/ecen5013-yocto/blob/ecen5013-hello-world/meta-ecen5013/recipes-ecen5013/ecen5013-hello-world/ecen5013-hello-world_git.bb
    
	# ${D} - The destination directory (staging area) where files are installed before packaging
	#        This represents the root filesystem that will be packaged into the final image
	#        Example: ${D} = /path/to/build/tmp/work/.../image/1.0-r0/image/
	
	# ${S} - The source directory set to the aesd server folder in the git repo where 
	#        the building of the aesdsocket application was done
	
	# Create the target directory
    # install -d: Creates directory and any parent directories if they don't exist
    # ${bindir}: Yocto variable that typically expands to /usr/bin
    # Result: Creates ${D}/usr/bin directory in the staging area
    install -d ${D}${bindir}
    
    # Install the aesdsocket binary
    # install: Copies files and sets permissions in one command
    # -m 0755: Sets file permissions to rwxr-xr-x (owner can read/write/execute, group and others can read/execute)
    # ${S}/aesdsocket: Source file - the compiled binary from the build directory
    # ${D}${bindir}/: Destination - copies to ${D}/usr/bin/ in the staging area
    # Result: The aesdsocket binary is copied to /usr/bin/ with executable permissions in the final image
    install -m 0755 ${S}/aesdsocket ${D}${bindir}/
    
    # Install the test scripts
    install -m 0755 ${S}/aesdsocket-test.sh ${D}${bindir}/

    # Install the init script
    # ${sysconfdir} typically expands to /etc
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${S}/aesdsocket-start-stop ${D}${sysconfdir}/init.d/
}
