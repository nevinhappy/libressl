# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="C++ library offering portable support for system-related services"
SRC_URI="mirror://gnu/commoncpp/${P}.tar.gz"
HOMEPAGE="https://www.gnu.org/software/commoncpp/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86"
IUSE="debug doc examples ipv6 gnutls libressl ssl static-libs"

RDEPEND="
	sys-libs/zlib
	ssl? (
		gnutls? (
			dev-libs/libgcrypt:0=
			net-libs/gnutls:=
		)
		!gnutls? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl:= )
		)
	)"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.3.6 )"

PATCHES=(
	"${FILESDIR}/1.8.1-no-ssl3.patch"
	"${FILESDIR}/1.8.1-configure_detect_netfilter.patch"
	"${FILESDIR}/1.8.0-glibc212.patch"
	"${FILESDIR}/1.8.1-autoconf-update.patch"
	"${FILESDIR}/1.8.1-fix-buffer-overflow.patch"
	"${FILESDIR}/1.8.1-parallel-build.patch"
	"${FILESDIR}/1.8.1-libgcrypt.patch"
	"${FILESDIR}/1.8.1-fix-c++14.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use ssl && local myconf=( $(usex gnutls '--with-gnutls' '--with-openssl') )

	econf \
		$(use_enable debug) \
		$(use_with ipv6) \
		$(use_enable static-libs static) \
		$(use_with doc doxygen) \
		"${myconf[@]}"
}

src_install () {
	# Only install html docs
	# man and latex available, but seems a little wasteful
	use doc && HTML_DOCS=( doc/html/. )
	default
	dodoc COPYING.addendum

	if use examples; then
		docinto examples
		dodoc demo/{*.cpp,*.h,*.xml,README}
		docompress -x /usr/share/doc/${PF}/examples
	fi

	# package provides .pc files
	find "${D}" -name '*.la' -delete || die
}
