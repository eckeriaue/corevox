<script setup lang="ts">
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  // SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarFooter
} from "@/components/ui/sidebar"

import { SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar'

const props = defineProps<{
  me: {
    id: string
    email: string
    username: string
  },
  users: {
    id: string
    email: string
    username: string
  }[]
}>()

const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMic = defineModel<boolean>('enableMicrophone', { default: false })

</script>

<template>
<SidebarProvider>
  <Sidebar>
    <SidebarContent>
        <div class="flex items-center px-2 h-16">
           <a href="/"  class="btn btn-ghost text-xl">CoreVox</a>
       </div>
      <SidebarGroup>
        <SidebarGroupContent>
          <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton>
                    <span>{{ me.username }}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem v-for="user in props.users" :key="user.id">
                <SidebarMenuButton>
                    <span>{{ user.username }}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    </SidebarContent>
    <SidebarFooter class="border-t border-base-300">
        <SidebarMenuItem>
            <section class="flex items-center gap-x-4 w-full">
                <span>{{ props.me.username }}</span>
                <nav>
                    <ul class="flex gap-x-2">
                        <li>
                            <button
                                class="btn btn-ghost btn-sm btn-circle"
                                @click="enableMic = !enableMic"
                            >
                                    <span class="ph" :class="{ 'ph-microphone': enableMic, 'ph-microphone-slash': !enableMic }" />
                                </button>
                        </li>
                        <li>
                            <button
                                class="btn btn-ghost btn-sm btn-circle"
                                @click="enableCamera = !enableCamera"
                            >
                                    <span class="ph" :class="{ 'ph-video-camera': enableCamera, 'ph-video-camera-slash': !enableCamera }" />
                                </button>
                        </li>
                        <li>
                            <button
                                class="btn btn-ghost btn-sm btn-circle"
                                >
                                    <span class="ph ph-monitor-play" />
                                </button>
                        </li>
                    </ul>
                </nav>
            </section>
        </SidebarMenuItem>
    </SidebarFooter>
  </Sidebar>
  <div class="flex flex-col justify-between">
      <ul>
          <li class="relative">
              <div class="absolute -top-8 left-1 -translate-y-1/2 block">
                <SidebarTrigger />
              </div>
          </li>
      </ul>
  </div>
  <div class="p-4 grow">
      <slot />
  </div>
</SidebarProvider>
</template>
