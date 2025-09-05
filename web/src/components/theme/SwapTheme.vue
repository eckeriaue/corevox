<template>
<button
    @click="changeTheme"
    class="btn btn-ghost btn-circle"
>
    <span class="text-xl light ph ph-sun" />
    <span class="text-xl dark ph ph-moon" />
</button>
</template>

<script setup>
import { actions } from 'astro:actions'

async function changeTheme() {
  const currentTheme = document.documentElement.dataset.theme
  if (currentTheme === 'light') {
    document.documentElement.dataset.theme = 'dark'
  } else if (currentTheme === 'dark') {
    document.documentElement.dataset.theme = 'light'
  }
  await actions.changeTheme({ theme: document.documentElement.dataset.theme })
}
</script>

<style scoped>

[data-theme="light"] .light {
  display: inline;
}

[data-theme="dark"] .light {
  display: none;
}

[data-theme="dark"] .dark {
  display: inline;
}

[data-theme="light"] .dark {
  display: none;
}

</style>
