# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="A rewrite of Python's builtin doctest module but without all the weirdness"
HOMEPAGE="
	https://github.com/Erotemic/xdoctest/
	https://pypi.org/project/xdoctest/
"
SRC_URI="
	https://github.com/Erotemic/xdoctest/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/pytest[${PYTHON_USEDEP}]
"
# dev-python/nbformat-5.1.{0..2} did not install package data
BDEPEND="
	test? (
		>=dev-python/nbformat-5.1.2-r1[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGIN_LOAD_VIA_ENV=1
EPYTEST_PLUGINS=( "${PN}" )
EPYTEST_XDIST=1
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# broken by PYTEST_PLUGINS
		tests/test_plugin.py::TestXDoctestActivation::test_xdoctest_explicit_suppression
		tests/test_pytest_cli.py::test_simple_pytest_import_error_cli
	)

	epytest --pyargs tests xdoctest
}
