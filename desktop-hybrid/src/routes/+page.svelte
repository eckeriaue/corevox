<script lang="ts">
  import { invoke } from '@tauri-apps/api/core'
  import { Button } from 'm3-svelte'
  import '../app.css'

  let name = $state('')
  let greetMsg = $state('')

</script>

<svelte:head>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" />
</svelte:head>

<main style="background-color: rgb(var(--m3-scheme-background));" class=" h-dvh w-full">
<Button variant="filled">Click me</Button>
</main>
