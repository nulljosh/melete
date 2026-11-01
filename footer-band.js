// Footer band: Melete's own things in a row (an idea, a vote up, a post, the pond, a pen, the muse's lyre), cut like a line engraving in plain 2D canvas. Faint rules
// run across the band; inside the glyphs they thicken, and thicken again on the edge facing away from the light, so the
// glyphs look cut into the page. Drawn once per size and theme. Same engine as the Hermes landing; only the glyphs differ.
(function () {
  var band = document.querySelector('.word-band'), canvas = band && band.querySelector('canvas');
  if (!canvas) return;

  // Each glyph is drawn white on a 100 unit square.
  var GLYPHS = [
    function (c) { // an idea
      c.beginPath(); c.arc(50, 38, 24, 0.8 * Math.PI, 0.2 * Math.PI); c.lineTo(60, 68); c.lineTo(40, 68); c.closePath(); c.fill();
      c.fillRect(39, 72, 22, 6); c.fillRect(42, 81, 16, 6);
    },
    function (c) { // a vote up
      c.beginPath(); c.moveTo(50, 12); c.lineTo(84, 50); c.lineTo(62, 50); c.lineTo(62, 88); c.lineTo(38, 88); c.lineTo(38, 50); c.lineTo(16, 50); c.closePath(); c.fill();
    },
    function (c) { // a post on the board
      c.beginPath(); c.roundRect(14, 16, 72, 68, 8); c.fill(); c.globalCompositeOperation = 'destination-out';
      c.fillRect(24, 28, 40, 8); c.fillRect(24, 44, 52, 5); c.fillRect(24, 55, 46, 5); c.fillRect(24, 66, 30, 5);
    },
    function (c) { // a pond, where the ideas sit
      c.lineWidth = 5; [34, 24, 14].forEach(function (r) { c.beginPath(); c.ellipse(50, 60, r * 1.3, r * 0.5, 0, 0, 7); c.stroke(); });
      c.beginPath(); c.arc(50, 34, 8, 0, 7); c.fill();
    },
    function (c) { // a pen
      c.save(); c.translate(50, 50); c.rotate(-Math.PI / 4);
      c.fillRect(-8, -38, 16, 56); c.beginPath(); c.moveTo(-8, 22); c.lineTo(8, 22); c.lineTo(0, 40); c.closePath(); c.fill(); c.restore();
    },
    function (c) { // the muse's lyre
      c.lineWidth = 7; c.beginPath(); c.moveTo(26, 20); c.bezierCurveTo(10, 50, 30, 80, 50, 84); c.bezierCurveTo(70, 80, 90, 50, 74, 20); c.stroke();
      c.fillRect(24, 24, 52, 6); c.lineWidth = 3; [40, 50, 60].forEach(function (x) { c.beginPath(); c.moveTo(x, 30); c.lineTo(x, 80); c.stroke(); });
    }
  ];
  // Lays the glyphs out evenly across a w by h 2D context, in the given colour: one row, or two on a narrow band.
  function grid(w, h) {
    var n = GLYPHS.length, rows = w < h * 3 ? 2 : 1, per = Math.ceil(n / rows);
    return { rows: rows, per: per, cell: Math.min(h / rows * 0.86, w / per) };
  }
  function paint(c, w, h, colour) {
    var g = grid(w, h), gap = (w - g.cell * g.per) / g.per, rowH = h / g.rows;
    GLYPHS.forEach(function (draw, i) {
      var col = i % g.per, row = Math.floor(i / g.per);
      c.save(); c.translate(gap / 2 + col * (g.cell + gap), row * rowH + (rowH - g.cell) / 2 + rowH * 0.04); c.scale(g.cell / 100, g.cell / 100);
      c.fillStyle = c.strokeStyle = colour; draw(c); c.restore();
    });
  }

  var ctx = canvas.getContext('2d');
  if (!ctx) return;
  function layer(w, h) { var c = document.createElement('canvas'); c.width = w; c.height = h; return c; }
  // Horizontal rules `t` px thick, one every `pitch` px, kept only where `mask` is drawn (everywhere when null).
  function rules(w, h, pitch, t, colour, mask) {
    var c = layer(w, h), x = c.getContext('2d');
    x.fillStyle = colour;
    for (var y = 0; y < h; y += pitch) x.fillRect(0, Math.round(y + (pitch - t) / 2), w, Math.max(1, Math.round(t)));
    if (mask) { x.globalCompositeOperation = 'destination-in'; x.drawImage(mask, 0, 0); }
    return c;
  }
  var drawnW = 0;
  function draw() {
    var dpr = Math.min(window.devicePixelRatio || 1, 2), w = Math.round(canvas.clientWidth * dpr), h = Math.round(canvas.clientHeight * dpr);
    if (!w || !h) return;
    drawnW = w; canvas.width = w; canvas.height = h;
    var colour = getComputedStyle(band).color, pitch = Math.min(5 * dpr, Math.max(3 * dpr, grid(w, h).cell / 22)), s = Math.max(2, h * 0.014);
    var glyphs = layer(w, h); paint(glyphs.getContext('2d'), w, h, '#fff');
    // the shadow side: glyph pixels whose neighbour down and right is outside the glyph (light from the top left)
    var shade = layer(w, h), sc = shade.getContext('2d');
    sc.drawImage(glyphs, 0, 0); sc.globalCompositeOperation = 'destination-out'; sc.drawImage(glyphs, -s, -s);
    ctx.globalAlpha = 0.28; ctx.drawImage(rules(w, h, pitch, dpr * 0.75, colour, null), 0, 0);
    ctx.globalAlpha = 1; ctx.drawImage(rules(w, h, pitch, pitch * 0.32, colour, glyphs), 0, 0);
    ctx.drawImage(rules(w, h, pitch, pitch * 0.6, colour, shade), 0, 0);
    // fade out toward the legal line
    var g = ctx.createLinearGradient(0, h * 0.88, 0, h);
    g.addColorStop(0, '#000'); g.addColorStop(1, 'rgba(0,0,0,0)');
    ctx.globalCompositeOperation = 'destination-in'; ctx.fillStyle = g; ctx.fillRect(0, 0, w, h);
    ctx.globalCompositeOperation = 'source-over';
  }
  band.classList.add('live');
  draw();
  // iOS fires resize as the toolbar slides; only a width change needs a redraw
  window.addEventListener('resize', function () { if (Math.round(canvas.clientWidth * Math.min(window.devicePixelRatio || 1, 2)) !== drawnW) draw(); });
  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', draw);
})();
