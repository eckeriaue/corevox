import { watchEffect, ref, computed, nextTick, onUnmounted, onMounted } from 'vue'
import type { WatchStopHandle } from 'vue'
import { useSessionStorage, useLocalStorage } from '@vueuse/core'
import { apiUrl } from './apiUrl'


export function useMe() {
    const TOKEN_STORAGE_KEY = 'jwt_token'
    const sessionToken = useSessionStorage(TOKEN_STORAGE_KEY, '')
    const localToken = useLocalStorage(TOKEN_STORAGE_KEY, '')
    const token = computed(() => sessionToken.value || localToken.value)
    const isLoading = ref(true)
    const error = ref(null)
    const me = ref(null)

    let watcher: WatchStopHandle | undefined
    onMounted(() => {
      const meRequest = new Request(`${apiUrl}/api/v1/me`, {
        headers: {
          'content-type': 'application/json',
          Authorization: `Bearer ${token.value}`
        }
      })
      watcher = watchEffect(async () => {
          await nextTick()
          if (token.value) {
            isLoading.value = true
            fetch(meRequest.clone())
            .then(response => {
              if (response.status === 401) {
                localToken.value = ''
                sessionToken.value = ''
                location.reload()
                return Promise.resolve()
              }
              return response.json()
            })
            .then(data => me.value = data)
            .catch(err => error.value = err)
            .finally(() => isLoading.value = false)
          } else {
            isLoading.value = false
            me.value = null
          }
      })
    })
    onUnmounted(() => {
      watcher && watcher()
    })


    return {
        me,
        error,
        isAuth: computed(() => me.value !== null),
        isLoading,
        login(token: string, { remember = false } = {}) {
            if (remember) {
                localToken.value = token
            } else {
                sessionToken.value = token
            }
        },
        logout() {
            sessionToken.value = ''
            localToken.value = ''
        }
    }
}
