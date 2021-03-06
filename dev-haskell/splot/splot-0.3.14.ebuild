# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.9999

CABAL_FEATURES="bin"
inherit haskell-cabal

DESCRIPTION="A tool for visualizing the lifecycle of many concurrent multi-staged processes"
HOMEPAGE="http://www.haskell.org/haskellwiki/Splot"
SRC_URI="https://hackage.haskell.org/package/${P}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/bytestring-lexing-0.5:= <dev-haskell/bytestring-lexing-0.6:=
	dev-haskell/cairo:=
	dev-haskell/colour:=
	dev-haskell/hunit:=
	dev-haskell/mtl:=
	>=dev-haskell/strptime-0.1.7:=
	>=dev-haskell/vcs-revision-0.0.2:=
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.6
"
