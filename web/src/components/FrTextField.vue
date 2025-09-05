
<script setup lang="ts">
import { useId, toValue, computed, type HTMLAttributes } from 'vue'

const props = withDefaults(defineProps<{
  name?: string
  label?: string
  errorMessages?: string[]
  placeholder?: string
  autocomplete?: string
  type?: string
  class?: HTMLAttributes['class']
}>(), {
  type: 'text',
  errorMessages: () => []
})

const generatedId = useId()
const inputName = computed(() => props.name || toValue(generatedId))

const modelValue = defineModel<string>({ default: '' })
const hasErrors = computed(() => props.errorMessages.length > 0)

</script>
<template>
    <fieldset class="fieldset group" :class="props.class">
    <legend class="fieldset-legend">{{ label }}</legend>
    <input
        class="input w-full"
        :name="inputName"
        :placeholder
        :type
        :autocomplete
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
