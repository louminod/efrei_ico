const EfreiToken = artifacts.require("EfreiToken");
const EfreiICO = artifacts.require("EfreiICO");

module.exports = async function (deployer) {
    const _totalSupply = 10000000; //10M
    const _name = "Efrei Token";
    const _symbol = "ETOK"

    //Token
    await deployer.deploy(
        EfreiToken,
        _name, //name
        _symbol, //sticker
        _totalSupply
    );
    const efreiToken = await EfreiToken.deployed();

    //ICO
    await deployer.deploy(
        EfreiICO,
        efreiToken.address,
        592200, // duration (592200s = 1 week)
        web3.utils.toWei('2', 'milli'), // price of 1 token in DAI (wei) (= 0.002 DAI. 0.002 * 10M = 20,000 DAI ~= 20,000 USD)
        _totalSupply, //_availableTokens for the ICO. can be less than maxTotalSupply
        200, //_minPurchase (in DAI)
        5000 //_maxPurchase (in DAI)
    );
    const efreiICO = await EfreiICO.deployed();
    await efreiToken.updateAdmin(efreiICO.address);
    await efreiICO.start();
};