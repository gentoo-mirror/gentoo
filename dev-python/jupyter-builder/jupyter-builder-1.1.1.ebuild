# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi xdg

DESCRIPTION="JupyterLab build tools"
HOMEPAGE="
	https://jupyter.org/
	https://github.com/jupyterlab/jupyter-builder
	https://pypi.org/project/jupyter-builder/
"

LICENSE="BSD MIT ISC"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	!<dev-python/jupyterlab-4.6.0
"

BDEPEND="
	test? (
		dev-python/jinja2-time[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# TODO: package copier
	tests/test_tpl.py
)

distutils_enable_tests pytest

python_prepare_all() {
	distutils-r1_python_prepare_all
	# Disable the copier filterwarning
	sed -e '/copier/d' -i pyproject.toml || die
}
