<script setup lang="ts">
import { onMounted, toRaw, onUnmounted, reactive, ref, computed } from 'vue'
import { socket } from '../socket'
import { debounce } from 'radashi'
import FrTextField from './FrTextField.vue'
import FrPasswordField from './FrPasswordField.vue'
import { z } from 'zod'


if (typeof window !== 'undefined') {
  z.config(z.locales.ru())
}

const formStatus = ref<'ready' | 'loading'>('ready')

const channel = socket.channel('register:formvalidation', {})
channel.join().receive('ok', () => {
    console.log('Joined successfully')
})

const checkUniqueness = (field: string, value: string) => {
  return new Promise((resolve) => {
    channel.push(`check_${field}`, { value })
      .receive('ok', (resp) => {
        resolve(resp.unique)
      })
      .receive('error', (resp) => {
        console.error('Error in check:', resp)
        resolve(false)
      })
      .receive('timeout', () => {
        console.error('Timeout')
        resolve(false)
      })
  });
}


const errors = ref({
  username: [],
  email: [],
  password: [],
  confirm_password: []
})

const form = reactive({
  username: '',
  email: '',
  password: '',
  confirm_password: '',
})

const schema = z.object({
  username: z.string().nonempty().max(20).default('')
    .refine(async (value) => await checkUniqueness('username', value), {
      message: 'Имя пользователя уже занято',
    }),
  email: z.string().nonempty().email().default('')
    .refine(async (value) => await checkUniqueness('email', value), {
      message: 'Email уже зарегистрирован',
    }),
  password: z.string().nonempty().min(8).max(100).default(''),
  confirm_password: z.string().nonempty().min(8).max(100).default('')
}).refine((data) => data.password === data.confirm_password, {
  message: 'Пароли не совпадают',
  path: ['confirm_password'],
})


const disabled = computed(() => {
  return !form.username || !form.email || !form.password || !form.confirm_password || form.password !== form.confirm_password
})

const validate = debounce({ delay: 100 }, async () => {
  formStatus.value = 'loading'
  const { error } = await schema.safeParseAsync(structuredClone(toRaw(form)))
  formStatus.value = 'ready'
  errors.value = z.flattenError(error).fieldErrors
})

onMounted(validate)

onUnmounted(() => {
  channel.leave()
})

</script>

<template>
    <form
        @input="validate"
        class="flex flex-col mx-auto w-md"
    >

        <fr-text-field
            name="username"
            required
            class="w-full"
            label="Ваш ник"
            v-model="form.username"
            :error-messages="errors.username"
        />
        <fr-text-field
            name="email"
            class="w-full"
            required
            label="Email"
            v-model="form.email"
            :error-messages="errors.email"
        />

        <fr-password-field
            name="password"
            required
            label="Пароль"
            class="w-full"
            v-model="form.password"
            :error-messages="errors.password"
        />

        <fr-password-field
            name="confirmPassword"
            required
            class="w-full"
            label="Подтвердите пароль"
            v-model="form.confirm_password"
            :error-messages="errors.confirm_password"
        />

        <fieldset class="flex items-center mb-8 mt-2 gap-x-2">
            <label for="rememberMe">Запомнить меня</label>
            <input type="checkbox" class="checkbox" id="rememberMe" name="rememberMe">
        </fieldset>

        <button
            class="btn btn-primary"
            type="submit"
            :disabled
        >
            Зарегистрироваться
            <span v-if="formStatus === 'loading'" class="loading loading-ball loading-md"></span>
        </button>
    </form>
</template>
