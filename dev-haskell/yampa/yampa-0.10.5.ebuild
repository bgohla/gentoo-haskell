# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.2.9999
#hackport: flags: -test-doc-coverage,-test-hlint,-test-regression

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

MY_PN="Yampa"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Library for programming hybrid systems"
HOMEPAGE="http://www.haskell.org/haskellwiki/Yampa"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-haskell/random:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	cabal_chdeps \
		' -O3 ' ' '
}

src_configure() {
	haskell-cabal_src_configure \
		--flag=-test-doc-coverage \
		--flag=-test-hlint \
		--flag=-test-regression
}
