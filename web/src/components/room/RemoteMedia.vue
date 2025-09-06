<script setup lang="ts">
import { ref } from 'vue'

const isLoading = ref(true)

</script>

<template>
<div
    :class="{
      'ring-base-300': !false,
      'ring-primary': true,
    }"
    class="ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
    style="width:300px;height:200px; object-fit: cover; object-position: center;"
>
    <span v-if="isLoading" class="loading loading-spinner loading-xl"></span>
    <video
        v-else
        autoplay
        muted
        playsinline
        ref="video"
    />
</div>
</template>
