# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker eapi9-ver

DESCRIPTION="A collection of tools and scripts"
HOMEPAGE="https://inai.de/projects/hxtools/"
SRC_URI="https://inai.de/files/${PN}/${P}.tar.zst"

LICENSE="BSD-2-with-patent GPL-2+ GPL-3 LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="
	>=sys-apps/pciutils-3
	>=sys-apps/util-linux-2.19
	>=sys-libs/libhx-5.1:=
	dev-lang/perl
	sys-libs/libcap:=
	x11-libs/libxcb:0=
"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}
	$(unpacker_src_uri_depends)
	virtual/pkgconfig
"

src_prepare() {
	default

	# Don't collide with dev-util/cwdiff
	sed -i -e 's/cwdiff/cwdiff.hx/' doc/cwdiff.1 || die
}

src_configure() {
	# Gentoo doesn't have /usr/share/kbd
	econf --with-kbddatadir="${EPREFIX}"/usr/share
}

src_install() {
	default

	# man2html is provided by man
	rm -r "${ED}"/usr/bin/man2html || die
	rm -r "${ED}"/usr/share/man/man1/man2html* || die

	# Don't collide with dev-util/cwdiff
	mv "${ED}"/usr/bin/cwdiff "${ED}"/usr/bin/cwdiff.hx || die
	mv "${ED}"/usr/share/man/man1/cwdiff.1 "${ED}"/usr/share/man/man1/cwdiff.hx.1 || die

	gzip -r "${ED}"/usr/share/consolefonts || die
	gzip -r "${ED}"/usr/share/keymaps || die
}

pkg_postinst() {
	if ver_replacing -lt 20251011; then
		elog "vfontas has moved to package app-misc/consoleet-utils"
	fi
}
