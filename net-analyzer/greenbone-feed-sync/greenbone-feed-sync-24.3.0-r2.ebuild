# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} pypy3_11 )
DISTUTILS_USE_PEP517=poetry
inherit distutils-r1 systemd

DESCRIPTION="New script for syncing the Greenbone Community Feed"
HOMEPAGE="https://github.com/greenbone/greenbone-feed-sync"
SRC_URI="https://github.com/greenbone/greenbone-feed-sync/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64"
IUSE="cron"

COMMON_DEPEND="
	acct-user/gvm
	net-misc/rsync
	>=net-analyzer/gvmd-22.5.0
	>=dev-python/rich-13.2.0[${PYTHON_USEDEP}]
	>=dev-python/shtab-1.7.0[${PYTHON_USEDEP}]
"
DEPEND="
	${COMMON_DEPEND}
	test? ( >=net-analyzer/pontos-22.12.2[${PYTHON_USEDEP}] )
"
RDEPEND="
	${COMMON_DEPEND}
	cron? ( virtual/cron )
"

distutils_enable_tests unittest

src_test() {
	# Make a copy of the original config
	cp greenbone/feed/sync/config.py "${T}"/config.py.orig || die

	# Patch the config.py to not use files from /etc/gvm, as this may
	# cause a PermissionError. See https://bugs.gentoo.org/932836#c10
	sed -i \
		-e 's:DEFAULT_CONFIG_FILE = "/etc/gvm/greenbone-feed-sync.toml":DEFAULT_CONFIG_FILE = "'"${WORKDIR}/${P}-${TARGET}"'/install/etc/gvm/greenbone-feed-sync.toml":' \
		-e 's:DEFAULT_ENTERPRISE_KEY_PATH = "/etc/gvm/greenbone-enterprise-feed-key":DEFAULT_ENTERPRISE_KEY_PATH = "'"${WORKDIR}/${P}-${TARGET}"'/install/etc/gvm/greenbone-enterprise-feed-key":' \
		greenbone/feed/sync/config.py || die

	# Disable tests that require network access.
	sed -i \
		-e 's:test_do_not_run_as_root:_&:' \
		-e 's:test_sync_nvts:_&:' \
		-e 's:test_sync_nvts_quiet:_&:' \
		-e 's:test_sync_nvts_rsync_error:_&:' \
		-e 's:test_sync_nvts_verbose:_&:' \
		-e 's:test_sync_nvts:_&:' \
		-e 's:test_sync_nvts_error:_&:' \
			tests/test_main.py || die

	distutils-r1_src_test

	# Restore config.py after test.
	mv "${T}"/config.py.orig greenbone/feed/sync/config.py || die
}

python_install() {
	distutils-r1_python_install

	# greenbone-feed-sync should not be run as root to avoid changing file permissions
	insinto /etc/sudoers.d
	newins - greenbone-feed-sync <<-EOF
	gvm ALL = NOPASSWD: /usr/bin/greenbone-feed-sync
	EOF

	fperms 0750 /etc/sudoers.d
	fperms 0440 /etc/sudoers.d/greenbone-feed-sync

	if use cron; then
		exeinto /etc/cron.daily
		newexe "${FILESDIR}"/${PN}.cron ${PN}
	fi

	systemd_dounit "${FILESDIR}/${PN}.timer" "${FILESDIR}/${PN}.service"
}

pkg_postinst() {
	if [[ -n ${REPLACING_VERSIONS} ]]; then
		return
	fi

	if use cron; then
		elog
		elog "Edit ${EROOT}/etc/cron.weekly/greenbone-feed-sync to activate daily feed update!"
		elog
	fi

	if systemd_is_booted; then
		elog
		elog "To enable the systemd timer, run the following command:"
		elog "   systemctl enable --now greenbone-feed-sync.timer"
		elog
	fi
}
