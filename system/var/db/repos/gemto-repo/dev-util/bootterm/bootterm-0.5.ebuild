# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Maintainer: Popolon <popolon@popolon.org>

EAPI=8

DESCRIPTION="Simple, reliable and powerful terminal designed to ease connection to ephemeral serial ports"
HOMEPAGE="https://github.com/wtarreau/bootterm/"
SRC_URI="https://github.com/wtarreau/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

DEPEND="virtual/libc"
RDEPEND="${DEPEND}"
BDEPEND="dev-build/make"

src_compile() {
    emake V=1 CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
    emake install DESTDIR="${D}" PREFIX="/usr"
}
