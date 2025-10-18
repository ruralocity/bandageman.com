
(function() {
  // fetch original file name
  var s = document.scripts[document.scripts.length - 1]
  var file = s.getAttribute('data-original-file')
  if (!file) throw new Error('Missing data-original-file attribute.')

  // detect iOS
  var isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream

  // strip vendor prefixes
  window.AudioContext = window.AudioContext
    || window.webkitAudioContext
    || window.mozAudioContext
    || window.oAudioContext
    || window.msAudioContext

  // make AudioContext a singleton so we control it
  var ctx = new window.AudioContext
  window.AudioContext = function() { return ctx }

  // if not iOS, just load the game directly
  if (!isIOS) {
    var s = document.createElement('script')
    s.setAttribute('src', file)
    document.body.appendChild(s)
    return
  }

  // iOS-specific overlay below

  // create overlay
  var o = document.createElement('div')
  o.innerHTML = '<div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; gap: 20px;">' +
    '<img src="/images/bandageman-transparent.png" alt="" style="max-width: 100px; height: auto;">' +
    '<span>tap to play</span>' +
    '</div>'
  o.style.cssText = [
    'position: fixed',
    'top: 0',
    'left: 0',
    'right: 0',
    'bottom: 0',
    'background: rgb(0, 0, 0)',
    'background: rgba(0, 0, 0, 0.9)',
    'color: white',
    'text-align: center',
    'font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    'font-size: 18px',
  ].map(function(p) { return p + ';' }).join('')
  document.body.appendChild(o)

  // disable scrolling
  document.body.style.overflow = 'hidden'
  o.onclick = function() {

    // ...until overlay is clicked
    document.body.style.overflow = ''

    // then unlock AudioContext on iOS
    var buffer = ctx.createBuffer(1, 1, 22050)
    var source = ctx.createBufferSource()
    source.connect(ctx.destination)
    if (source.noteOn) source.noteOn(0)
    else source.start(0)

    // dynamically load original script
    var s = document.createElement('script')
    s.setAttribute('src', file)
    document.body.appendChild(s)

    // and delete overlay div
    document.body.removeChild(o)
  }
})()
