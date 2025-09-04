
if (typeof window !== 'undefined') {
  console.info('Barba initialized')
  import('@barba/core').then(m => m.default.init())
}
