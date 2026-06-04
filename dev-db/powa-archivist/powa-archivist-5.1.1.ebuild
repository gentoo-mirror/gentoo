# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

POSTGRES_COMPAT=( 14 15 16 17 18 )
POSTGRES_USEDEP="server"

inherit optfeature postgres-multi

DESCRIPTION="PostgreSQL Workload Analyzer Archivist"
HOMEPAGE="https://github.com/powa-team/powa-archivist"
SRC_URI="https://github.com/powa-team/${PN}/archive/refs/tags/REL_5_1_1.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-REL_${PV//./_}"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="test"

src_install() {
	default
}

pkg_postinst() {
	optfeature "suggesting new hypothetical indexes." dev-db/hypopg
	optfeature "keeping statistics on predicates." dev-db/pg_qualstats
	optfeature "gathering statistics on system metrics." dev-db/pg_stat_kcache
	optfeature "keeping track of configuration changes." dev-db/pg_track_settings
	optfeature "sampling wait_events of all queries executed." dev-db/pg_wait_sampling
}
