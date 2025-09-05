<script setup lang="ts">
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'
import { actions } from 'astro:actions'

const props = defineProps<{
  username: string
}>()


async function logoutAndReload() {
    const { data, error } = await actions.signout()
    console.info(data, error)
    if (data.redirect) {
        window.location.href = data.redirect
    }
}
</script>

<template>
    <dropdown-menu>
        <dropdown-menu-trigger as-child>
            <button class="btn btn-ghost">
            <span>{{ props.username }}</span>
            <span class="ph ph-user" />
            </button>
        </dropdown-menu-trigger>
        <dropdown-menu-content>
            <dropdown-menu-item @select="logoutAndReload">
                <span>Выйти</span>
            </dropdown-menu-item>
        </dropdown-menu-content>
    </dropdown-menu>
</template>
