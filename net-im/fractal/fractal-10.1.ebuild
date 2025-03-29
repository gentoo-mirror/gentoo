# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

RUST_MIN_VER="1.82.0"

inherit cargo gnome2-utils meson

MY_P=${P/_/.}
CRATE_P=fractal-${PV}

DESCRIPTION="Matrix messaging app for GNOME written in Rust"
HOMEPAGE="
	https://wiki.gnome.org/Apps/Fractal
	https://gitlab.gnome.org/World/fractal/
"
SRC_URI="
	https://gitlab.gnome.org/World/fractal/-/archive/${PV/_/.}/${MY_P}.tar.bz2
	${CARGO_CRATE_URIS}
"
if [[ ${PKGBUMPING} != ${PVR} ]]; then
	SRC_URI+="
		https://github.com/gentoo-crate-dist/fractal/releases/download/${PV}/${CRATE_P}-crates.tar.xz
	"
fi
S=${WORKDIR}/${MY_P}

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	GPL-3+ ISC MIT MPL-2.0 MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	>=dev-libs/glib-2.82
	>=gui-libs/gtk-4.16:4
	>=gui-libs/libadwaita-1.6:1

	>=media-libs/gstreamer-1.20:1.0
	>=media-libs/gst-plugins-bad-1.20:1.0
	>=media-libs/gst-plugins-base-1.20:1.0

	>=gui-libs/gtksourceview-5.0.0:5
	>=media-libs/libwebp-1.0.0:=
	>=dev-libs/openssl-1.0.1:=
	>=media-libs/libshumate-1.2:1.0
	>=dev-db/sqlite-3.24.0:3
	>=sys-apps/xdg-desktop-portal-1.14.1

	>=media-libs/lcms-2.12.0:2
	>=sys-libs/libseccomp-2.5.0:=

"
RDEPEND="
	${DEPEND}
	media-libs/glycin-loaders
	media-plugins/gst-plugin-gtk4
	virtual/secret-service
"
# clang needed by bindgen
BDEPEND="
	llvm-core/clang
	dev-lang/grass
"

# Rust
QA_FLAGS_IGNORED="usr/bin/fractal"

src_prepare() {
	default

	# upstream dev settings are insane
	sed -i -e 's:profile\.dev:ignored.insanity:' Cargo.toml || die
}

src_configure() {
	local mymesonargs=(
		#-Ddisable-glycin-sandbox=true
	)

	meson_src_configure
	ln -s "${CARGO_HOME}" "${BUILD_DIR}/cargo-home" || die
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_desktop_database_update
	xdg_icon_cache_update
}
