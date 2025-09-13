<script setup lang="ts">
import { Primitive, type PrimitiveProps } from "reka-ui"


defineProps<PrimitiveProps>()

</script>

<template>
<Primitive
    data-glare
    :as="as"
    :as-child="asChild"
>
    <slot />
</Primitive>
</template>

<style>
[data-glare] {
    box-shadow: 2px 2px 0px 0px var(--color-neutral), 1px 1px 0 0 inset rgba(255,255,255,.1);
    &:active {
        translate: -1px -1px;
        box-shadow: 1px 1px 0 0 inset rgba(255,255,255,.1);
    }
}
</style>
