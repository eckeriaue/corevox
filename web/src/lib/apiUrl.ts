import { isClient } from "./isClient"


export const apiUrl = isClient() ? import.meta.env.PUBLIC_APP_HTTP_URL : `http://${import.meta.env.PUBLIC_APP_NAME}:4000`
