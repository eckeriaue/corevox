<script setup >
import { useMe } from '@/lib/useMe'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'

const { me, logout } = useMe()
function logoutAndReload() {
    logout()
    location.reload()
}
</script>

<template>
<dropdown-menu>
    <dropdown-menu-trigger>
        <button class="btn btn-ghost">
          <span>{{ me?.username }}</span>
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
