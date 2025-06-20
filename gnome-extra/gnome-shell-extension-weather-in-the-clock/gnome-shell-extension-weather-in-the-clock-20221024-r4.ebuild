# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit gnome2-utils

DESCRIPTION="Display the current weather in the clock"
HOMEPAGE="https://github.com/JasonLG1979/gnome-shell-extension-weather-in-the-clock"
COMMIT="38ba36090961a37260215ae04f4a7e0a1377da95"
SRC_URI="https://github.com/JasonLG1979/gnome-shell-extension-weather-in-the-clock/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="
	app-eselect/eselect-gnome-shell-extensions
	>=gnome-base/gnome-shell-45
	gnome-extra/gnome-weather
"

extension_uuid="weatherintheclock@JasonLG1979.github.io"

PATCHES=(
	# https://github.com/JasonLG1979/gnome-shell-extension-weather-in-the-clock/pull/32
	"${FILESDIR}/${PN}-gnome-47.patch"
)

src_compile() { :; }

src_install() {
	einstalldocs
	insinto /usr/share/gnome-shell/extensions/
	doins -r "${extension_uuid}"
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}

pkg_postrm() {
	gnome2_schemas_update
}
