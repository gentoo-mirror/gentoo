# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit edo flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Light-weight X11 desktop panel"
HOMEPAGE="https://aanatoly.github.io/fbpanel/"
SRC_URI="https://github.com/aanatoly/fbpanel/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT LGPL-2+ GPL-2+"	# bug #795591
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~mips ppc ppc64 x86"
IUSE="alsa"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/libX11
	alsa? ( media-libs/alsa-lib )
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-6.1-underlinking.patch
	"${FILESDIR}"/${PN}-7.0-clang.patch
	"${FILESDIR}"/${PN}-7.0-fno-common.patch
	"${FILESDIR}"/${PN}-7.0-images.patch
	"${FILESDIR}"/${PN}-7.0-python3-shebangs.patch
	"${FILESDIR}"/${PN}-7.0-remove-gdk-pixbuf-xlib.h.patch
	"${FILESDIR}"/${PN}-7.0-python3.10.patch
	"${FILESDIR}"/${PN}-7.0-2to3.patch
)

src_configure() {
	tc-export CC
	append-cflags -std=gnu17

	# not autotools based
	local confargs=(
		V=1
		--mandir="${EPREFIX}"/usr/share/man/man1
		--datadir="${EPREFIX}"/usr/share/${PN}
		--prefix="${EPREFIX}"/usr
		--libdir="${EPREFIX}"/usr/$(get_libdir)/${PN}
		$(usex alsa --sound --no-sound)
	)

	edo ./configure "${confargs[@]}"
}

pkg_postinst() {
	elog "For the volume plugin to work, you need to configure your kernel"
	elog "with CONFIG_SND_MIXER_OSS or CONFIG_SOUND_PRIME or some other means"
	elog "that provide the /dev/mixer device node."
}
