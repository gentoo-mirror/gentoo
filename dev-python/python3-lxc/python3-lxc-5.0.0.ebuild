# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 verify-sig

DESCRIPTION="Python bindings for LXC"
HOMEPAGE="https://linuxcontainers.org/lxc/"
SRC_URI="https://linuxcontainers.org/downloads/lxc/${P}.tar.gz
	verify-sig? ( https://linuxcontainers.org/downloads/lxc/${P}.tar.gz.asc )"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
IUSE="verify-sig"

DEPEND="app-containers/lxc:="
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig
	verify-sig? ( sec-keys/openpgp-keys-linuxcontainers )"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/linuxcontainers.asc
