<script setup lang="ts">
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'

import FrTextField from '@/components/FrTextField.vue'
import FrPasswordField from '@/components/FrPasswordField.vue'
import { z } from 'zod'
import { ref, unref, toRaw } from 'vue'
import { debounce, isString, } from 'radashi'
import type { Channel } from 'phoenix'
import { useMe } from '@/lib'

type Room = {
  id: string,
  description: string,
  name: string
}

const props = defineProps<{
  channel: Channel
}>()

const emit = defineEmits<{
  create: [room: Room]
}>()

const { me } = useMe()
const isOpen = ref(false)



const isValid = ref(false)

const defaultErrors = () => ({
  is_private: [],
  name: [],
  password: [],
  description: []
})

const errors = ref(defaultErrors())

const defaultForm = () => ({
  is_private: false,
  name: '',
  password: null,
  description: null
})

const form = ref(defaultForm())

const schema = z.object({
  name: z.string().min(2).max(100),
  password: z.string().max(100).optional().nullable(),
  description: z.string().max(1000).optional().nullable(),
  is_private: z.boolean().default(false)
})

const validate = debounce({ delay: 100 }, () => {
  const { success, error } = schema.safeParse(structuredClone(toRaw(unref(form))))
  if (error) {
    errors.value = z.flattenError(error).fieldErrors
  } else {
    errors.value = defaultErrors()
  }
  isValid.value = success
})

function createRoom() {
  const formData = structuredClone(toRaw(unref(form)))
  if (isString(formData.password) && formData.password!.length === 0) {
    formData.password = null
  }
  if (isString(formData.description) && formData.description!.length === 0) {
    formData.description = null
  }
  if (me.value) {
    Reflect.set(formData, 'owner_id', me.value.id)
    props.channel.push('create_room', formData)
      .receive('ok', ({ room }: { room: Room }) => {
        isOpen.value = false
        emit('create', room)
      })
      .receive('error', (response) => {
        console.error('Failed to create room:', response)
    })
  }
}

</script>

<template>
    <Dialog v-model:open="isOpen">
      <DialogTrigger as-child>
        <button class="btn btn-primary" type="button">Создать комнату</button>
      </DialogTrigger>
      <DialogContent>
        <form @input="validate" @submit.prevent="createRoom">
            <DialogHeader>
                <DialogTitle>Cоздание комнаты</DialogTitle>
                <DialogDescription>
                    Создайте комнату, чтобы начать общение с другими пользователями.
                </DialogDescription>
            </DialogHeader>

            <div class="mb-8 mt-8">

                <label class="label mb-2">
                  <input type="checkbox" v-model="form.is_private" class="toggle" />
                  <span class="text-sm">Приватная комната</span>
                </label>

                <fr-text-field
                    label="Топик"
                    name="roomTopicName"
                    autocomplete="off"
                    v-model="form.name"
                />
                <fr-password-field
                    name="roomPassword"
                    autocomplete="off"
                    label="Пароль для комнаты (необязательно)"
                    v-model="form.password"
                />
                <fieldset class="fieldset w-full">
                  <legend class="fieldset-legend">Описание комнаты (необязательно)</legend>
                  <textarea class="textarea h-24 w-full" placeholder="Описание комнаты"
                  v-model="form.description"></textarea>
                </fieldset>
            </div>

            <DialogFooter>
                <button
                    class="btn btn-primary"
                    type="submit"
                    :disabled="!isValid"
                >
                    Создать
                </button>
            </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
</template>
