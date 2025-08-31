

export class JoinRtc {
  pc
  static configuration = {
    iceServers: [
      { urls: 'stun:stun1.l.google.com:19302' }
    ]
  }

  async mounted() {
    this.pc = new RTCPeerConnection(JoinRtc.configuration)
    const offer = await this.pc.createOffer()
    await this.pc.setLocalDescription(offer)
    const localUserId = this.el.dataset.localUserId
    const remoteUserId = this.el.dataset.remoteUserId

    this.pushEvent('offer', { offer, localUserId, remoteUserId })
  }
}
