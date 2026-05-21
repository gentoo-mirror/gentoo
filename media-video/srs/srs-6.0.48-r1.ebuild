# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Simple Realtime media Server"
HOMEPAGE="https://ossrs.io/"
SRC_URI="https://github.com/ossrs/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}"/${P}

LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="srt"

DEPEND="
	dev-libs/openssl:0=
	media-video/ffmpeg:=
	srt? ( net-libs/srt:= )
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-cmake.patch
	"${FILESDIR}"/${P}-configure.patch
	"${FILESDIR}"/${P}-execStack.patch
	"${FILESDIR}"/${P}-fixAliasing.patch
	"${FILESDIR}"/${P}-LDFLAGS.patch
)

src_prepare() {
	cd trunk
	default
}

src_configure() {
	cd trunk
	local myconf=(
		--cxx="$(tc-getCXX)"
		--config=/etc/srs/
		--ffmpeg-fit=off
		--generic-linux=on
		--https=off
		--nasm=off
		--prefix="${EPREFIX}/"
		--rtc=off
		--sanitizer=off
		--sys-ssl=on
		--srt=$(usex srt on off)
		--shared-srt=$(usex srt on off)
	)

	./configure "${myconf[@]}" || die
}

src_compile() {
	cd trunk
	# Build libst.a
	emake -C 3rdparty/st-srs \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		EXTRA_CFLAGS="${CFLAGS} -DMALLOC_STACK" \
		linux-debug
	cp 3rdparty/st-srs/obj/{st.h,libst.a} objs/st

	default
}

src_install() {
	einstalldocs

	cd trunk
	# Install executable
	newbin objs/srs srs-media

	# Install configuration file
	insinto /usr/share/srs/conf
	doins conf/*.conf

	# Install the Web files
	insinto /usr/share/srs/html
	doins -r objs/nginx/html/*

	newinitd "${FILESDIR}"/init.d srs
	newconfd "${FILESDIR}"/conf.d srs

	insinto /etc/srs
	doins "${FILESDIR}"/srs.conf
}
