# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=AUTRIJUS
DIST_VERSION=0.07
inherit perl-module

DESCRIPTION="Encode.pm emulation layer"

SLOT="0"
KEYWORDS="amd64 ~loong ~ppc sparc x86"

RDEPEND="dev-perl/Text-Iconv"
BDEPEND="${RDEPEND}"
