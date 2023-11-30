<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { Web3 } from 'web3';
import { smartContractABI, smartContractAddress } from "./configuration/v2";

let myContract;
const nftCount = ref<number>(0);
const accounts = ref<string[]>([]);
const nftList = ref<any[]>([]);

const selectedNft = ref<any>(null);
const selectedTokenId = ref<string>("");
const mintImageUri = ref<string>("");

const selectedAccount = ref<string>("");
const ethereum = computed<any>(() => window.ethereum);

async function checkMetamaskConnection() {
  if (ethereum.value) {
    try {
      accounts.value = await ethereum.value.request({ method: 'eth_requestAccounts' });
      selectedAccount.value = accounts.value[0];
      return true;
    } catch (err) {
      console.log(err)
      return false;
    }
  } else {
    console.log("Metamask Not Found!")
    return false;
  }
}

const totalNFTsMinted = async () => {
  nftCount.value = await myContract.methods.currentTokenId().call();
}

const getNFT = async (_tokenId: string) => {
  const imageURI = await myContract.methods.tokenURI(_tokenId).call();
  const owner = await myContract.methods.ownerOf(_tokenId).call();
  return { id: _tokenId, owner: owner, imageURI: imageURI };
}

// const getSelectedNft = async () => {
//   selectedNft.value = await getNFT(selectedTokenId.value);
// };

const fetchNfts = async () => {
  for (let n = 1; n < nftCount.value; n++) {
    const nft = await getNFT(String(n));
    nftList.value.push(nft);
  }
};

const fetchUnsoldNfts = async () => {
  const result = await myContract.methods.fetchMarketItems().call();
  console.log(result);
};

const mintNFT = async () => {
  await myContract.methods.mintNFT().send({ from: selectedAccount.value }, (err, res) => {
    if (!err) {
      console.log(res);
    } else {
      console.error(err);
    }
  });
  await setTokenURI();
}

const setTokenURI = async() =>  await myContract.methods.setBaseTokenURI(mintImageUri.value).call();

const transferNFT = (_tokenId: string) => {
  var toAddress = document.getElementById("toAddress").value;
  var tokenId = document.getElementById("tokenId").value;
  myContract.methods.transferFrom(selectedAccount.value, toAddress, tokenId).send({ from: selectedAccount.value }, function (err, res) {
    if (!err) {
      console.log(res);
    } else {
      console.log(err);
    }
  })
}

onMounted(() => {
  setTimeout(async () => {
    const isMetaMask = await checkMetamaskConnection();
    if (isMetaMask) {
      const web3 = new Web3(ethereum.value as any);
      myContract = await new web3.eth.Contract(smartContractABI, smartContractAddress);
      // await totalNFTsMinted();
      // await fetchNfts();
      await fetchUnsoldNfts();
    } else {
      alert("Metamask not detected!")
    }
  }, 3000)
});
</script>

<template>
  <header>
    <h1>Schengatto NFTs</h1>
    <div>
      <label for="account">Account</label>
      <select v-model="selectedAccount">
        <option v-for="account of accounts" :key="account">{{ account }}</option>
      </select>
    </div>
  </header>

  <main>
    <div v-if="accounts.length">
      <p id="totalNFTs">Total NFTs Minted: {{ nftCount }}</p>
      <div>
        <form @submit.prevent="setTokenURI">
          <input id="mintImageUri" type="url" placeholder="Type Image Uri" v-model="mintImageUri" required>
          <!-- <button class="button" type="submit" :disabled="!mintImageUri">Mint NFT</button> -->
          <button class="button" type="submit" :disabled="!mintImageUri">Set Token URI</button>
        </form>
      </div>
      <hr>
      <!-- <div>
        <input id="tokenId" placeholder="Type tokenId" v-model="selectedTokenId">
        <button class="button" @click="getSelectedNft">Get NFT</button>
      </div> -->
      <div v-for="nft of nftList" :key="nft.id" class="imgdiv">
        <div>Id: {{ nft.id }}</div>
        <img height=100 id="nftpng" :src="nft.imageURI" />
        <p id="nftowner">Owner: {{ nft.owner }}</p>
      </div>
      <hr>
      <!-- <div>
        <button class="button" @click="transferNFT">Transfer NFT</button>
        <input id="toAddress" placeholder="Transfer address">
      </div> -->
    </div>
  </main>

  <footer>Created with Vue 3 for Polygon Blockchain</footer>
</template>

<style scoped></style>
