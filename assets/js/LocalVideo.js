

export class LocalVideo {
  animationFrame
  mounted() {
    this.animationFrame = requestAnimationFrame(() => {
      navigator.mediaDevices.getUserMedia({ video: true, audio: true })
        .then(stream => {
          this.el.srcObject = stream
          this.el.addEventListener('loadeddata', () => {
            const loadingIndicator = document.querySelector(this.el.dataset.loadingIndicator)
            if (loadingIndicator) {
              loadingIndicator.hidden = true
            }
            this.el.hidden = false
          }, { once: true })
        })
    })
  }

  destroyed() {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
    }
    if (this.el.srcObject) {
      this.el.srcObject.getTracks().forEach(track => track.stop())
    }
  }
}
