# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

# tests not enabled because of missing eclass support of junit-jupiter
JAVA_PKG_IUSE="doc source"

# Avoid circular dependency
JAVA_DISABLE_DEPEND_ON_JAVA_DEP_CHECK="true"

inherit java-pkg-2 java-pkg-simple

MY_P="ASM_${PV//./_}"

DESCRIPTION="Bytecode manipulation framework for Java"
HOMEPAGE="https://asm.ow2.io"
SRC_URI="https://gitlab.ow2.org/asm/asm/-/archive/${MY_P}/asm-${MY_P}.tar.bz2"
S="${WORKDIR}/asm-${MY_P}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x64-macos"

DEPEND=">=virtual/jdk-11:*"
RDEPEND=">=virtual/jre-1.8:*"

ASM_MODULES=( "asm" "asm-tree" "asm-analysis" "asm-commons" "asm-util" )
JAVADOC_SRC_DIRS=( asm{-analysis,-commons,,-tree,-util}/src/main/java )

src_compile() {
	local module
	for module in "${ASM_MODULES[@]}"; do
		einfo "Compiling ${module}"
		JAVA_GENTOO_CLASSPATH_EXTRA+=":${module}.jar"
		JAVA_INTERMEDIATE_JAR_NAME="org.objectweb.${module/-/.}"
		JAVA_JAR_FILENAME="${module}.jar"
		JAVA_MODULE_INFO_OUT="${module}/src/main"
		JAVA_MODULE_INFO_RELEASE=9
		JAVA_SRC_DIR="${module}/src/main/java"
		java-pkg-simple_src_compile
		rm -r target || die
	done

	use doc && ejavadoc
}

src_install() {
	JAVA_JAR_FILENAME="asm.jar"
	java-pkg-simple_src_install
	local module
	for module in asm-{analysis,commons,tree,util}; do
		java-pkg_dojar ${module}.jar
		if use source; then
			java-pkg_dosrc "${module}/src/main/java/*"
		fi
	done
}
