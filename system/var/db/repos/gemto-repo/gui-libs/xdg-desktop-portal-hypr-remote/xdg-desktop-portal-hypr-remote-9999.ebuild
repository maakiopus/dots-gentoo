# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Remote desktop portal implementation for Hyprland using libei and Wayland protocols"
HOMEPAGE="https://github.com/gac3k/xdg-desktop-portal-hypr-remote"
SRC_URI=""
EGIT_REPO_URI="https://github.com/gac3k/xdg-desktop-portal-hypr-remote.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

# Build-time and runtime dependencies
DEPEND="
    dev-build/cmake
    dev-util/pkgconf
    sys-devel/gcc
    dev-libs/wayland
    dev-libs/wayland-protocols
    dev-libs/libei
    dev-cpp/sdbus-c++
    sys-apps/systemd
"
RDEPEND="${DEPEND}"

inherit git-r3 cmake

src_configure() {
    cmake_src_configure
}

src_compile() {
    cmake_src_compile
}

src_install() {
    # Install the compiled binary
    dobin "${BUILD_DIR}/xdg-desktop-portal-hypr-remote"

    # Install the portal config file
    insinto /usr/share/xdg-desktop-portal/portals
    doins data/hyprland.portal
}
