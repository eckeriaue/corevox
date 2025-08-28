
export class LeaveRoom {
  destroyAbortController = new AbortController()
  mounted() {
    window.addEventListener('beforeunload', () => {
      this.pushEvent('leave_room', {})
    }, { signal: this.destroyAbortController.signal })
  }

  destroyed() {
    this.destroyAbortController.abort()
  }
}
