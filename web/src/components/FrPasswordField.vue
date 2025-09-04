
<script setup lang="ts">
import type { HTMLAttributes } from 'vue'

const props = defineProps<{
  name?: string
  label?: string
  errorMessages?: string[]
  placeholder?: string
  class?: HTMLAttributes['class']
}>()


const modelValue = defineModel<string>({ default: '' })

</script>
<template>
    <fieldset class="fieldset group" :class="props.class">
    <legend class="fieldset-legend">{{ label }}</legend>
    <input
        type="password"
        class="input w-full"
        :placeholder
        v-model="modelValue"
    />
    <p
        class="label text-color-error group-focus-within:hidden"
        :class="{ 'hidden': modelValue.length === 0 }"
        v-for="error in errorMessages">{{ error }}</p>
    </fieldset>
</template>
