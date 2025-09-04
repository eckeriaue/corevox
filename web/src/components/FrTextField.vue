
<script setup lang="ts">
import { computed, type HTMLAttributes } from 'vue'

const props = withDefaults(defineProps<{
  name?: string
  label?: string
  errorMessages?: string[]
  placeholder?: string
  class?: HTMLAttributes['class']
}>(), {
  errorMessages: () => []
})


const modelValue = defineModel<string>({ default: '' })
const hasErrors = computed(() => props.errorMessages.length > 0)

</script>
<template>
    <fieldset class="fieldset group" :class="props.class">
    <legend class="fieldset-legend">{{ label }}</legend>
    <input
        type="text"
        class="input w-full"
        :placeholder
        :class="{
          'input-error': hasErrors && modelValue.length > 0,
        }"
        v-model="modelValue"
    />
    <p
        class="label text-error group-focus-within:hidden"
        :class="{ 'hidden': modelValue.length === 0 }"
        v-for="error in errorMessages">{{ error }}</p>
    </fieldset>
</template>
