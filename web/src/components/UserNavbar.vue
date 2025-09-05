<script setup lang="ts">
import { useMe } from '../lib'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '../components/ui/dropdown-menu'

const { me, error, isLoading, logout, login } = useMe()

function logoutAndReload() {
    logout()
    location.reload()
}

</script>

<template>
<div>
    <div v-if="isLoading">
        <span>Выполняется вход</span>
        <span class="loading loading-ball loading-md"></span>
    </div>
    <div v-else-if="error">
        {{ error }}
    </div>
    <div v-else-if="me">
        <dropdown-menu>
            <dropdown-menu-trigger>
                <button class="btn btn-ghost">
                  <span>{{ me.username }}</span>
                  <span class="ph ph-user" />
                </button>
            </dropdown-menu-trigger>
            <dropdown-menu-content>
                <dropdown-menu-item @select="logoutAndReload">
                    <span>Выйти</span>
                </dropdown-menu-item>
            </dropdown-menu-content>
        </dropdown-menu>
    </div>
    <div v-else-if="me === null" class="flex-none">
        <ul class="menu menu-horizontal px-1">
            <li><a href="/register">Зарегистрироваться</a></li>
            <li><a href="/login">Войти</a></li>
        </ul>
    </div>
</div>
</template>
