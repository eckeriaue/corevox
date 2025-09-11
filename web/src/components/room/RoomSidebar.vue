<script setup lang="ts">
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarFooter
} from "@/components/ui/sidebar"
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'
import type { User } from './users'

import { SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar'

const props = defineProps<{
  users: User[]
}>()

const emit = defineEmits<{
  'stream-screen': []
}>()

const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMic = defineModel<boolean>('enableMicrophone', { default: false })

</script>

<template>
<SidebarProvider>
  <Sidebar>
    <SidebarContent>
        <div class="flex items-center px-2 h-16">
           <a href="/" data-astro-reload class="btn btn-ghost text-xl">CoreVox</a>
       </div>
      <SidebarGroup>
        <SidebarGroupContent>
          <SidebarMenu>
              <SidebarMenuItem v-for="user in props.users" :key="user.id">
                <SidebarMenuButton>
                    <span>{{ user.username }}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    </SidebarContent>
    <SidebarFooter class="border-t border-base-300 bg-base-100">
        <SidebarMenuItem>
            <section class="flex items-center gap-x-4 w-full justify-between">
                <nav>
                    <ul class="flex gap-x-2">
                        <li>
                            <button
                                class="btn btn-ghost btn-sm btn-circle"
                                type="button"
                                @click="enableMic = !enableMic"
                            >
                                    <span class="ph" :class="{ 'ph-microphone': enableMic, 'ph-microphone-slash': !enableMic }" />
                                </button>
                        </li>
                        <li>
                            <button
                                class="btn btn-ghost btn-sm btn-circle"
                                type="button"
                                @click="enableCamera = !enableCamera"
                            >
                                    <span class="ph" :class="{ 'ph-video-camera': enableCamera, 'ph-video-camera-slash': !enableCamera }" />
                                </button>
                        </li>
                    </ul>
                </nav>


                <div>
                    <dropdown-menu>
                        <dropdown-menu-trigger as-child>
                            <button type="button" class="btn btn-ghost btn-sm btn-circle">
                                <span class="ph ph-dots-nine text-xl" />
                            </button>
                        </dropdown-menu-trigger>

                        <dropdown-menu-content>
                            <dropdown-menu-item @select="emit('stream-screen')">
                                <span class="ph ph-monitor-play" />
                                <span class="font-medium text-xs">Транслировать экран (включить/отключить)</span>
                            </dropdown-menu-item>
                        </dropdown-menu-content>
                    </dropdown-menu>
                </div>

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
  <div class="p-4 grow relative">
      <slot />
  </div>
</SidebarProvider>
</template>
