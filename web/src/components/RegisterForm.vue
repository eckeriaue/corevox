<script setup lang="ts">
import { socket } from '../socket'

socket.channel('register:form', {}).join().receive('ok', () => {
    console.log('Joined successfully')
})

</script>

<template>
    <form
        action="/register"
        method="POST"
        class="flex flex-col gap-y-3 mx-auto max-w-md"
    >
        <div>
            <label for="name">Ваш ник:</label>
            <input
                class="input w-full"
                type="text"
                id="name"
                name="name"
                required
            >
        </div>
        <div>
            <label for="email">Email:</label>
            <input
                class="input w-full"
                type="email"
                id="email"
                name="email"
                required
            >
        </div>

        <div>
            <label for="password">Пароль:</label>
            <input
                class="input w-full"
                type="password"
                id="password"
                name="password"
                required
            >
        </div>

        <div>
            <label for="confirm_password">Подтвердите пароль:</label>
            <input
                class="input w-full"
                type="password"
                id="confirm_password"
                name="confirm_password"
                required
            >
        </div>

        <div class="flex items-center mb-8 mt-2 gap-x-2">
            <label for="remember_me">Запомнить меня</label>
            <input type="checkbox" class="checkbox" id="remember_me" name="remember_me">
        </div>

        <button class="btn btn-primary" type="submit">Зарегистрироваться</button>
    </form>
</template>
