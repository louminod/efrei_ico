const EfreiToken = artifacts.require("EfreiToken");
const EfreiICO = artifacts.require("EfreiICO");
const {
    expect
} = require('chai');

contract('EfreiICO', accounts => {
    const [initialHolder, recipient, anotherAccount] = accounts;

    let efreiToken;

    const _name = "Efrei Token";
    const _symbol = "ETOK";
    const _initialSupply = 1000;

    beforeEach(async function () {
        efreiToken = await EfreiToken.new(_name, _symbol, _initialSupply);
        this.token = await EfreiICO.new(
            efreiToken.address,
            592200, // duration (592200s = 1 week)
            web3.utils.toWei('2', 'milli'), // price of 1 token in DAI (wei) (= 0.002 DAI. 0.002 * 10M = 20,000 DAI ~= 20,000 USD)
            _initialSupply, //_availableTokens for the ICO. can be less than maxTotalSupply
            200, //_minPurchase (in DAI)
            5000 //_maxPurchase (in DAI)
        );
        await efreiToken.updateAdmin(this.token.address);
        await this.token.start();
    });

    describe('balanceOf', function () {
        describe('when the requested account has no tokens', function () {
            it('returns zero', async function () {
                const expected = web3.utils.toBN('0');
                const actual = await efreiToken.balanceOf(anotherAccount);
                expect(actual).to.eql(expected);
            });
        });

        describe('when the requested account has some tokens', function () {
            it('returns the total amount of tokens', async function () {
                const expected = web3.utils.toBN(_initialSupply);
                const actual = await efreiToken.balanceOf(initialHolder);
                expect(actual).to.eql(expected);
            });
        });
    });

    describe('buy', function () {
        it('buy it', async function () {
            const expected = web3.utils.toBN(_initialSupply);
            const actual = await efreiToken.balanceOf(initialHolder);
            expect(actual).to.eql(expected);
        });
    });

});