# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2 meson optfeature xdg

DESCRIPTION="A graphical, full featured, twin-panel file manager"
HOMEPAGE="https://gnome.pages.gitlab.gnome.org/gnome-commander/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc exif gsf pdf taglib"

RDEPEND="
	doc? ( gnome-extra/yelp )
	>=dev-libs/glib-2.70.0:2
	>=x11-libs/gtk+-3.24.0:3
	exif? ( >=media-gfx/exiv2-0.14:= )
	gsf? ( >=gnome-extra/libgsf-1.12:= )
	gui-libs/vte
	pdf? ( app-text/poppler:=[cairo] )
	taglib? ( >=media-libs/taglib-1.4:= )
	x11-libs/gdk-pixbuf
	!dev-lang/rust-bin:stable
"
BDEPEND="
	doc? ( app-text/yelp-tools )
	dev-util/glib-utils
	dev-build/gtk-doc-am
	app-alternatives/lex
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"
DEPEND="
	${RDEPEND}
"

src_configure() {
	local emesonargs=(
		$(meson_feature exif exiv2)
		$(meson_feature gsf libgsf)
		$(meson_feature pdf poppler)
		$(meson_feature taglib)
		$(meson_use doc help)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_pkg_postinst
	optfeature "synchronizing files and directories" dev-util/meld
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
