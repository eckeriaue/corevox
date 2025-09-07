export type User = {
  id: number
  rtcId: string
  username: string
  email: string
  joined_at: Date
  stream: MediaStream
  enableMicrophone: boolean
  enableCamera: boolean
}
