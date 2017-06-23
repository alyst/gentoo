# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic perl-functions user

DESCRIPTION="A portable and secure set of open-source and modular IRC services"
HOMEPAGE="https://github.com/atheme/atheme"
SRC_URI="https://github.com/atheme/atheme/releases/download/v${PV}/atheme-${PV}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cracklib largenet ldap nls +pcre perl profile ssl"
S="${WORKDIR}/atheme-${PV}"

RDEPEND=">=dev-libs/libmowgli-2.1.0:0
	cracklib? ( sys-libs/cracklib )
	ldap? ( net-nds/openldap )
	perl? ( dev-lang/perl )
	pcre? ( dev-libs/libpcre )
	ssl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${P}-fix-docdir.patch
	"${FILESDIR}"/${P}-configure-logdir.patch)

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/atheme ${PN}
}

src_configure() {
	# perl scriping module support is also broken in 7.0.0. Yay for QA failures.
	econf \
		--sysconfdir="${EPREFIX}"/etc/${PN} \
		--localstatedir="${EPREFIX}"/var \
		--enable-fhs-paths \
		--disable-warnings \
		--enable-contrib \
		$(use_enable largenet large-net) \
		$(use_with cracklib) \
		$(use_with ldap) \
		$(use_enable nls) \
		$(use_enable profile) \
		$(use_with pcre) \
		$(use_with perl) \
		$(use_enable ssl)
}

src_compile() {
	emake V=1
}

src_install() {
	default

	insinto /etc/${PN}
	for conf in dist/*.example; do
		# The .cron file isn't meant to live in /etc/${PN}, so only
		# install a .example version.
		[[ ${conf} == *cron* ]] && continue

		local confdest=${conf##*/}
		newins ${conf} ${confdest%.example}
	done

	fowners -R 0:${PN} /etc/${PN}
	keepdir /var/{lib,log}/atheme
	fowners ${PN}:${PN} /var/{lib,log}/atheme
	fperms -R go-w,o-rx /etc/${PN}
	fperms 750 /etc/${PN} /var/{lib,log}/atheme

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	mv "${ED}"/usr/bin/{,atheme-}dbverify || die

	# contributed scripts and such:
	docinto contrib
	dodoc contrib/*.{c,pl,php,py,rb}

	use perl && perl_domodule -r contrib/Atheme{,.pm}

	rm "${ED%/}/usr/share/doc/${PF}/WINDOWS" || die

	# Bug #454840 #520490
	rm -rf "${ED%/}/var/run" || die
}
