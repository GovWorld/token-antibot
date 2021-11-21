// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")
const ethers = hre.ethers
const provider = new ethers.getDefaultProvider(process.env.NETWORK)
const { DATA } = require("./csvjson.js");
async function main() {
    [this.admin1] =  await ethers.getSigners();
    const govTokenFactory = await hre.ethers.getContractFactory("EthGOVToken");
    const govToken = await govTokenFactory.deploy("GovWorld Token TST","GOVTST");
    await govToken.deployed();
    console.log('TOKEN ADDRESS: ', govToken.address);
}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })