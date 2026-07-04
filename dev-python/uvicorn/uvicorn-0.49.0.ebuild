# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYPI_VERIFY_REPO=https://github.com/Kludex/uvicorn
PYTHON_TESTED=( python3_{12..14} )
PYTHON_COMPAT=( "${PYTHON_TESTED[@]}" python3_15 )

inherit distutils-r1 optfeature pypi

DESCRIPTION="Lightning-fast ASGI server implementation"
HOMEPAGE="
	https://uvicorn.dev/
	https://github.com/Kludex/uvicorn/
	https://pypi.org/project/uvicorn/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="test test-rust"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-python/asgiref-3.4.0[${PYTHON_USEDEP}]
	>=dev-python/click-7.0[${PYTHON_USEDEP}]
	>=dev-python/h11-0.8[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		$(python_gen_cond_dep '
			dev-python/a2wsgi[${PYTHON_USEDEP}]
			dev-python/anyio[${PYTHON_USEDEP}]
			>=dev-python/httptools-0.8.0[${PYTHON_USEDEP}]
			>=dev-python/httpx-0.28[${PYTHON_USEDEP}]
			dev-python/pytest[${PYTHON_USEDEP}]
			dev-python/pytest-mock[${PYTHON_USEDEP}]
			dev-python/pytest-rerunfailures[${PYTHON_USEDEP}]
			dev-python/pytest-xdist[${PYTHON_USEDEP}]
			dev-python/python-dotenv[${PYTHON_USEDEP}]
			dev-python/pyyaml[${PYTHON_USEDEP}]
			dev-python/typing-extensions[${PYTHON_USEDEP}]
			>=dev-python/websockets-10.4[${PYTHON_USEDEP}]
			dev-python/wsproto[${PYTHON_USEDEP}]
			test-rust? (
				dev-python/cryptography[${PYTHON_USEDEP}]
				dev-python/trustme[${PYTHON_USEDEP}]
				>=dev-python/watchfiles-0.20[${PYTHON_USEDEP}]
			)
		' "${PYTHON_TESTED[@]}")
	)
"

python_test() {
	if ! has "${EPYTHON/./_}" "${PYTHON_TESTED[@]}"; then
		einfo "Skipping tests on ${EPYTHON}"
		return
	fi

	local EPYTEST_PLUGINS=( anyio pytest-mock )
	local EPYTEST_RERUNS=5
	local EPYTEST_XDIST=1

	local EPYTEST_IGNORE=(
		tests/benchmarks
	)
	local EPYTEST_DESELECT=(
		# too long path for unix socket
		tests/test_config.py::test_bind_unix_socket_works_with_reload_or_workers
		# TODO
		'tests/protocols/test_http.py::test_close_connection_with_multiple_requests[httptools]'
		'tests/protocols/test_websocket.py::test_send_binary_data_to_server_bigger_than_default_on_websockets[httptools-max=defaults sent=defaults+1]'
		'tests/protocols/test_websocket.py::test_send_binary_data_to_server_bigger_than_default_on_websockets[h11-max=defaults sent=defaults+1]'
		# tests broken with non-ancient dev-python/websockets
		tests/protocols/test_websocket.py::test_fragmented_message_exceeding_max_size
		tests/protocols/test_websocket.py::test_fragmented_message_reassembly
	)

	epytest
}

pkg_postinst() {
	optfeature "auto reload on file changes" dev-python/watchfiles
}
