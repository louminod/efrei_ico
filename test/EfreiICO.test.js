const EfreiToken = artifacts.require("EfreiToken");
const EfreiICO = artifacts.require("EfreiICO");
const {
    expect
} = require('chai');
const BigNumber = web3.BigNumber;

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

    describe('efreiToken attributes', function () {
        it('has the correct name', async function () {
            expect(await efreiToken.name()).to.equal(_name);
        })

        it('has the correct symbol', async function () {
            expect(await efreiToken.symbol()).to.equal(_symbol);
        })
    })

    describe('total supply', function () {
        it('returns the total amount of tokens', async function () {
          expect(await efreiToken.totalSupply()).to.be.bignumber.equal(_initialSupply);
        });
      });
    
});