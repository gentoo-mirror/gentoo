# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_OPTIONAL=yes

inherit distutils-r1 flag-o-matic toolchain-funcs virtualx

DESCRIPTION="The Snack Sound Toolkit (Tcl)"
HOMEPAGE="http://www.speech.kth.se/snack/"
SRC_URI="http://www.speech.kth.se/snack/dist/${PN}${PV}.tar.gz"
S="${WORKDIR}/${PN}${PV}/unix"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~hppa ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="alsa examples python vorbis"

RESTRICT="!test? ( test )"

DEPEND="
	dev-lang/tcl:0=
	dev-lang/tk:0=
	alsa? ( media-libs/alsa-lib )
	python? ( ${PYTHON_DEPS} )
	vorbis? ( media-libs/libvorbis )
"
RDEPEND="${DEPEND}"
BDEPEND="
	python? (
		${PYTHON_DEPS}
		${DISTUTILS_DEPS}
	)
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}"/alsa-undef-sym.patch
	"${FILESDIR}"/${P}-CVE-2012-6303-fix.patch
	"${FILESDIR}"/${P}-debian-args.patch
	"${FILESDIR}"/${P}-test.patch
	"${FILESDIR}"/${PN}${PV}-seektell-fix.patch
	"${FILESDIR}"/tcl-${P}-python3.patch
	"${FILESDIR}"/${P}-lto.patch
	"${FILESDIR}"/${P}-configure-clang16.patch
	"${FILESDIR}"/${P}-implicit.patch
	"${FILESDIR}"/${P}-parallelMake.patch
	"${FILESDIR}"/${P}-py3.8.patch
)

HTML_DOCS="${WORKDIR}/${PN}${PV}/doc/*"

src_prepare() {
	# adds -install_name (soname on Darwin)
	[[ ${CHOST} == *-darwin* ]] && PATCHES+=( "${FILESDIR}"/${P}-darwin.patch )

	# For Clang 16, bunch of -Wimplicit-int, etc
	append-flags -std=gnu89

	sed \
		-e "s:ar cr:$(tc-getAR) cr:g" \
		-e "s|-O|${CFLAGS}|g" \
		-i Makefile.in || die

	cd .. || die

	default

	sed \
		-e 's|^\(#define roundf(.*\)|//\1|' \
		-i generic/jkFormatMP3.c || die
	rm tests/{play,record}.test || die
	if use python; then
		cd python || die
		distutils-r1_src_prepare
	fi
}

src_configure() {
	local myconf=""

	use alsa && myconf+=" --enable-alsa"

	if use vorbis; then
		myconf+=" --with-ogg-include="${EPREFIX}"/usr/include"
		myconf+=" --with-ogg-lib="${EPREFIX}"/usr/$(get_libdir)"
	fi

	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--includedir="${EPREFIX}"/usr/include \
		--with-tcl="${EPREFIX}"/usr/$(get_libdir) \
		--with-tk="${EPREFIX}"/usr/$(get_libdir) \
		${myconf}

	if use python; then
		cd ../python || die
		distutils-r1_src_configure
	fi
}

src_compile() {
	default
	if use python; then
		cd ../python || die
		distutils-r1_src_compile
	fi
}

src_test() {
	TCLLIBPATH=${S} virtx default | tee snack.testResult
	grep -q FAILED snack.testResult && die
}

src_install() {
	default

	if use python ; then
		cd "${S}"/../python || die
		distutils-r1_src_install
	fi

	cd "${S}"/.. || die

	if use examples ; then
		docinto examples
		sed -i -e 's/wish[0-9.]+/wish/g' demos/tcl/* || die
		dodoc -r demos/tcl

		use python && dodoc -r demos/python
	fi
}
