# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=BRIANDFOY
DIST_VERSION=1.231
inherit perl-module

DESCRIPTION="Cycle through a list of values via a scalar"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

PERL_RM_FILES=( "t/pod.t" "t/pod_coverage.t" )
