# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# ebuild generated by hackport 0.6.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Backports of GHC deriving extensions"
HOMEPAGE="https://github.com/haskell-compat/deriving-compat"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/th-abstraction-0.3:=[profile?] <dev-haskell/th-abstraction-0.4:=[profile?]
	>=dev-haskell/transformers-compat-0.5:=[profile?]
	>=dev-lang/ghc-7.8.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
	test? ( >=dev-haskell/base-compat-0.8.1 <dev-haskell/base-compat-1
		>=dev-haskell/base-orphans-0.5 <dev-haskell/base-orphans-1
		>=dev-haskell/hspec-1.8
		>=dev-haskell/quickcheck-2 <dev-haskell/quickcheck-3
		>=dev-haskell/tagged-0.7 <dev-haskell/tagged-1 )
"