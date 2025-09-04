
<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { computed, ref } from 'vue'

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
const canSee = ref(false)

</script>
<template>
    <fieldset class="fieldset group" :class="props.class">
    <legend class="fieldset-legend">{{ label }}</legend>
    <label
        class="w-full input"
        :class="{
          'input-error': hasErrors && modelValue.length > 0,
        }"
    >
        <input
            :type="canSee ? 'text' : 'password'"
            class="w-full"
            :placeholder
            v-model="modelValue"
        />
        <button
            type="button"
            class="not-[&:hover]:opacity-80 cursor-pointer block ph"
            @click="canSee = !canSee"
            :class="{
              'ph-eye': canSee,
              'ph-eye-slash': !canSee,
            }"
        />
    </label>
    <p
        class="label text-error group-focus-within:hidden"
        :class="{ 'hidden': modelValue.length === 0 }"
        v-for="error in errorMessages">{{ error }}</p>
    </fieldset>
</template>
