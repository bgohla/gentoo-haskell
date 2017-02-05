# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild generated by hackport 0.5.1.9999

CABAL_FEATURES=""
inherit haskell-cabal

AGDA_PV=2.5.2
AGDA_P=agda-${AGDA_PV}

DESCRIPTION="Fixes whitespace issues for Agda sources"
HOMEPAGE="http://hackage.haskell.org/package/fix-agda-whitespace"
SRC_URI="https://github.com/agda/agda/archive/v${AGDA_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/filemanip-0.3.6.2:= <dev-haskell/filemanip-0.4:=
	>=dev-haskell/text-0.11.3.1:= <dev-haskell/text-1.3:=
	>=dev-lang/ghc-7.6.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.16.0
"

S=${WORKDIR}/${AGDA_P}/src/fix-agda-whitespace
