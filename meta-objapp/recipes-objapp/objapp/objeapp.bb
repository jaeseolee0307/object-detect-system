inherit update-rc.d

SRC_URI = "{workingdir}/raspberry_pi"
PV = "1.0+git${SRCPV}"
SRCREV = "a215357eb860a55996a4f4790faaab54f7ba70f4"
S = "${WORKDIR}/git/server"

# TODO: Add the aesdsocket application and any other files you need to install
# See https://git.yoctoproject.org/poky/plain/meta/conf/bitbake.conf?h=kirkstone
FILES:${PN} += "${bindir}/objapp"
TARGET_LDFLAGS += "-pthread -lrt"

INITSCRIPT_PACKAGES = "${PN}"

INITSCRIPT_NAME:${PN} = "objapp-start-stop.sh"

do_configure () {
	:
}

do_compile () {
	oe_runmake
}

do_install () {
install -d ${D}${bindir}
	install -m 0755 ${S}/raspberrypi ${D}${bindir}/
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${S}/objapp-start-stop.sh ${D}${sysconfdir}/init.d
}
