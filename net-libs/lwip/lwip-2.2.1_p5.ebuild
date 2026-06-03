# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake edos2unix

LWIP_BASE_S="${WORKDIR}"/${P%_p*}
LWIP_POSIX_S="${LWIP_BASE_S}"/contrib/ports/unix/posixlib

DESCRIPTION="Small independent implementation of the TCP/IP protocol suite"
HOMEPAGE="https://savannah.nongnu.org/projects/lwip/"
SRC_URI="mirror://nongnu/${PN}/${P%_p*}.zip"

if [[ ${PV} == *_p* ]] ; then
	LWIP_PV=+dfsg1-${PV#*_p}
	SRC_URI+=" mirror://debian/pool/main/l/${PN}/${PN}_${PV%_p*}${LWIP_PV}.debian.tar.xz"
fi

S="${LWIP_POSIX_S}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="app-arch/unzip"

src_prepare() {
	cd "${LWIP_BASE_S}" || die

	# The .zips produced by upstream have Windows line-endings, but
	# the Debian patches don't.
	edos2unix $(find "${LWIP_BASE_S}" -type 'f' || die)

	eapply $(awk '{print $1}' "${WORKDIR}"/debian/patches/series | sed -e '/^#/d' -e "s:^:${WORKDIR}/debian/patches/:")

	sed -i -e 's:-Werror::' \
		contrib/ports/CMakeCommon.cmake \
		contrib/ports/Common.allports.mk || die

	cd "${LWIP_POSIX_S}" || die

	cmake_src_prepare
}
