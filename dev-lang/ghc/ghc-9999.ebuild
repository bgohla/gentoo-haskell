# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Brief explanation of the bootstrap logic:
#
# Previous ghc ebuilds have been split into two: ghc and ghc-bin,
# where ghc-bin was primarily used for bootstrapping purposes.
# From now on, these two ebuilds have been combined, with the
# binary USE flag used to determine whether or not the pre-built
# binary package should be emerged or whether ghc should be compiled
# from source.  If the latter, then the relevant ghc-bin for the
# arch in question will be used in the working directory to compile
# ghc from source.
#
# This solution has the advantage of allowing us to retain the one
# ebuild for both packages, and thus phase out virtual/ghc.

# Note to users of hardened gcc-3.x:
#
# If you emerge ghc with hardened gcc it should work fine (because we
# turn off the hardened features that would otherwise break ghc).
# However, emerging ghc while using a vanilla gcc and then switching to
# hardened gcc (using gcc-config) will leave you with a broken ghc. To
# fix it you would need to either switch back to vanilla gcc or re-emerge
# ghc (or ghc-bin). Note that also if you are using hardened gcc-3.x and
# you switch to gcc-4.x that this will also break ghc and you'll need to
# re-emerge ghc (or ghc-bin). People using vanilla gcc can switch between
# gcc-3.x and 4.x with no problems.

EAPI="5"

# to make make a crosscompiler use crossdev and symlink ghc tree into
# cross overlay. result would look like 'cross-sparc-unknown-linux-gnu/ghc'
#
# 'CTARGET' definition and 'is_crosscompile' are taken from 'toolchain.eclass'
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

inherit base autotools bash-completion-r1 eutils flag-o-matic git-2 multilib toolchain-funcs ghc-package versionator pax-utils

DESCRIPTION="The Glasgow Haskell Compiler"
HOMEPAGE="http://www.haskell.org/ghc/"

#EGIT_REPO_URI="http://darcs.haskell.org/ghc.git/"
EGIT_REPO_URI="https://github.com/ghc/ghc.git"
LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS=""
IUSE="doc +ghcbootstrap llvm"
REQUIRED_USE="ghcbootstrap"

RDEPEND="
	!kernel_Darwin? ( >=sys-devel/gcc-2.95.3 )
	kernel_linux? ( >=sys-devel/binutils-2.17 )
	kernel_SunOS? ( >=sys-devel/binutils-2.17 )
	>=dev-lang/perl-5.6.1
	>=dev-libs/gmp-5
	virtual/libffi
	!<dev-haskell/haddock-2.4.2
	sys-libs/ncurses[unicode]"
# earlier versions than 2.4.2 of haddock only works with older ghc releases

# force dependency on >=gmp-5, even if >=gmp-4.1 would be enough. this is due to
# that we want the binaries to use the latest versioun available, and not to be
# built against gmp-4

DEPEND="${RDEPEND}
	>=dev-haskell/alex-2.3
	>=dev-haskell/happy-1.18
	doc? (	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	>=dev-libs/libxslt-1.1.2 )"

PDEPEND="
	${PDEPEND}
	llvm? ( sys-devel/llvm )"

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

append-ghc-cflags() {
	local flag compile assemble link
	for flag in $*; do
		case ${flag} in
			compile)	compile="yes";;
			assemble)	assemble="yes";;
			link)		link="yes";;
			*)
				[[ ${compile}  ]] && GHC_FLAGS="${GHC_FLAGS} -optc${flag}" CFLAGS="${CFLAGS} ${flag}"
				[[ ${assemble} ]] && GHC_FLAGS="${GHC_FLAGS} -opta${flag}" CFLAGS="${CFLAGS} ${flag}"
				[[ ${link}     ]] && GHC_FLAGS="${GHC_FLAGS} -optl${flag}" FILTERED_LDFLAGS="${FILTERED_LDFLAGS} ${flag}";;
		esac
	done
}

ghc_setup_cflags() {
	if is_crosscompile; then
		export CFLAGS=${GHC_CFLAGS-"-O2 -pipe"}
		export LDFLAGS=${GHC_LDFLAGS-"-Wl,-O1"}
		einfo "Crosscompiling mode:"
		einfo "   CHOST:   ${CHOST}"
		einfo "   CTARGET: ${CTARGET}"
		einfo "   CFLAGS:  ${CFLAGS}"
		einfo "   LDFLAGS: ${LDFLAGS}"
		return
	fi
	# We need to be very careful with the CFLAGS we ask ghc to pass through to
	# gcc. There are plenty of flags which will make gcc produce output that
	# breaks ghc in various ways. The main ones we want to pass through are
	# -mcpu / -march flags. These are important for arches like alpha & sparc.
	# We also use these CFLAGS for building the C parts of ghc, ie the rts.
	strip-flags
	strip-unsupported-flags

	GHC_FLAGS=""
	for flag in ${CFLAGS}; do
		case ${flag} in

			# Ignore extra optimisation (ghc passes -O to gcc anyway)
			# -O2 and above break on too many systems
			-O*) ;;

			# Arch and ABI flags are what we're really after
			-m*) append-ghc-cflags compile assemble ${flag};;

			# Debugging flags don't help either. You can't debug Haskell code
			# at the C source level and the mangler discards the debug info.
			-g*) ;;

			# Ignore all other flags, including all -f* flags
		esac
	done

	FILTERED_LDFLAGS=""
	for flag in ${LDFLAGS}; do
		case ${flag} in
			# Pass the canary. we don't quite respect LDFLAGS, but we have an excuse!
			"-Wl,--hash-style="*) append-ghc-cflags link ${flag};;

			# Ignore all other flags
		esac
	done

	# hardened-gcc needs to be disabled, because the mangler doesn't accept
	# its output.
	gcc-specs-pie && append-ghc-cflags compile link	-nopie
	gcc-specs-ssp && append-ghc-cflags compile		-fno-stack-protector

	# prevent from failind building unregisterised ghc:
	# http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg171602.html
	use ppc64 && append-ghc-cflags compile -mminimal-toc
	# fix the similar issue as ppc64 TOC on ia64. ia64 has limited size of small data
	# currently ghc fails to build haddock
	# http://osdir.com/ml/gnu.binutils.bugs/2004-10/msg00050.html
	use ia64 && append-ghc-cflags compile -G0

	# Unfortunately driver/split/ghc-split.lprl is dumb
	# enough to preserve stack marking for each split object
	# and it flags stack marking violation:
	# * !WX --- --- usr/lib64/ghc-7.4.1/base-4.5.0.0/libHSbase-4.5.0.0.a:Fingerprint__1.o
	# * !WX --- --- usr/lib64/ghc-7.4.1/base-4.5.0.0/libHSbase-4.5.0.0.a:Fingerprint__2.o
	# * !WX --- --- usr/lib64/ghc-7.4.1/base-4.5.0.0/libHSbase-4.5.0.0.a:Fingerprint__3.o
	case $($(tc-getAS) -v 2>&1 </dev/null) in
		*"GNU Binutils"*) # GNU ld
			append-ghc-cflags compile assemble -Wa,--noexecstack
			;;
	esac
}

pkg_setup() {
	[[ -z $(type -P ghc) ]] && \
		die "Could not find a ghc to bootstrap with."
}

src_unpack() {
	EGIT_NONBARE="true"
	EGIT_BRANCH="master"
	if [[ -n ${GHC_BRANCH} ]]; then
		EGIT_BRANCH="${GHC_BRANCH}"
	fi

	debug-print-function ${FUNCNAME} "$@"

	git-2_init_variables
	git-2_prepare_storedir
	git-2_migrate_repository
	git-2_fetch "$@"
	git-2_gc
	git-2_submodules

	pushd ${EGIT_DIR} || die "Could not cd to ${EGIT_DIR}"
	if [[ -f ghc-tarballs/LICENSE ]]; then
		einfo "./sync-all --branch=${EGIT_BRANCH} --testsuite pull"
		./sync-all --branch=${EGIT_BRANCH} --testsuite pull
		if [[ "$?" != "0" ]]; then
			ewarn "sync-all --branch=${EGIT_BRANCH} --testsuite pull failed, trying get"
			einfo "./sync-all --branch=${EGIT_BRANCH} --testsuite get"
			./sync-all --branch=${EGIT_BRANCH} --testsuite get \
				|| die "sync-all --branch=${EGIT_BRANCH} --testsuite get failed"
		fi
	else
		einfo "./sync-all --branch=${EGIT_BRANCH} --testsuite get"
		./sync-all --branch=${EGIT_BRANCH} --testsuite get \
			|| die "sync-all --branch=${EGIT_BRANCH} --testsuite get failed"
	fi
	popd

	git-2_move_source
	git-2_branch
	git-2_bootstrap
	git-2_cleanup
	echo ">>> Unpacked to ${EGIT_SOURCEDIR}"

	# Users can specify some SRC_URI and we should
	# unpack the files too.
	if [[ ! ${EGIT_NOUNPACK} ]]; then
		if has ${EAPI:-0} 0 1; then
			[[ ${A} ]] && unpack ${A}
		else
			default_src_unpack
		fi
	fi

	cd "${S}"
}

src_prepare() {
	ghc_setup_cflags

	sed -i -e "s|\"\$topdir\"|\"\$topdir\" ${GHC_FLAGS}|" \
		"${S}/ghc/ghc.wrapper"

	cd "${S}" # otherwise epatch will break

	epatch "${FILESDIR}/ghc-7.0.4-CHOST-prefix.patch"

	# epatch "${FILESDIR}"/${PN}-7.0.4-darwin8.patch
	# failed to apply. FIXME
	#epatch "${FILESDIR}"/${PN}-6.12.3-mach-o-relocation-limit.patch

	# epatch "${FILESDIR}"/${PN}-7.4-rc2-macos-prefix-respect-gcc.patch
	# epatch "${FILESDIR}"/${PN}-7.2.1-freebsd-CHOST.patch

	# one mode external depend with unstable ABI be careful to stash it
	if [[ "${EGIT_BRANCH}" == "ghc-7.4" || ( -n ${GHC_USE_7_4_2_SYSTEM_LIBFFI_PATCH} ) ]]; then
		epatch "${FILESDIR}"/${PN}-7.4.2-system-libffi.patch
	else
		epatch "${FILESDIR}"/${PN}-7.7.20121013-system-libffi.patch
	fi

	# FIXME this should not be necessary, workaround ghc 7.5.20120505 build failure
	# http://web.archiveorange.com/archive/v/j7U5dEOAbcD9aCZJDOPT
	epatch "${FILESDIR}"/${PN}-7.5-dph-base_dist_install_GHCI_LIB_not_defined.patch

	if use prefix; then
		# Make configure find docbook-xsl-stylesheets from Prefix
		sed -e '/^FP_DIR_DOCBOOK_XSL/s:\[.*\]:['"${EPREFIX}"'/usr/share/sgml/docbook/xsl-stylesheets/]:' \
			-i utils/haddock/doc/configure.ac || die
	fi

	# as we have changed the build system
	eautoreconf
}

src_configure() {
	# initialize build.mk
	echo '# Gentoo changes' > mk/build.mk

	# Put docs into the right place, ie /usr/share/doc/ghc-${PV}
	echo "docdir = ${EPREFIX}/usr/share/doc/${P}" >> mk/build.mk
	echo "htmldir = ${EPREFIX}/usr/share/doc/${P}" >> mk/build.mk

	# We also need to use the GHC_FLAGS flags when building ghc itself
	echo "SRC_HC_OPTS+=${GHC_FLAGS}" >> mk/build.mk
	echo "SRC_CC_OPTS+=${CFLAGS}" >> mk/build.mk
	echo "SRC_LD_OPTS+=${FILTERED_LDFLAGS}" >> mk/build.mk

	# We can't depend on haddock except when bootstrapping when we
	# must build docs and include them into the binary .tbz2 package
	# app-text/dblatex is not in portage, can not build PDF or PS
	if use ghcbootstrap && use doc; then
		echo "BUILD_DOCBOOK_PDF  = NO"  >> mk/build.mk
		echo "BUILD_DOCBOOK_PS   = NO"  >> mk/build.mk
		echo "BUILD_DOCBOOK_HTML = YES" >> mk/build.mk
		if is_crosscompile; then
			# TODO this is a workaround for this build error with the live ebuild with haddock:
			# make[1]: *** No rule to make target `compiler/stage2/build/Module.hi',
			# needed by `utils/haddock/dist/build/Main.o'.  Stop.
			echo "HADDOCK_DOCS       = NO" >> mk/build.mk
		else
			echo "HADDOCK_DOCS       = YES" >> mk/build.mk
		fi
	else
		echo "BUILD_DOCBOOK_PDF  = NO" >> mk/build.mk
		echo "BUILD_DOCBOOK_PS   = NO" >> mk/build.mk
		echo "BUILD_DOCBOOK_HTML = NO" >> mk/build.mk
		echo "HADDOCK_DOCS       = NO" >> mk/build.mk
	fi

	# circumvent a very strange bug that seems related with ghc producing
	# too much output while being filtered through tee (e.g. due to
	# portage logging) reported as bug #111183
	echo "SRC_HC_OPTS+=-w" >> mk/build.mk

	echo "SRC_HC_OPTS+=-O -H64m" >> mk/build.mk
	echo "GhcStage1HcOpts = -O -fasm" >> mk/build.mk
	echo "GhcStage2HcOpts = -O2 -fasm" >> mk/build.mk
	echo "GhcHcOpts       = -Rghc-timing" >> mk/build.mk
	echo "GhcLibHcOpts    = -O2" >> mk/build.mk
	echo "GhcLibWays     += p" >> mk/build.mk
	echo 'ifeq "$(PlatformSupportsSharedLibs)" "YES"' >> mk/build.mk
	echo "GhcLibWays += dyn" >> mk/build.mk
	echo "endif" >> mk/build.mk

	# some arches do not support ELF parsing for ghci module loading
	# PPC64: never worked (should be easy to implement)
	# alpha: never worked
	# arm: http://hackage.haskell.org/trac/ghc/changeset/27302c9094909e04eb73f200d52d5e9370c34a8a
	if use alpha || use ppc64; then
		echo "GhcWithInterpreter=NO" >> mk/build.mk
	fi

	# we have to tell it to build unregisterised on some arches
	# ppc64: EvilMangler currently does not understand some TOCs
	# ia64: EvilMangler bitrot
	if use alpha || use ia64 || use ppc64; then
		echo "GhcUnregisterised=YES" >> mk/build.mk
		echo "GhcWithNativeCodeGen=NO" >> mk/build.mk
		echo "SplitObjs=NO" >> mk/build.mk
		echo "GhcRTSWays := debug" >> mk/build.mk
		echo "GhcNotThreaded=YES" >> mk/build.mk
	fi

	# arm: no EvilMangler support, no NCG support
	if use arm; then
		echo "GhcUnregisterised=YES" >> mk/build.mk
		echo "GhcWithNativeCodeGen=NO" >> mk/build.mk
	fi

	# Have "ld -r --relax" problem with split-objs on sparc:
	if use sparc; then
		echo "SplitObjs=NO" >> mk/build.mk
	fi

	if ! use llvm; then
		echo "GhcWithLlvmCodeGen=NO" >> mk/build.mk
	fi

	# This is only for head builds
	perl boot || die "perl boot failed"

	# Since GHC 6.12.2 the GHC wrappers store which GCC version GHC was
	# compiled with, by saving the path to it. The purpose is to make sure
	# that GHC will use the very same gcc version when it compiles haskell
	# sources, as the extra-gcc-opts files contains extra gcc options which
	# match only this GCC version.
	# However, this is not required in Gentoo, as only modern GCCs are used
	# (>4).
	# Instead, this causes trouble when for example ccache is used during
	# compilation, but we don't want the wrappers to point to ccache.
	# Due to the above, we simply set GCC to be "gcc". When compiling ghc it
	# might point to ccache, once installed it will point to the users
	# regular gcc.

	econf --with-gcc=gcc --enable-bootstrap-with-devel-snapshot \
		|| die "econf failed"
	GHC_PV="$(grep 'S\[\"PACKAGE_VERSION\"\]' config.status | sed -e 's@^.*=\"\(.*\)\"@\1@')"
	GHC_TPF="$(grep 'S\[\"TargetPlatformFull\"\]' config.status | sed -e 's@^.*=\"\(.*\)\"@\1@')"
}

src_compile() {
	#limit_jobs() {
	#	if [[ -n ${I_DEMAND_MY_CORES_LOADED} ]]; then
	#		ewarn "You have requested parallel build which is known to break."
	#		ewarn "Please report all breakages upstream."
	#		return
	#	fi
	#	echo $@
	#}
	# ghc massively parallel make: #409631, #409873
	#   but let users screw it by setting 'I_DEMAND_MY_CORES_LOADED'
	#emake $(limit_jobs -j1) all
	# ^ above seems to be fixed.
	emake all

	if is_crosscompile; then
		# runghc does not work for a stage1 compiler, we can build it anyway
		# so it will print the error message: not built for interactive use
		pushd "${S}/utils/runghc" || die "Could not cd to utils/runghc"
		if [ ! -f Setup.hs ]; then
			echo 'import Distribution.Simple; main = defaultMainWithHooks defaultUserHooks' \
				> Setup.hs || die "failed to create default Setup.hs"
		fi
		ghc -o setup --make Setup.hs || die "setup build failed"
		./setup configure || die "runghc configure failed"
		sed -e "s@VERSION@\"${GHC_PV}\"@" -i runghc.hs
		./setup build || die "runghc build failed"
		popd
	fi
}

src_install() {
	export LD_LIBRARY_PATH="$(find . -type f -name 'lib*.so' -print |sed -e "s@\./\(.*\)/lib.*@${PWD}/\1@g" |xargs | sed -e 's@ @:@g')"

	local insttarget="install"

	emake -j1 ${insttarget} \
		DESTDIR="${D}" \
		|| die "make ${insttarget} failed"

	# remove wrapper and linker
	rm -f "${ED}"/usr/bin/haddock*

	# ghci uses mmap with rwx protection at it implements dynamic
	# linking on it's own (bug #299709)
	# so mark resulting binary
	pax-mark -m "${ED}/usr/$(get_libdir)/${PN}-${GHC_PV}/ghc"

	if [[ ! -f "${S}/VERSION" ]]; then
		echo "${GHC_PV}" > "${S}/VERSION" \
			|| die "Could not create file ${S}/VERSION"
	fi
	dodoc "${S}/README" "${S}/ANNOUNCE" "${S}/LICENSE" "${S}/VERSION"

	dobashcomp "${FILESDIR}/ghc-bash-completion"

	# 7.7.20121102 dyn links ghc and forgets to install the ghc shared lib, and the
	# dynamically linked and profiling files.
	pushd "${S}/compiler/stage2/build" || die "Could not cd to ${S}/compiler/stage2/build"
	dodir /usr/$(get_libdir)/ghc-${GHC_PV}/ghc-${GHC_PV}
	exeinto /usr/$(get_libdir)/ghc-${GHC_PV}/ghc-${GHC_PV}
	doexe "libHSghc-${GHC_PV}-ghc${GHC_PV}.so"
	while IFS= read -r -d $'\0' j; do
		local d=$(dirname /usr/$(get_libdir)/ghc-${GHC_PV}/ghc-${GHC_PV}${j#${PWD}})
		dodir ${d}
		insinto ${d}
		doins ${j}
	done < <(find ${PWD} -type f \( -name '*.dyn_hi' -o -name '*.p_hi' \) -print0)
	popd

	# path to the package.conf.d
	local package_confdir="${ED}/usr/$(get_libdir)/${PN}-${GHC_PV}/package.conf.d"
	# path to the package.cache
	PKGCACHE="${ED}/usr/$(get_libdir)/${PN}-${GHC_PV}/package.conf.d/package.cache"
	# copy the package.conf.d, including timestamp, save it so we can help
	# users that have a broken package.conf.d
	cp -pR "${package_confdir}"{,.initial} || die "failed to backup intial package.conf.d"

	# copy the package.conf, including timestamp, save it so we later can put it
	# back before uninstalling, or when upgrading.
	cp -p "${PKGCACHE}"{,.shipped} \
		|| die "failed to copy package.conf.d/package.cache"
}

pkg_preinst() {
	# have we got an earlier version of ghc installed?
	if has_version "<${CATEGORY}/${PF}"; then
		haskell_updater_warn="1"
	fi
}

pkg_postinst() {
	ghc-reregister

	# path to the package.cache
	PKGCACHE="${EROOT}/usr/$(get_libdir)/${PN}-${GHC_PV}/package.conf.d/package.cache"

	# give the cache a new timestamp, it must be as recent as
	# the package.conf.d directory.
	touch "${PKGCACHE}"

	ewarn
	ewarn "\e[1;31m************************************************************************\e[0m"
	ewarn
	ewarn "For the master branch (ghc 7.7) place lines like these in"
	ewarn "/etc/portage/package.keywords"
	ewarn "=dev-haskell/time-1.4.0.1*"
	ewarn "=dev-haskell/cabal-1.17.0* **"
	ewarn "=dev-haskell/deepseq-1.3.0.1* **"
	ewarn "=dev-haskell/haddock-2.11.0* **"
	ewarn "=dev-haskell/deepseq-1.3.0.1* **"
	ewarn "=dev-lang/ghc-9999 **"
	ewarn ""
	if [[ "${haskell_updater_warn}" == "1" ]]; then
		ewarn "You have just upgraded from an older version of GHC."
		ewarn "You may have to run"
		ewarn "      'haskell-updater --upgrade'"
		ewarn "to rebuild all ghc-based Haskell libraries."
	fi
	if is_crosscompile; then
		ewarn
		ewarn "GHC built as a cross compiler.  The interpreter, ghci and runghc, do"
		ewarn "not work for a cross compiler."
		ewarn "For the ghci error: \"<command line>: not built for interactive use\" see:"
		ewarn "http://www.haskell.org/haskellwiki/GHC:FAQ#When_I_try_to_start_ghci_.28probably_one_I_compiled_myself.29_it_says_ghc-5.02:_not_built_for_interactive_use"
	fi
	ewarn
	ewarn "\e[1;31m************************************************************************\e[0m"
	ewarn
}

pkg_prerm() {
	# Be very careful here... Call order when upgrading is (according to PMS):
	# * src_install for new package
	# * pkg_preinst for new package
	# * pkg_postinst for new package
	# * pkg_prerm for the package being replaced
	# * pkg_postrm for the package being replaced
	# so you'll actually be touching the new packages files, not the one you
	# uninstall, due to that or installation directory ${PN}-${GHC_PV} will be the same for
	# both packages.

	# Call order for reinstalling is (according to PMS):
	# * src_install
	# * pkg_preinst
	# * pkg_prerm for the package being replaced
	# * pkg_postrm for the package being replaced
	# * pkg_postinst

	# Overwrite the modified package.cache with a copy of the
	# original one, so that it will be removed during uninstall.

	PKGCACHE="${EROOT}/usr/$(get_libdir)/${PN}-${GHC_PV}/package.conf.d/package.cache"
	rm -rf "${PKGCACHE}"

	cp -p "${PKGCACHE}"{.shipped,}
}
