import type { App } from 'vue'
import { isClient } from '@/lib'
import { z } from 'zod'

export default function (app: App) {
  if(isClient()) {
    z.config(z.locales.ru())
  }
}
