<script setup lang="ts">
import type { HTMLAttributes } from "vue"
import { PanelLeft } from "lucide-vue-next"
import { cn } from "@/lib/utils"
import { Button } from '@/components/ui/button'
import { useSidebar } from "./utils"

const props = defineProps<{
  class?: HTMLAttributes["class"]
}>()

const { toggleSidebar, state } = useSidebar()
</script>

<template>
<button
    type="button"
    class="btn btn-ghost btn-square"
    data-sidebar="trigger"
    data-slot="sidebar-trigger"
    @click="toggleSidebar"
>
    <span class="ph ph-sidebar" />
</button>
</template>
