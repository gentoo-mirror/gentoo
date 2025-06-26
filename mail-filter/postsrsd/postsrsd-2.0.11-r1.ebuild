# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake eapi9-ver readme.gentoo-r1 systemd

DESCRIPTION="Postfix Sender Rewriting Scheme daemon"
HOMEPAGE="https://github.com/roehling/postsrsd"
SRC_URI="https://github.com/roehling/postsrsd/archive/${PV}.tar.gz -> ${P}.tar.gz"

# See REUSE.toml; GPL-3 for the main software, BSD for src/sha*.
LICENSE="GPL-3 BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="dev-libs/confuse:="
DEPEND="
	${RDEPEND}
	test? ( dev-libs/check )
"

CHROOT_DIR="${EPREFIX}/var/lib/postsrsd"

PATCHES=(
	"${FILESDIR}"/${PN}-2.0.11-sysconfdir.patch
)
DOCS=( README.rst CHANGELOG.rst )

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)

		-DPOSTSRSD_CHROOTDIR="${CHROOT_DIR}"
		-DSYSTEMD_UNITDIR="$(systemd_get_systemunitdir)"
		-DSYSTEMD_SYSUSERSDIR="${EPREFIX}/usr/lib/sysusers.d"

		-DINSTALL_SYSTEMD_SERVICE=ON
		# https://github.com/roehling/postsrsd/blob/main/doc/packaging.rst#third-party-dependencies
		-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
		# We don't want to run tests with sanitizers. They're
		# unreliable under sandbox and don't run on all platforms
		-DTESTS_WITH_ASAN=OFF

		-DWITH_MILTER=OFF
		-DWITH_SQLITE=OFF
		-DWITH_REDIS=OFF
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	newinitd "${FILESDIR}"/postsrsd-2.0.11.initd postsrsd
	newconfd "${FILESDIR}"/postsrsd-2.0.11.confd postsrsd
	keepdir "${CHROOT_DIR}"

	local DOC_CONTENTS="When updating from version 1.x:
		\n\nNote that most configuration options can no longer be set from the
		command line, therefore we cannot define them in OpenRC's conf.d file
		either. You will have to set them in ${EPREFIX}/etc/postsrsd.conf
		instead.
		\n\nIn the config file, you must *at least* set the \"domains\"
		variable, i.e. the local domain name. In most cases, using the output
		of \"postconf -h mydomain\" should be okay.
		\n\nAlso note that PostSRSd 2.x by default uses Unix domain sockets
		instead	of TCP sockets, so you must update \"sender_canonical_maps\"
		and \"recipient_canonical_maps\" in ${EPREFIX}/etc/postfix/main.cf.
		(Alternatively, you can update \"socketmap\" in postsrsd.conf.)
		\n\nSee README.rst and the comments in postsrsd.conf for more detailed
		information."
	readme.gentoo_create_doc
}

pkg_postinst() {
	ver_replacing -lt 2.0.11-r1 && local FORCE_PRINT_ELOG=1
	readme.gentoo_print_elog
}
