import { isClient } from "./isClient"


export const apiUrl = isClient() ? 'http://localhost:4000' : 'http://corevox_app_dev:4000'
