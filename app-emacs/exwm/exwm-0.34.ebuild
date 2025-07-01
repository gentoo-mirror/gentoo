# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NEED_EMACS="27.1"

inherit elisp

DESCRIPTION="Emacs X Window Manager"
HOMEPAGE="https://github.com/emacs-exwm/exwm/"

if [[ "${PV}" == *9999* ]] ; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/emacs-exwm/${PN}"
else
	SRC_URI="https://github.com/emacs-exwm/${PN}/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz"

	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+"
SLOT="0"

BDEPEND="
	>=app-emacs/compat-30.0.0.0
	>=app-emacs/xelb-0.20
"
RDEPEND="
	${BDEPEND}
	x11-apps/xrandr
"

DOCS=( README.md )
SITEFILE="50${PN}-gentoo.el"
