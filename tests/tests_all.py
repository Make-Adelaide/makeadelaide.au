import pytest

from brownie import Contract

@pytest.fixture
def dao_proxy(TransparentProxy, DAO, accounts):
	dao = DAO.deploy({"from": accounts[0]})
	yield TransparentProxy.deploy(dao, {"from": accounts[0]})

@pytest.fixture
def dao(dao_proxy):
	contract = Contract.from_abi("DAO", proxy.address, DAO)
	contract.initialise(accounts[0])
	yield contract

@pytest.fixture
def make_adelaide_proxy(TransparentProxy, MakeAdelaide, accounts):
	make_adelaide = MakeAdelaide.deploy({"from": accounts[0]})
	yield TransparentProxy.deploy(make_adelaide, {"from": accounts[0]})

@pytest.fixture
def make_adelaide(make_adelaide_proxy, dao, accounts):
	contract = Contract.from_abi("MakeAdelaide", make_adelaide_proxy.address, MakeAdelaide)
	contract.initialise(dao.address, accounts[0], accounts[0])
	yield contract

@pytest.fixture
def admin(TransparentProxy, Admin, accounts, dao_proxy, make_adelaide_proxy):
	admin = Admin.deploy(dao, make_adelaide, {"from": accounts[0]})

	dao.new_admin(admin.address)
	make_adelaide.new_admin(admin.address)

	yield admin

def test_make_adelaide_account_0_submitter(make_adelaide, accounts):
	assert make_adelaide.isSubmitter({"from": accounts[0]})
