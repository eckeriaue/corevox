<script setup lang="ts">
import FrTextField from './FrTextField.vue'
import FrPasswordField from './FrPasswordField.vue'
import { toast } from 'vue-sonner'
import { ref, onMounted, onUnmounted, computed, unref, toRaw } from 'vue'
import { z } from 'zod'
import { actions } from 'astro:actions'
import { debounce } from 'radashi'
import { socket } from '@/socket'

const channel = socket.channel('login:formvalidation')
const isLoading = ref(false)
const isValid = ref(false)

channel.join().receive('ok', () => {
  console.log('Channel joined')
}).receive('error', () => {
  toast('Невозможно подключиться к серверу')
})

const defaultErrors = () => ({
  email: [],
  password: [],
})

const defaultForm = () => ({
  email: '',
  password: '',
  remember_me: false
})

const errors = ref(defaultErrors())
const form = ref(defaultForm())

const schema = z.object({
  email: z.string().email().min(2).max(100).refine(async data => {
    return new Promise(resolve => {
      channel.push('has_email', { value: data })
        .receive('ok', (payload) => {
          resolve(payload.has_user)
        })
        .receive('error', () => {
          toast('Невозможно проверить email. Сервер недоступен')
          resolve(false)
        })
    })
  }, {
    message: 'Email не зарегестрирован',
    path: ['email']
  }),
  password:  z.string().min(6).max(100)
})

const validate = debounce({ delay: 100 }, async () => {
  const formData = structuredClone(toRaw(unref(form)))
  isLoading.value = true
  const { success, error } = await schema.safeParseAsync(formData)
  isLoading.value = false
  isValid.value = success
  if (error) {
    errors.value = error.flatten().fieldErrors
  } else {
    errors.value = defaultErrors()
  }
})

const disabled = computed(() => isLoading.value || !isValid.value)

function submit() {
  if (disabled.value) return
  isLoading.value = true
  channel.push('login', structuredClone(toRaw(unref(form))))
    .receive('ok', async ({ token, user }: { token: string, user: object }) => {
      const { data } = await actions.signin({ token, user, remember: unref(form).remember_me })
      window.location.href = data.redirect
      isLoading.value = false
    })
    .receive('error', () => {
      toast('Невозможно войти. Сервер не отвечает.')
      isLoading.value = false
    })
}
onMounted(validate)

onUnmounted(() => {
  channel.leave('login')
})

</script>

<template>
    <form
        class="w-md mx-auto"
        @submit.prevent="submit"
    >
        <FrTextField
            label="Email"
            type="email"
            v-model="form.email"
            @update:modelValue="validate()"
            :error-messages="errors.email"
        />
        <FrPasswordField
            label="Пароль"
            v-model="form.password"
            @update:modelValue="validate()"
            :error-messages="errors.password"
        />

        <fieldset class="flex items-center mb-8 mt-2 gap-x-2">
            <label for="remember_me">Запомнить меня</label>
            <input
                type="checkbox"
                class="checkbox"
                id="remember_me"
                name="remember_me"
                v-model="form.remember_me"
            >

        </fieldset>


        <button
            class="btn btn-primary w-full"
            type="submit"
            :disabled
        >
            Войти
        </button>

    </form>
</template>
