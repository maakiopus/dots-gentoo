# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=poetry

inherit python-r1 git-r3

DESCRIPTION="Time tracking and productivity monitoring software"
HOMEPAGE="https://activitywatch.net/"
EGIT_REPO_URI="https://github.com/ActivityWatch/activitywatch.git"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	dev-python/poetry
	dev-lang/rust
	net-libs/nodejs
"

RDEPEND="
	${DEPEND}
"

BDEPEND="
	dev-vcs/git
"

src_unpack() {
	git-r3_src_unpack
	cd "${S}" || die
	git submodule update --init --recursive || die
}

src_prepare() {
	default
	
	# Use system poetry for build
	sed -i 's/python3 -m pip install poetry//' Makefile || die

	# Ensure we're using the right Python version
	sed -i "s/python3/python${EPYTHON#python}/" Makefile || die
}

src_configure() {
	# Ensure we have the right dependencies
	poetry env use "python${EPYTHON#python}" || die
}

src_compile() {
	# Uses poetry and make to build the project
	make build || die
}

src_install() {
	# Create installation directory
	insinto /opt/activitywatch

	# Copy built files
	doins -r dist/activitywatch/* || die

	# Create symlinks for binaries
	dosym /opt/activitywatch/aw-qt /usr/bin/aw-qt
	dosym /opt/activitywatch/aw-server /usr/bin/aw-server
	dosym /opt/activitywatch/aw-watcher-afk /usr/bin/aw-watcher-afk
	dosym /opt/activitywatch/aw-watcher-window /usr/bin/aw-watcher-window

	# Install desktop entry
	domenu "${FILESDIR}"/activitywatch.desktop
}

src_test() {
	# Add testing flags if needed
	make test || die
}

pkg_postinst() {
	elog "ActivityWatch has been installed to /opt/activitywatch"
	elog "You can start it by running 'aw-qt' or through the desktop entry"
}
