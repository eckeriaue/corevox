<script>
export default {
    props: {
        username: String,
        enableMicrophone: Boolean,
        enableCamera: Boolean,
    },
};
</script>

<template>
    <div class="join">
        <span class="join-item badge">{{ username }}</span>
        <div
        :class="{
            'badge-info': enableMicrophone,
            'badge-error': !enableMicrophone,
        }"
            class="join-item transition-colors badge size-6 badge-soft"
        >
            <span class="ph" :class="{ 'ph-microphone-slash': !enableMicrophone, 'ph-microphone': enableMicrophone }" />
        </div>

        <div
            class="join-item transition-colors badge size-6 badge-soft"
            :class="{
            'badge-error': !enableCamera,
            'badge-info': enableCamera,
            }"
        >
            <span class="ph" :class="{ 'ph-video-camera-slash': !enableCamera, 'ph-video-camera': enableCamera }" />
        </div>

    </div>
</template>
