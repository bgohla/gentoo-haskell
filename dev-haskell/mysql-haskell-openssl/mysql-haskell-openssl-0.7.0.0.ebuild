# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# ebuild generated by hackport 0.5

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="TLS support for mysql-haskell package using openssl"
HOMEPAGE="https://github.com/winterland1989/mysql-haskell"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/hsopenssl-0.10.3:=[profile?] <dev-haskell/hsopenssl-0.12:=[profile?]
	>=dev-haskell/io-streams-1.2:=[profile?] <dev-haskell/io-streams-2.0:=[profile?]
	>=dev-haskell/mysql-haskell-0.7:=[profile?]
	>=dev-haskell/network-2.3:=[profile?] <dev-haskell/network-3.0:=[profile?]
	>=dev-haskell/tcp-streams-0.6:=[profile?] <dev-haskell/tcp-streams-0.7:=[profile?]
	>=dev-haskell/tcp-streams-openssl-0.6:=[profile?] <dev-haskell/tcp-streams-openssl-0.7:=[profile?]
	>=dev-haskell/wire-streams-0.1:=[profile?]
	>=dev-lang/ghc-7.8.2:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.18.1.3
"