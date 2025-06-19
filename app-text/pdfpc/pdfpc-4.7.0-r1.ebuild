# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VALA_MAX_API_VERSION="0.56" # append versions in sed line if increased

#COMMIT_ID=""

inherit cmake vala

DESCRIPTION="Presenter console with multi-monitor support for PDF files"
HOMEPAGE="https://pdfpc.github.io https://github.com/pdfpc/pdfpc"

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
	inherit git-r3
elif [[ ${PV} == *_p* ]]; then
	SRC_URI="https://github.com/${PN}/${PN}/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${COMMIT_ID}"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="X +gstreamer soup wayland webkit"

RDEPEND="
	app-text/discount:=
	app-text/poppler:=[cairo]
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8=
	gnome-base/librsvg
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/libX11
	x11-libs/pango
	x11-libs/gtk+:3[X?,wayland?]
	!X? ( !wayland? ( x11-libs/gtk+:3[X] ) )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		media-libs/gst-plugins-good:1.0
		media-plugins/gst-plugins-gtk:1.0=
		media-plugins/gst-plugins-cairo:1.0=
	)
	soup? (
		media-gfx/qrencode
		net-libs/libsoup:3.0
	)
	webkit? ( net-libs/webkit-gtk:4.1= )
"
DEPEND="${RDEPEND}"
BDEPEND="$(vala_depend)"

DOCS=(
	CHANGELOG.rst
	FAQ.rst
	README.rst
	SUPPORT.rst
)

src_prepare() {
	if ! use wayland; then  #958395
		sed -i -e 's/GDK_WINDOWING_WAYLAND/GdK_nO_wAyLaNd/' \
			src/display_backend.c || die
	elif ! use X; then
		sed -i -e 's/GDK_WINDOWING_X11/GdK_nO_xElEvEn/' \
			src/display_backend.c || die
	fi

	cmake_src_prepare
	vala_setup
	sed -i -e "/find_program/s/valac/& &-0.56 &-0.54 &-0.52 &-0.50/" \
		cmake/vala/FindVala.cmake || die
}

src_configure() {
	local mycmakeargs=(
		-DMOVIES=$(usex gstreamer on off)
		-DREST=$(usex soup on off)
		-DMDVIEW=$(usex webkit on off)
		-DCMAKE_VERBOSE_MAKEFILE=TRUE
	)
	cmake_src_configure
}
