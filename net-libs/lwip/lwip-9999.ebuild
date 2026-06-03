# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake edos2unix

LWIP_BASE_S="${WORKDIR}"/${P%_p*}
LWIP_POSIX_S="${LWIP_BASE_S}"/contrib/ports/unix/posixlib

DESCRIPTION="Small independent implementation of the TCP/IP protocol suite"
HOMEPAGE="https://savannah.nongnu.org/projects/lwip/"

if [[ ${PV} == 9999 ]] ; then
	EGIT_REPO_URI="
		https://https.git.savannah.gnu.org/git/lwip.git
		https://github.com/lwip-tcpip/lwip
	"
	inherit git-r3
else
	SRC_URI="mirror://nongnu/${PN}/${P%_p*}.zip"

	if [[ ${PV} == *_p* ]] ; then
		LWIP_PV=+dfsg1-${PV#*_p}
		SRC_URI+=" mirror://debian/pool/main/l/${PN}/${PN}_${PV%_p*}${LWIP_PV}.debian.tar.xz"
	fi

	KEYWORDS="~amd64 ~x86"
fi

S="${LWIP_POSIX_S}"

LICENSE="BSD"
SLOT="0"

BDEPEND="app-arch/unzip"

src_prepare() {
	cd "${LWIP_BASE_S}" || die

	# The .zips produced by upstream have Windows line-endings, but
	# the Debian patches don't. But always do this for consistency
	# for user patches.
	edos2unix $(find "${LWIP_BASE_S}" -type 'f' || die)

	if [[ ${PV} == *_p* ]] ; then
		eapply $(awk '{print $1}' "${WORKDIR}"/debian/patches/series | sed -e '/^#/d' -e "s:^:${WORKDIR}/debian/patches/:")
	fi

	sed -i -e 's:-Werror::' \
		contrib/ports/CMakeCommon.cmake \
		contrib/ports/Common.allports.mk || die

	cd "${LWIP_POSIX_S}" || die

	cmake_src_prepare
}
