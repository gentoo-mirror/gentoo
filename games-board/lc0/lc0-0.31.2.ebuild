# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Neural-network chess engine"
HOMEPAGE="https://github.com/LeelaChessZero/lc0/"
SRC_URI="https://github.com/LeelaChessZero/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/LeelaChessZero/lczero-common/archive/c47d3683972d9ef293b0c0bc7675f7c2c5ce2274.tar.gz -> ${PN}-common-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="blas dnnl ispc onnx opencl test"

RDEPEND="dev-cpp/eigen
	dev-cpp/gtest
	blas? ( sci-libs/openblas )
	opencl? ( virtual/opencl )
	ispc? ( dev-lang/ispc )
	dnnl? ( sci-ml/oneDNN )
	"
DEPEND="${RDEPEND}"

RESTRICT="!test? ( test )"

src_prepare() {
	cp -r "${WORKDIR}/lczero-common-c47d3683972d9ef293b0c0bc7675f7c2c5ce2274/proto" "${S}/libs/lczero-common/" || die
	eapply_user
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use ispc ispc)
		$(meson_use dnnl dnnl)
		$(meson_use opencl opencl)
		)
	meson_src_configure
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}-build/lc0" "${D}/usr/bin" || die

	default
}
