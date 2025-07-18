# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="CU / ROCM agnostic hip FFT implementation"
HOMEPAGE="https://github.com/ROCm/hipFFT"
SRC_URI="https://github.com/ROCm/hipFFT/archive/refs/tags/rocm-${PV}.tar.gz -> hipFFT-rocm-${PV}.tar.gz"
S="${WORKDIR}/hipFFT-rocm-${PV}"

REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

RESTRICT="test"

RDEPEND="dev-util/hip
	sci-libs/rocFFT:${SLOT}"
DEPEND="${RDEPEND}"

src_configure() {
	# Note: hipcc is enforced; clang fails when libc++ is enabled
	# with an error similar to https://github.com/boostorg/config/issues/392
	rocm_use_hipcc

	local mycmakeargs=(
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_RIDER=OFF
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
	)

	cmake_src_configure
}
