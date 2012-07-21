# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

# ebuild generated by hackport 0.2.18.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Haml-like template files that are compile-time checked"
HOMEPAGE="http://www.yesodweb.com/book/shakespearean-templates"
SRC_URI="http://hackage.haskell.org/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-haskell/blaze-builder-0.2[profile?]
		<dev-haskell/blaze-builder-0.4[profile?]
		=dev-haskell/blaze-html-0.5*[profile?]
		>=dev-haskell/blaze-markup-0.5.1[profile?]
		<dev-haskell/blaze-markup-0.6[profile?]
		>=dev-haskell/failure-0.1[profile?]
		<dev-haskell/failure-0.3[profile?]
		>=dev-haskell/parsec-2[profile?]
		<dev-haskell/parsec-4[profile?]
		>=dev-haskell/shakespeare-1.0.1[profile?]
		<dev-haskell/shakespeare-1.1[profile?]
		>=dev-haskell/text-0.7[profile?]
		<dev-haskell/text-0.12[profile?]
		>=dev-lang/ghc-6.10.1"
DEPEND="${RDEPEND}
		test? ( >=dev-haskell/hspec-1.0
			<dev-haskell/hspec-1.3
			dev-haskell/hunit
		)
		>=dev-haskell/cabal-1.8"

src_prepare() {
	sed -e 's@hspec            >= 1.0     && < 1.2@hspec            >= 1.0     \&\& < 1.3@' \
		-i "${S}/${PN}.cabal" || die "Could not loosen dependencies"
}
