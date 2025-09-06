const config = {
  iceServers: [
    {
      urls: [import.meta.env.PUBLIC_STUN_SERVER_URL]
    },
    {
      urls: "stun:stun.l.google.com:19302"
    },
    {
      urls: [import.meta.env.PUBLIC_TURN_SERVER_URL],
      username: import.meta.env.PUBLIC_TURN_USER,
      credential: import.meta.env.PUBLIC_TURN_PASSWORD
    }
  ],
  // iceTransportPolicy: 'all',
  // iceCandidatePoolSize: 10,
  // bundlePolicy: 'balanced',
  // rtcpMuxPolicy: 'require',
  // sdpSemantics: 'unified-plan',
  // iceCandidateTypeFilter: 'host',
  // iceCandidateTypePriority: {
  //   host: 126,
  //   srflx: 124,
  //   prflx: 122,
  //   relay: 120
  // }
}


export const peerConfig = {
  host: import.meta.env.PUBLIC_SIGNAL_HOST,
  port: parseInt(import.meta.env.PUBLIC_SIGNAL_PORT),
  path: import.meta.env.PUBLIC_SIGNAL_PATH,
  secure: false,
  config
}
