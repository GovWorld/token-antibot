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
    // const govTokenFactory = await hre.ethers.getContractFactory("JetPack");
    // const govToken = await govTokenFactory.deploy();
    // await govToken.deployed();
    // console.log('TOKEN ADDRESS: ', govToken.address);

    const govTokenFactory = await hre.ethers.getContractAt("JetPack","0xd0F0C40FCD1598721567F140eBf8aF436e7b97cF",this.admin1);
    for(let i = 0 ; i< DATA.length ;  i++){
      console.log('i = ',DATA[i]['Ethereum_Wallet_Address']);
    }

}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })