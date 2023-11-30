<script setup lang="ts">
import { computed, PropType } from "vue";
import BaseCard from "@/components/BaseCard/BaseCard.vue";
import { NftItem } from "../../types/nft";

const emit = defineEmits<{
  (e: "buy", value: number): void;
}>();

const props = defineProps({
  item: {
    type: Object as PropType<NftItem>,
    required: true,
  },
});
const name = computed<string>(() => {
  const url = new URL(props.item.tokenURI);
  const parts = url.pathname.split('/');
  return parts[parts.length - 1].split(".")[0];
});
const tags = computed<string[]>(() => [`backend: ${props.item.attributes.backend}`, `frontend: ${props.item.attributes.frontend}`, `leadership: ${props.item.attributes.leadership}`]);

const buy = () => {
  emit("buy", props.item.tokenId);
}
</script>

<template>
  <div class="item">
    <BaseCard :tags="tags">
      <template #content>
        <div class="item__content">
          <div class="d-flex flex-column">
            <div class="item__title">ID: {{ item.tokenId }}</div>
            <div class="item__title">{{ name }}</div>
          </div>
          <div class="item__subtitle">Price: {{ item.price }} MATIC</div>
          <div class="item__image-wrapper">
            <img :src="item.tokenURI" :alt="name" :title="name" />
          </div>
          <div class="item__description">
            <template v-if="item.sold">
              <div class="item__sold">Sold</div>
              <div>Owner: {{ item.owner }}</div>
            </template>
            <template v-else>
              <div class="item__available" @click="buy"></div>
              <div>Owner: {{ item.owner }}</div>
            </template>
          </div>
        </div>
      </template>
    </BaseCard>
  </div>
</template>

<style scoped lang="scss">
.item {

  &__content {
    display: flex;
    flex-direction: column;
    gap: 0.5em;

    img {
      height: 300px;
      width: 300px;
    }
  }

  &__title {
    font-size: 28px;
    color: var(--color-primary-text);
    text-transform: uppercase;
  }

  &__subtitle {
    font-weight: bold;
  }

  &__available {
    background: var(--color-primary-text);
    padding: 8px;
    text-align: center;
    text-transform: uppercase;
    font-style: normal;
    font-weight: bolder;
    font-size: 18px;
    cursor: pointer;

    &:after {
      content: 'AVAILABLE';
    }

    &:hover::after {
      content: 'BUY';
    }
  }

  &__sold {
    background: red;
    padding: 8px;
    text-align: center;
    text-transform: uppercase;
    font-style: normal;
    font-weight: bolder;
    font-size: 18px;
  }

  &__description {
    font-style: italic;
    font-size: 12px;
  }
}
</style>
