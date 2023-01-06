const ERC20_ICO = artifacts.require("ERC20_ICO");

module.exports = function (deployer) {
  deployer.deploy(ERC20_ICO);
};
