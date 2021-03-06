# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit eutils distutils-r1

MY_PN="YubiOTP"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Library for verifying YubiKey OTP tokens, both locally and through a Yubico web service"
HOMEPAGE="https://bitbucket.org/psagers/yubiotp"
SRC_URI="mirror://pypi/Y/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="test"

S="${WORKDIR}/${MY_P}"

CDEPEND="dev-python/six[${PYTHON_USEDEP}]
		|| ( dev-python/pycryptodome[${PYTHON_USEDEP}] dev-python/pycrypto[${PYTHON_USEDEP}] )"

RDEPEND="${CDEPEND}"
DEPEND="test? ( ${CDEPEND} )"

python_test() {
	esetup.py test
}
