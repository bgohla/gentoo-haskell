# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# ebuild generated by hackport 0.3.1.9999

CABAL_FEATURES="bin lib profile haddock hoogle hscolour test-suite"
CABAL_FEATURES+=" nocabaldep" # needs ghc's version as uses leksah-server and ltk linked against ghc's Cabal
inherit haskell-cabal git-2

DESCRIPTION="Haskell IDE written in Haskell"
HOMEPAGE="http://www.leksah.org"
EGIT_REPO_URI="git://github.com/leksah/leksah.git"

LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS=""
REQUIRED_USE="dyre? ( yi )"
IUSE="dyre +gtk3 loc webkit yi"
# tests fail to compile: confused by gtk2 in slot 2 and gtk2hs upstream using
# the exact same version numbers for gtk2 on hackage and gtk2 in git.
# GHCi runtime linker: fatal error: I found a duplicate definition for symbol
#    gtk2hs_closure_new
# whilst processing object file
#    /usr/lib64/glib-0.12.4/ghc-7.6.2/HSglib-0.12.4.o
RESTRICT="test"

RDEPEND="=app-editors/leksah-server-9999*:=[profile?]
		>=dev-haskell/binary-0.5.0.0:=[profile?]
		<dev-haskell/binary-0.8:=[profile?]
		=dev-haskell/binary-shared-0.8*:=[profile?]
		>=dev-haskell/cabal-1.6.0.1:=[profile?]
		<dev-haskell/cabal-1.18:=[profile?]
		>=dev-haskell/deepseq-1.1.0.0:=[profile?]
		<dev-haskell/deepseq-1.4:=[profile?]
		>=dev-haskell/enumerator-0.4.14:=[profile?]
		<dev-haskell/enumerator-0.5:=[profile?]
		gtk3? (
			>=dev-haskell/gio-0.13.0:3=[profile?]
			>=dev-haskell/glib-0.13.0:3=[profile?]
			>=dev-haskell/gtk-0.13.0:3=[profile?]
			>=dev-haskell/gtksourceview2-0.13.0:3=[profile?]
		)
		!gtk3? (
			>=dev-haskell/gio-0.12.2:2=[profile?]
			<dev-haskell/gio-0.13:2=[profile?]
			>=dev-haskell/glib-0.10:2=[profile?]
			<dev-haskell/glib-0.13:2=[profile?]
			>=dev-haskell/gtk-0.10:2=[profile?]
			<dev-haskell/gtk-0.13:2=[profile?]
			>=dev-haskell/gtksourceview2-0.10.0:2=[profile?]
			<dev-haskell/gtksourceview2-0.13:2=[profile?]
		)
		>=dev-haskell/haskell-src-exts-1.13.5:=[profile?]
		<dev-haskell/haskell-src-exts-1.14:=[profile?]
		>=dev-haskell/hlint-1.8.39:=[profile?]
		<dev-haskell/hlint-1.9:=[profile?]
		>=dev-haskell/hslogger-1.0.7:=[profile?]
		<dev-haskell/hslogger-1.3:=[profile?]
		=dev-haskell/ltk-9999*:=[profile?]
		>=dev-haskell/missingh-1.1.1.0:=[profile?]
		<dev-haskell/missingh-1.3:=[profile?]
		>=dev-haskell/mtl-1.1.0.2:=[profile?]
		<dev-haskell/mtl-2.2:=[profile?]
		>=dev-haskell/network-2.2:=[profile?]
		<dev-haskell/network-3.0:=[profile?]
		>=dev-haskell/parsec-2.1.0.1:=[profile?]
		<dev-haskell/parsec-3.2:=[profile?]
		=dev-haskell/pretty-show-1.5*:=[profile?]
		>=dev-haskell/quickcheck-2.4.2:=[profile?]
		<dev-haskell/quickcheck-2.6:=[profile?]
		=dev-haskell/regex-base-0.93*:=[profile?]
		=dev-haskell/regex-tdfa-1.1*:=[profile?]
		>=dev-haskell/strict-0.3.2:=[profile?]
		<dev-haskell/strict-0.4:=[profile?]
		>=dev-haskell/text-0.11.1.5:=[profile?]
		<dev-haskell/text-0.12:=[profile?]
		>=dev-haskell/transformers-0.2.2.0:=[profile?]
		<dev-haskell/transformers-0.4:=[profile?]
		>=dev-haskell/utf8-string-0.3.1.1:=[profile?]
		<dev-haskell/utf8-string-0.4:=[profile?]
		dev-haskell/vcsgui:=[profile?]
		>=dev-haskell/vcswrapper-0.0.1:=[profile?]
		<dev-haskell/vcswrapper-0.1:=[profile?]
		>=dev-lang/ghc-6.12.1:=
		loc? ( dev-haskell/hgettext:=[profile?]
			dev-haskell/setlocale:=[profile?]
		)
		webkit? ( dev-haskell/blaze-html:=[profile?]
			dev-haskell/ghcjs-codemirror:=[profile?]
			dev-haskell/ghcjs-dom:=[profile?]
			dev-haskell/hamlet:=[profile?]
			dev-haskell/jsc:=[profile?]
			dev-haskell/lens:=[profile?]
			dev-haskell/webkit:=[profile?]
			dev-haskell/webkit-javascriptcore:=[profile?]
		)
		yi? ( >=app-editors/yi-0.6.6.1:=[profile?]
			<app-editors/yi-0.7:=[profile?]
			dyre? ( >=dev-haskell/dyre-0.8.3:=[profile?]
			<dev-haskell/dyre-0.9:=[profile?]
			)
		)"
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.10
		test? ( dev-haskell/monad-loops
		)"

src_prepare() {
	if has_version "<dev-lang/ghc-7.0.1" && has_version ">=dev-haskell/cabal-1.10.0.0"; then
		# with ghc 6.12 does not work with cabal-1.10, so use ghc-6.12 shipped one
		sed -e 's@build-depends: Cabal >=1.6.0.1 && <1.17@build-depends: Cabal >=1.6.0.1 \&\& <1.9@g' \
			-i "${S}/${PN}.cabal"
	fi
	if ! use webkit; then
		sed -e '/executable bewleksah/,/    hs-source-dirs: bew/d' \
			-i "${S}/${PN}.cabal" \
			|| die "Could not remove executable bewleksah from ${S}/${PN}.cabal"
	fi
	if use gtk3; then
		cabal_chdeps \
			'glib >=0.10 && <0.13' 'glib >=0.13' \
			'gtk >=0.10 && <0.13' 'gtk >=0.13' \
			'gtksourceview2 >=0.10.0 && <0.13' 'gtksourceview2 >=0.13.0' \
			'gio >=0.12.2 && <0.13' 'gio >=0.13.0' \
			'QuickCheck >=2.4.2 && <2.6' 'QuickCheck >=2.4.2 && <2.7'
	fi

	# workaround haddock 2.10.0 error: parse error on input `-- ^ source buffer view'
	sed -e 's@-- ^@--@g' \
		-i "${S}/src/IDE/SymbolNavigation.hs" \
		|| die "Could not remove haddock markup"
}

src_configure() {
	threaded_flag=""
	if $(ghc-getghc) --info | grep "Support SMP" | grep -q "YES"; then
		threaded_flag="--flags=threaded"
		einfo "$P will be built with threads support"
	else
		threaded_flag="--flags=-threaded"
		einfo "$P will be built without threads support"
	fi
	cabal_src_configure $threaded_flag \
		$(cabal_flag dyre) \
		$(cabal_flag gtk3) \
		$(cabal_flag loc) \
		$(cabal_flag webkit) \
		$(cabal_flag yi) \
		--constraint="Cabal == $(cabal-version)"
}
