const EfreiToken = artifacts.require("EfreiToken");
const { expect } = require('chai');
const BigNumber = web3.BigNumber;

contract('EfreiToken', accounts => {
    const [ initialHolder, recipient, anotherAccount ] = accounts;

    const _name = "Efrei Token";
    const _symbol = "ETOK"

    beforeEach(async function () {
        this.token = await EfreiToken.new(_name, _symbol, 1000);
    });

    describe('token attributes', function () {
        it('has the correct name', async function () {
            expect(await this.token.name()).to.equal(_name);
        })

        it('has the correct symbol', async function () {
            expect(await this.token.symbol()).to.equal(_symbol);
        })
    })
});