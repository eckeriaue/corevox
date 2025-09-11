const config = {
  iceServers: [
    { urls: import.meta.env.PUBLIC_STUN_SERVER_URL },
    // { urls: 'stun:stun.l.google.com:19302' },
    // { urls: 'stun:stun1.l.google.com:19302' },
    {
      urls: [
        import.meta.env.PUBLIC_TURN_SERVER_URL,
        import.meta.env.PUBLIC_TURN_SERVER_URL + '?transport=udp',
        import.meta.env.PUBLIC_TURN_SERVER_URL + '?transport=tcp',
      ],
      username: import.meta.env.PUBLIC_TURN_USER,
      credential: import.meta.env.PUBLIC_TURN_PASSWORD
    },
  ],
}


export const peerConfig = {
  host: import.meta.env.PUBLIC_SIGNAL_HOST,
  port: parseInt(import.meta.env.PUBLIC_SIGNAL_PORT),
  path: import.meta.env.PUBLIC_SIGNAL_PATH,
  secure: import.meta.env.PUBLIC_SIGNAL_SECURE === 'true',
  config
}
