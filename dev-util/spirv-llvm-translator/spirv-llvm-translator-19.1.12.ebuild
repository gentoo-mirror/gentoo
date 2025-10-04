# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

HASH_SPIRV="01e0577914a75a2569c846778c2f93aa8e6feddd"
LLVM_COMPAT=( 19 )
MY_PN="SPIRV-LLVM-Translator"
MY_P="${MY_PN}-${PV}"

inherit cmake-multilib flag-o-matic llvm-r2 multiprocessing

DESCRIPTION="Bi-directional translator between SPIR-V and LLVM IR"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-LLVM-Translator"
SRC_URI="
	https://github.com/KhronosGroup/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/KhronosGroup/SPIRV-Headers/archive/${HASH_SPIRV}.tar.gz
		-> spirv-headers-${HASH_SPIRV}.tar.gz
"
S="${WORKDIR}/${MY_P}"

LICENSE="UoI-NCSA"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-util/spirv-tools[${MULTILIB_USEDEP}]
	llvm-core/llvm:${SLOT}=[${MULTILIB_USEDEP}]
"
# We need to use currently newer spirv-headers, as stable release is too old..
# DEPEND="${RDEPEND}
#	>=dev-util/spirv-headers-1.4.313.0
# "
BDEPEND="
	virtual/pkgconfig
	test? (
		dev-python/lit
		llvm-core/clang:${SLOT}
	)
"

src_prepare() {
	append-flags -fPIC
	cmake_src_prepare

	# https://github.com/KhronosGroup/SPIRV-LLVM-Translator/pull/2555
	sed -i -e 's/%triple/x86_64-unknown-linux-gnu/' test/DebugInfo/X86/*.ll || die
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCCACHE_ALLOWED="OFF"
		-DCMAKE_INSTALL_PREFIX="$(get_llvm_prefix)"
		-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR="${WORKDIR}/SPIRV-Headers-${HASH_SPIRV}"
		-DLLVM_SPIRV_INCLUDE_TESTS=$(usex test "ON" "OFF")
		-Wno-dev
	)

	cmake_src_configure
}

multilib_src_test() {
	lit -vv "-j${LIT_JOBS:-$(makeopts_jobs)}" "${BUILD_DIR}/test" || die
}
