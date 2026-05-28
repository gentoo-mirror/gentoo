# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 cmake

COMMIT="ab7d6bbf90af6f63898d3c2e45cd36da50b4f40b"

DESCRIPTION="Raspberry Pi userspace utilities"
HOMEPAGE="https://github.com/raspberrypi/utils"
SRC_URI="https://github.com/raspberrypi/utils/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/utils-${COMMIT}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm ~arm64"

DEPEND="
	sys-apps/dtc
"

RDEPEND="
	${DEPEND}
	dev-lang/perl
	!media-libs/raspberrypi-userland
	!media-libs/raspberrypi-userland-bin
"

src_configure() {
	local mycmakeargs=( -DBUILD_SHARED_LIBS=OFF -DENABLE_WERROR=OFF )
	cmake_src_configure
}

src_install() {
	cmake_src_install

	local SRC
	rm -r "${ED}"/usr/share/bash-completion/ || die
	for SRC in */*-completion.bash; do
		local DEST=${SRC%-completion.bash}
		newbashcomp "${SRC}" "${DEST##*/}"
	done
}
