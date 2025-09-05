<script setup lang="ts">
import { useMe } from '@/lib'
import UserProfile from './UserProfile.vue'
import SignNav from './SignNav.vue'

const { isAuth, error, isLoading } = useMe()


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
    <div v-else-if="isAuth">
        <user-profile />
    </div>
    <div v-else-if="!isAuth" class="flex-none">
        <sign-nav />
    </div>
</div>
</template>
