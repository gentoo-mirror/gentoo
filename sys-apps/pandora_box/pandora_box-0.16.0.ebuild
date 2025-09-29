# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

IUSE="static"

RUST_MIN_VER="1.83.0"

CRATES="
	ahash@0.8.12
	autocfg@1.5.0
	bitflags@2.9.4
	block-buffer@0.10.4
	btoi@0.5.0
	bumpalo@3.19.0
	cfg-if@1.0.3
	cfg_aliases@0.2.1
	console@0.16.1
	cpufeatures@0.2.17
	crc-catalog@2.4.0
	crc@3.3.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crypto-common@0.1.6
	data-encoding@2.9.0
	digest@0.10.7
	either@1.15.0
	encode_unicode@1.0.0
	equivalent@1.0.2
	errno@0.3.14
	fastrand@2.3.0
	generic-array@0.14.7
	getrandom@0.3.3
	hashbrown@0.16.0
	hermit-abi@0.5.2
	indexmap@2.11.4
	indicatif@0.18.0
	itoa@1.0.15
	js-sys@0.3.81
	keccak@0.1.5
	lexopt@0.3.1
	libc@0.2.176
	linux-raw-sys@0.11.0
	log@0.4.28
	md5@0.8.0
	memchr@2.7.6
	memoffset@0.9.1
	nix@0.30.1
	num-traits@0.2.19
	num_cpus@1.17.0
	once_cell@1.21.3
	patricia_tree@0.8.0
	portable-atomic@1.11.1
	proc-macro2@1.0.101
	quote@1.0.41
	r-efi@5.3.0
	rayon-core@1.13.0
	rayon@1.11.0
	rustix@1.1.2
	rustversion@1.0.22
	ryu@1.0.20
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.145
	sha1@0.10.6
	sha3@0.10.8
	syn@2.0.106
	tempfile@3.23.0
	typenum@1.18.0
	unicode-ident@1.0.19
	unicode-width@0.2.1
	unit-prefix@0.5.1
	version_check@0.9.5
	wasi@0.14.7+wasi-0.2.4
	wasip2@1.0.1+wasi-0.2.4
	wasm-bindgen-backend@0.2.104
	wasm-bindgen-macro-support@0.2.104
	wasm-bindgen-macro@0.2.104
	wasm-bindgen-shared@0.2.104
	wasm-bindgen@0.2.104
	web-time@1.1.0
	windows-link@0.2.0
	windows-sys@0.61.1
	wit-bindgen@0.46.0
	zerocopy-derive@0.8.27
	zerocopy@0.8.27
"

inherit cargo

DESCRIPTION="Syd's log inspector & profile writer"
HOMEPAGE="https://man.exherbolinux.org"

SRC_URI="https://git.sr.ht/~alip/syd/archive/pandora-${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}/syd-pandora-${PV}/pandora"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD CC0-1.0 GPL-2
	ISC MIT MPL-2.0 Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="~amd64"

src_configure() {
	if use static; then
		export RUSTFLAGS+="-Ctarget-feature=+crt-static"
	fi
	cargo_src_configure
}
