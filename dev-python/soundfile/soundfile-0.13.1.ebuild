# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="audio library based on libsndfile, CFFI and NumPy"
HOMEPAGE="
	https://pypi.org/project/soundfile/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	media-libs/libsndfile
"

distutils_enable_tests pytest
