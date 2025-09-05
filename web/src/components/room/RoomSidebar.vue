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
                <SidebarMenuButton asChild>
                    <span>{{item.title}}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    </SidebarContent>
  </Sidebar>
  <div class="flex flex-col border-r border-base-300 justify-between">
      <ul>
          <li>
              <SidebarTrigger />
          </li>
      </ul>
  </div>
  <slot />
</SidebarProvider>
</template>
