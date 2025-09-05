<script setup lang="ts">
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarFooter
} from "@/components/ui/sidebar"

import { SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar'

const items = [
  {
    title: "Home",
  },
  {
    title: "Inbox",
  },
  {
    title: "Calendar",
  },
  {
    title: "Search",
  },
  {
    title: "Settings",
  },
];
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
              <SidebarMenuItem v-for="item in items" :key="item.title">
                <SidebarMenuButton>
                    <span>{{item.title}}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    </SidebarContent>
    <SidebarFooter class="border-t border-base-300">
        <SidebarMenuItem>
        <SidebarMenuButton>
            <ul>
                <li>
                    test
                </li>
            </ul>
        </SidebarMenuButton>
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
  <slot />
</SidebarProvider>
</template>
