# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The E16 online help"
HOMEPAGE="https://www.enlightenment.org https://sourceforge.net/projects/enlightenment/"
SRC_URI="https://downloads.sourceforge.net/enlightenment/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~riscv x86"

RDEPEND="!app-doc/edox-data"
