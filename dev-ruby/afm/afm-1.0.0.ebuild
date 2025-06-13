# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33 ruby34"

RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md"

inherit ruby-fakegem

DESCRIPTION="A very simple library to read Adobe Font Metrics files"
HOMEPAGE="https://github.com/halfbyte/afm"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="test"

all_ruby_prepare() {
	sed -i -e "/[Bb]undler/s/^/#/" Rakefile test/helper.rb || die
}

each_ruby_test() {
	${RUBY} -Ilib:test test/test_afm.rb || die
}
