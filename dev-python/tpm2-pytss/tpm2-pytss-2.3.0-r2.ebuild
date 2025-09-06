# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python bindings for TSS"
HOMEPAGE="
	https://pypi.org/project/tpm2-pytss/
	https://github.com/tpm2-software/tpm2-pytss/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+fapi test"

DEPEND="
	app-crypt/tpm2-tss:=[fapi=]
	fapi? ( >=app-crypt/tpm2-tss-3.0.3:= )
	test? ( app-crypt/swtpm )
"
RDEPEND="${DEPEND}
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/asn1crypto[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pycparser[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/pkgconfig[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/${PN}-2.3.0-preprocess-as-C99.patch"
	"${FILESDIR}/${PN}-2.3.0-use-CC-enviromental-variable.patch"
	# https://github.com/tpm2-software/tpm2-pytss/pull/643
	"${FILESDIR}/${P}-cryptography-45.patch"
)

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=()
EPYTEST_XDIST=1
distutils_enable_tests pytest
