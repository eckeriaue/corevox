<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
    username: string,
}>()

const isLoading = ref(true)

</script>

<template>
<div
    :class="{
      'ring-base-300': !false,
      'ring-primary': true,
    }"
    class="relative ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
    style="width:300px;height:200px; object-fit: cover; object-position: center;"
>
    <div class="absolute inset-2 size-[calc(100%_-_var(--spacing)*4)]">
        <span class="badge">{{ props.username }}</span>
    </div>
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
