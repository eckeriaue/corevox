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

</script>

<template>
    <Dialog>
      <DialogTrigger as-child>
        <button class="btn btn-primary" type="button">Создать комнату</button>
      </DialogTrigger>
      <DialogContent>
        <form>
            <DialogHeader>
                <DialogTitle>Cоздание комнаты</DialogTitle>
                <DialogDescription>
                    Создайте комнату, чтобы начать общение с другими пользователями.
                </DialogDescription>
            </DialogHeader>

            <div class="mb-8">
                <fr-text-field
                    label="Топик"
                    name="roomTopicName"
                    autocomplete="off"
                />
                <fr-password-field
                    name="roomPassword"
                    autocomplete="off"
                    label="Пароль для комнаты (необязательно)"
                />
                <fieldset class="fieldset w-full">
                  <legend class="fieldset-legend">Описание комнаты (необязательно)</legend>
                  <textarea class="textarea h-24 w-full" placeholder="Описание комнаты"></textarea>
                </fieldset>
            </div>

            <DialogFooter>
                <button class="btn btn-primary" type="submit">Создать</button>
            </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
</template>
