<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { Web3 } from 'web3';
import { smartContractABI, smartContractAddress } from "./configuration/v2";
import { NftItem } from "./types/nft";
import CardItem from "@/components/CardItem/CardItem.vue";


let myContract;
const accounts = ref<string[]>([]);
const nftList = ref<NftItem[]>([]);

const nftCount = computed<number>(() => nftList.value.length);

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

const fetchUnsoldNfts = async () => {
  const list = await myContract.methods.fetchMarketItems().call();
  nftList.value = list.map((nft: NftItem) => (
    {
      tokenId: nft.tokenId,
      owner: nft.owner,
      seller: nft.seller,
      price: nft.price,
      sold: nft.sold,
      tokenURI: nft.tokenURI,
      attributes: {
        backend: nft.attributes.backend,
        frontend: nft.attributes.frontend,
        leadership: nft.attributes.leadership
      }
    }));
};

const handleBuy = async (_tokenId: string) => { 
  console.log(myContract.methods)
  console.log(_tokenId)
  await myContract.methods.createMarketSale(_tokenId).call();
};

onMounted(() => {
  setTimeout(async () => {
    const isMetaMask = await checkMetamaskConnection();
    if (isMetaMask) {
      const web3 = new Web3(ethereum.value as any);
      myContract = await new web3.eth.Contract(smartContractABI, smartContractAddress);
      await fetchUnsoldNfts();
    } else {
      alert("Metamask not detected!")
    }
  }, 3000)
});
</script>

<template>
  <header>
    <h1>Schengatto NFTs Marketplace</h1>
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
      <div class="showcase">
        <div class="nft-grid">
          <CardItem v-for="nft of nftList" :key="nft.tokenId" :item="nft" @buy="handleBuy" />
        </div>
      </div>
      <hr>
    </div>
  </main>

  <footer>Created with Vue 3 for Polygon Blockchain</footer>
</template>

<style scoped lang="scss">
.showcase {
  margin: 32px auto;
  .nft-grid {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
    justify-content: safe;
  }
}
</style>
