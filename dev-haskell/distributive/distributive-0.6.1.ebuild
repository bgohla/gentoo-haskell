# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.6.9999
#hackport: flags: +tagged,+semigroups

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Distributive functors -- Dual to Traversable"
HOMEPAGE="https://github.com/ekmett/distributive/"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT=test # fails on USE=doc

RDEPEND=">=dev-haskell/base-orphans-0.5.2:=[profile?] <dev-haskell/base-orphans-1:=[profile?]
	>=dev-haskell/semigroups-0.13:=[profile?] <dev-haskell/semigroups-1:=[profile?]
	>=dev-haskell/tagged-0.7:=[profile?] <dev-haskell/tagged-1:=[profile?]
	>=dev-lang/ghc-7.8.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
	>=dev-haskell/cabal-doctest-1 <dev-haskell/cabal-doctest-1.1
	test? ( >=dev-haskell/doctest-0.11.1 <dev-haskell/doctest-0.17
		>=dev-haskell/generic-deriving-1.11 <dev-haskell/generic-deriving-2
		>=dev-haskell/hspec-2 <dev-haskell/hspec-3 )
"

src_configure() {
	haskell-cabal_src_configure \
		--flag=semigroups \
		--flag=tagged
}
