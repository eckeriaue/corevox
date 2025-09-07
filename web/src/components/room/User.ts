export type User = {
  id: number
  rtcId: string
  username: string
  email: string
  joined_at: Date
  streams: MediaStream[]
  enableMicrophone: boolean
  enableCamera: boolean
}
