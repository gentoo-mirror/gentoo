# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_TEST="forceoptional"
KFMIN=6.9.0
QTMIN=6.8.1
KDE_ORG_COMMIT=10aad738194d675ac4cfcde62097938e6921d25e
inherit ecm kde.org xdg

DESCRIPTION="Text-based subtitles editor"
HOMEPAGE="https://subtitlecomposer.kde.org/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="unicode"

DEPEND="
	dev-libs/openssl:=
	>=dev-qt/qt5compat-${QTMIN}:6
	>=dev-qt/qtbase-${QTMIN}:6[gui,network,opengl,widgets]
	>=dev-qt/qtdeclarative-${QTMIN}:6
	>=kde-frameworks/kcodecs-${KFMIN}:6
	>=kde-frameworks/kcompletion-${KFMIN}:6
	>=kde-frameworks/kconfig-${KFMIN}:6
	>=kde-frameworks/kconfigwidgets-${KFMIN}:6
	>=kde-frameworks/kcoreaddons-${KFMIN}:6
	>=kde-frameworks/ki18n-${KFMIN}:6
	>=kde-frameworks/kio-${KFMIN}:6
	>=kde-frameworks/ktextwidgets-${KFMIN}:6
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:6
	>=kde-frameworks/kxmlgui-${KFMIN}:6
	>=kde-frameworks/sonnet-${KFMIN}:6
	media-libs/openal
	>=media-video/ffmpeg-5.1.5:0=
	unicode? ( dev-libs/icu:= )
"
RDEPEND="${DEPEND}
	!${CATEGORY}/${PN}:5
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

# TODO: downstream workaround, push upstream?
PATCHES=( "${FILESDIR}/${P}-force-xcb-platform.patch" )

src_configure() {
	local mycmakeargs=(
		-DQT_MAJOR_VERSION=6
		-DCMAKE_DISABLE_FIND_PACKAGE_PocketSphinx=ON # bugs 616706, 610434
		$(cmake_use_find_package unicode ICU)
	)

	ecm_src_configure
}
