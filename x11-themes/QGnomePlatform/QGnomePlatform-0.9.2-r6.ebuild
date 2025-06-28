# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake flag-o-matic

DESCRIPTION="A Qt Platform Theme aimed to accommodate GNOME settings"
HOMEPAGE="https://github.com/FedoraQt/QGnomePlatform"
SRC_URI="https://github.com/FedoraQt/QGnomePlatform/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"

IUSE="qt5 +qt6 minimal wayland X"
REQUIRED_USE="|| ( qt5 qt6 )"

RDEPEND="
	qt5? (
		dev-qt/qtdbus:5=
		>=dev-qt/qtquickcontrols2-5.15.2:5=
		>=dev-qt/qtwidgets-5.15.2:5=
		!minimal? ( kde-frameworks/qqc2-desktop-style:5= )
		wayland? ( dev-qt/qtwayland:5= )
	)
	qt6? (
		dev-qt/qtbase:6=[dbus,gui,widgets]
		dev-qt/qtdeclarative:6=
		wayland? ( dev-qt/qtwayland:6= )
	)
	gnome-base/gsettings-desktop-schemas
	sys-apps/xdg-desktop-portal
	x11-libs/gtk+:3[wayland?,X?]
	>=x11-themes/adwaita-qt-1.4.2
"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}"

src_prepare() {
	# Fix cmake4 compatibility, bug #958301
	sed -i -e 's/VERSION 3.0/VERSION 3.5/' CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	# avoid automagic dep on src/theme/qgtk3dialoghelpers.cpp
	use X || append-cppflags -DGENTOO_GTK_HIDE_X11
	use wayland || append-cppflags -DGENTOO_GTK_HIDE_WAYLAND

	if use qt5; then
		BUILD_DIR="${WORKDIR}/${PN}_qt5"
		local mycmakeargs=(
			-DUSE_QT6=OFF
			-DDISABLE_DECORATION_SUPPORT="$(usex wayland false true)"
		)
		cmake_src_configure
	fi
	if use qt6; then
		BUILD_DIR="${WORKDIR}/${PN}_qt6"
		local mycmakeargs=(
			-DUSE_QT6=ON
			-DDISABLE_DECORATION_SUPPORT="$(usex wayland false true)"
		)
		cmake_src_configure
	fi
}

src_compile() {
	local _d
	for _d in "${WORKDIR}"/${PN}_qt*; do
		cmake_src_compile -C "${_d}"
	done
}

src_install() {
	local _d
	for _d in "${WORKDIR}"/${PN}_qt*; do
		cmake_src_install -C "${_d}"
	done

	# https://github.com/FedoraQt/QGnomePlatform/pull/150#issuecomment-1689693729
	insinto /etc/profile.d
	doins "${FILESDIR}/90-${PN}.sh"
}
