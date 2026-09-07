/* Minimal QR Code generator — byte mode, ECC level L/M.
 * Ported from the original single-page site; validated bit-for-bit against a
 * reference encoder. ESM export: encode(text, { ecl }) -> { matrix, size, version, mask }
 */

const EXP = new Uint8Array(512), LOG = new Uint8Array(256);
(function () {
  let x = 1;
  for (let i = 0; i < 255; i++) { EXP[i] = x; LOG[x] = i; x <<= 1; if (x & 0x100) x ^= 0x11d; }
  for (let i = 255; i < 512; i++) EXP[i] = EXP[i - 255];
})();
function gfMul(a, b) { return (a === 0 || b === 0) ? 0 : EXP[LOG[a] + LOG[b]]; }
function rsGenPoly(degree) {
  let poly = [1];
  for (let d = 0; d < degree; d++) {
    const np = new Array(poly.length + 1).fill(0);
    for (let i = 0; i < poly.length; i++) { np[i] ^= gfMul(poly[i], 1); np[i + 1] ^= gfMul(poly[i], EXP[d]); }
    poly = np;
  }
  return poly;
}
function rsEncode(data, ecLen) {
  const gen = rsGenPoly(ecLen);
  const res = new Array(ecLen).fill(0);
  for (let i = 0; i < data.length; i++) {
    const factor = data[i] ^ res[0];
    res.shift(); res.push(0);
    for (let j = 0; j < ecLen; j++) res[j] ^= gfMul(gen[j + 1], factor);
  }
  return res;
}
const ECB = {
  L: [null,[7,1,19,0,0],[10,1,34,0,0],[15,1,55,0,0],[20,1,80,0,0],[26,1,108,0,0],[18,2,68,0,0],[20,2,78,0,0],[24,2,97,0,0],[30,2,116,0,0],[18,2,68,2,69],[20,4,81,0,0],[24,2,92,2,93],[26,4,107,0,0],[30,3,115,1,116],[22,5,87,1,88],[24,5,98,1,99],[28,1,107,5,108],[30,5,120,1,121],[28,3,113,4,114],[28,3,107,5,108],[28,4,116,4,117],[28,2,111,7,112],[30,4,121,5,122],[30,6,117,4,118],[26,8,106,4,107],[28,10,114,2,115],[30,8,122,4,123],[30,3,117,10,118],[30,7,116,7,117],[30,5,115,10,116],[30,13,115,3,116],[30,17,115,0,0],[30,17,115,1,116],[30,13,115,6,116],[30,12,121,7,122],[30,6,121,14,122],[30,17,122,4,123],[30,4,122,18,123],[30,20,117,4,118],[30,19,118,6,119]],
  M: [null,[10,1,16,0,0],[16,1,28,0,0],[26,1,44,0,0],[18,2,32,0,0],[24,2,43,0,0],[16,4,27,0,0],[18,4,31,0,0],[22,2,38,2,39],[22,3,36,2,37],[26,4,43,1,44],[30,1,50,4,51],[22,6,36,2,37],[22,8,37,1,38],[24,4,40,5,41],[24,5,41,5,42],[28,7,45,3,46],[28,10,46,1,47],[26,9,43,4,44],[26,3,44,11,45],[26,3,41,13,42],[26,17,42,0,0],[28,17,46,0,0],[28,4,47,14,48],[28,6,45,14,46],[28,8,47,13,48],[28,19,46,4,47],[28,22,45,3,46],[28,3,45,23,46],[28,21,45,7,46],[28,19,47,10,48],[28,2,46,29,47],[28,10,46,23,47],[28,14,46,21,47],[28,14,46,23,47],[28,12,47,26,48],[28,6,47,34,48],[28,29,46,14,47],[28,13,46,32,47],[28,40,47,7,48],[28,18,47,31,48]],
};
const ALIGN = [null,[],[6,18],[6,22],[6,26],[6,30],[6,34],[6,22,38],[6,24,42],[6,26,46],[6,28,50],[6,30,54],[6,32,58],[6,34,62],[6,26,46,66],[6,26,48,70],[6,26,50,74],[6,30,54,78],[6,30,56,82],[6,30,58,86],[6,34,62,90],[6,28,50,72,94],[6,26,50,74,98],[6,30,54,78,102],[6,28,54,80,106],[6,32,58,84,110],[6,30,58,86,114],[6,34,62,90,118],[6,26,50,74,98,122],[6,30,54,78,102,126],[6,26,52,78,104,130],[6,30,56,82,108,134],[6,34,60,86,112,138],[6,30,58,86,114,142],[6,34,62,90,118,146],[6,30,54,78,102,126,150],[6,24,50,76,102,128,154],[6,28,54,80,106,132,158],[6,32,58,84,110,136,162],[6,26,54,82,110,138,166],[6,30,58,86,114,142,170]];
function bch(data, poly, len) {
  let d = data << len, gd = 0, t = poly;
  while (t) { gd++; t >>= 1; } gd--;
  let dd = 0; t = d;
  while (t) { dd++; t >>= 1; } dd--;
  while (dd >= gd) {
    d ^= poly << (dd - gd);
    dd = 0; t = d;
    while (t) { dd++; t >>= 1; } dd--;
    if (d === 0) break;
  }
  return d;
}
function formatBits(e, m) { const data = (e << 3) | m; return ((data << 10) | bch(data, 0x537, 10)) ^ 0x5412; }
function versionBits(v) { return (v << 12) | bch(v, 0x1f25, 12); }
const ECC_FORMAT = { L: 1, M: 0 };
function chooseVersion(byteLen, ecl) {
  for (let v = 1; v <= 40; v++) {
    const row = ECB[ecl][v];
    const dataCw = row[1] * row[2] + row[3] * row[4];
    const cci = v <= 9 ? 8 : 16;
    if (4 + cci + byteLen * 8 <= dataCw * 8) return v;
  }
  throw new Error("QR: text too long");
}

export function encode(text, opts = {}) {
  const ecl = opts.ecl || "M";
  const bytes = Array.from(new TextEncoder().encode(text));
  const version = opts.version || chooseVersion(bytes.length, ecl);
  const row = ECB[ecl][version], ecPerBlock = row[0], g1b = row[1], g1d = row[2], g2b = row[3], g2d = row[4];
  const totalDataCw = g1b * g1d + g2b * g2d;
  const bb = [];
  const put = (val, len) => { for (let k = len - 1; k >= 0; k--) bb.push((val >> k) & 1); };
  put(4, 4);
  const cci = version <= 9 ? 8 : 16;
  put(bytes.length, cci);
  for (let b = 0; b < bytes.length; b++) put(bytes[b], 8);
  const cap = totalDataCw * 8;
  for (let tz = 0; tz < 4 && bb.length < cap; tz++) bb.push(0);
  while (bb.length % 8 !== 0) bb.push(0);
  const pad = [0xec, 0x11]; let pi = 0;
  while (bb.length < cap) { put(pad[pi % 2], 8); pi++; }
  const dataCw = [];
  for (let q = 0; q < bb.length; q += 8) { let bv = 0; for (let r = 0; r < 8; r++) bv = (bv << 1) | bb[q + r]; dataCw.push(bv); }
  const blocks = []; let idx = 0;
  for (let gb = 0; gb < g1b; gb++) { blocks.push(dataCw.slice(idx, idx + g1d)); idx += g1d; }
  for (let gb2 = 0; gb2 < g2b; gb2++) { blocks.push(dataCw.slice(idx, idx + g2d)); idx += g2d; }
  const ecBlocks = blocks.map((blk) => rsEncode(blk, ecPerBlock));
  const finalCw = []; const maxData = Math.max(g1d, g2d);
  for (let c = 0; c < maxData; c++) for (let bl = 0; bl < blocks.length; bl++) if (c < blocks[bl].length) finalCw.push(blocks[bl][c]);
  for (let c2 = 0; c2 < ecPerBlock; c2++) for (let bl2 = 0; bl2 < ecBlocks.length; bl2++) finalCw.push(ecBlocks[bl2][c2]);
  const size = version * 4 + 17, mod = [], reserved = [];
  for (let y = 0; y < size; y++) { mod.push(new Array(size).fill(0)); reserved.push(new Array(size).fill(false)); }
  const setF = (x, yy, val) => { mod[yy][x] = val ? 1 : 0; reserved[yy][x] = true; };
  function placeFinder(cx, cy) {
    for (let dy = -1; dy <= 7; dy++) for (let dx = -1; dx <= 7; dx++) {
      const xx = cx + dx, yy = cy + dy;
      if (xx < 0 || xx >= size || yy < 0 || yy >= size) continue;
      const inRing = (dx >= 0 && dx <= 6 && (dy === 0 || dy === 6)) || (dy >= 0 && dy <= 6 && (dx === 0 || dx === 6));
      const inCore = (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
      setF(xx, yy, inRing || inCore);
    }
  }
  placeFinder(0, 0); placeFinder(size - 7, 0); placeFinder(0, size - 7);
  for (let t2 = 8; t2 < size - 8; t2++) { setF(t2, 6, t2 % 2 === 0); setF(6, t2, t2 % 2 === 0); }
  setF(8, size - 8, 1);
  const apos = ALIGN[version], lastA = apos.length - 1;
  for (let a1 = 0; a1 < apos.length; a1++) for (let a2 = 0; a2 < apos.length; a2++) {
    if ((a1 === 0 && a2 === 0) || (a1 === 0 && a2 === lastA) || (a1 === lastA && a2 === 0)) continue;
    const ax = apos[a1], ay = apos[a2];
    for (let ey = -2; ey <= 2; ey++) for (let ex = -2; ex <= 2; ex++) setF(ax + ex, ay + ey, Math.max(Math.abs(ex), Math.abs(ey)) !== 1);
  }
  for (let k1 = 0; k1 <= 8; k1++) { reserved[8][k1] = true; reserved[k1][8] = true; }
  for (let k2 = 0; k2 < 8; k2++) { reserved[8][size - 1 - k2] = true; reserved[size - 1 - k2][8] = true; }
  if (version >= 7) for (let vy = 0; vy < 6; vy++) for (let vx = 0; vx < 3; vx++) { reserved[vy][size - 11 + vx] = true; reserved[size - 11 + vx][vy] = true; }
  const dataBits = [];
  for (let dc = 0; dc < finalCw.length; dc++) for (let db = 7; db >= 0; db--) dataBits.push((finalCw[dc] >> db) & 1);
  let bitIdx = 0, col = size - 1, upward = true;
  while (col > 0) {
    if (col === 6) col--;
    for (let rr = 0; rr < size; rr++) {
      const yrow = upward ? (size - 1 - rr) : rr;
      for (let cc = 0; cc < 2; cc++) {
        const xcol = col - cc;
        if (reserved[yrow][xcol]) continue;
        mod[yrow][xcol] = bitIdx < dataBits.length ? dataBits[bitIdx] : 0;
        bitIdx++;
      }
    }
    col -= 2; upward = !upward;
  }
  function maskFn(m, x, y) {
    switch (m) {
      case 0: return (x + y) % 2 === 0;
      case 1: return y % 2 === 0;
      case 2: return x % 3 === 0;
      case 3: return (x + y) % 3 === 0;
      case 4: return (Math.floor(y / 2) + Math.floor(x / 3)) % 2 === 0;
      case 5: return ((x * y) % 2) + ((x * y) % 3) === 0;
      case 6: return (((x * y) % 2) + ((x * y) % 3)) % 2 === 0;
      case 7: return (((x + y) % 2) + ((x * y) % 3)) % 2 === 0;
    }
  }
  function applyMask(m) {
    const out = [];
    for (let yy = 0; yy < size; yy++) {
      out.push(mod[yy].slice());
      for (let xx = 0; xx < size; xx++) if (!reserved[yy][xx] && maskFn(m, xx, yy)) out[yy][xx] ^= 1;
    }
    return out;
  }
  function drawFormat(grid, m) {
    const fmt = formatBits(ECC_FORMAT[ecl], m);
    for (let p = 0; p < 15; p++) {
      const bitv = (fmt >> p) & 1;
      let x1, y1;
      if (p < 6) { x1 = 8; y1 = p; }
      else if (p === 6) { x1 = 8; y1 = 7; }
      else if (p === 7) { x1 = 8; y1 = 8; }
      else if (p === 8) { x1 = 7; y1 = 8; }
      else { x1 = 14 - p; y1 = 8; }
      grid[y1][x1] = bitv;
      let x2, y2;
      if (p < 8) { x2 = size - 1 - p; y2 = 8; } else { x2 = 8; y2 = size - 15 + p; }
      grid[y2][x2] = bitv;
    }
    grid[size - 8][8] = 1;
  }
  function drawVersion(grid) {
    if (version < 7) return;
    const vb = versionBits(version);
    for (let p = 0; p < 18; p++) {
      const bitv = (vb >> p) & 1, a = Math.floor(p / 3), b2 = p % 3;
      grid[b2 + size - 11][a] = bitv;
      grid[a][b2 + size - 11] = bitv;
    }
  }
  function penalty(grid) {
    let score = 0; const n = size;
    for (let y1 = 0; y1 < n; y1++) {
      let rc = 1, rv = grid[y1][0];
      for (let x1 = 1; x1 < n; x1++) { if (grid[y1][x1] === rv) rc++; else { if (rc >= 5) score += rc - 2; rc = 1; rv = grid[y1][x1]; } }
      if (rc >= 5) score += rc - 2;
    }
    for (let x2 = 0; x2 < n; x2++) {
      let c3 = 1, v3 = grid[0][x2];
      for (let y2 = 1; y2 < n; y2++) { if (grid[y2][x2] === v3) c3++; else { if (c3 >= 5) score += c3 - 2; c3 = 1; v3 = grid[y2][x2]; } }
      if (c3 >= 5) score += c3 - 2;
    }
    for (let y3 = 0; y3 < n - 1; y3++) for (let x3 = 0; x3 < n - 1; x3++) {
      const vv = grid[y3][x3];
      if (vv === grid[y3][x3 + 1] && vv === grid[y3 + 1][x3] && vv === grid[y3 + 1][x3 + 1]) score += 3;
    }
    const p1 = [1,0,1,1,1,0,1,0,0,0,0], p2 = [0,0,0,0,1,0,1,1,1,0,1];
    for (let y4 = 0; y4 < n; y4++) for (let x4 = 0; x4 <= n - 11; x4++) {
      let mm1 = true, mm2 = true;
      for (let kk = 0; kk < 11; kk++) { if (grid[y4][x4 + kk] !== p1[kk]) mm1 = false; if (grid[y4][x4 + kk] !== p2[kk]) mm2 = false; }
      if (mm1) score += 40; if (mm2) score += 40;
    }
    for (let x5 = 0; x5 < n; x5++) for (let y5 = 0; y5 <= n - 11; y5++) {
      let nn1 = true, nn2 = true;
      for (let k3 = 0; k3 < 11; k3++) { if (grid[y5 + k3][x5] !== p1[k3]) nn1 = false; if (grid[y5 + k3][x5] !== p2[k3]) nn2 = false; }
      if (nn1) score += 40; if (nn2) score += 40;
    }
    let dark = 0;
    for (let y6 = 0; y6 < n; y6++) for (let x6 = 0; x6 < n; x6++) dark += grid[y6][x6];
    score += Math.floor(Math.abs((dark * 100) / (n * n) - 50) / 5) * 10;
    return score;
  }
  let best = null, bestScore = Infinity, bestMask = 0;
  const maskList = opts.forceMask != null ? [opts.forceMask] : [0, 1, 2, 3, 4, 5, 6, 7];
  for (let mi = 0; mi < maskList.length; mi++) {
    const m = maskList[mi];
    const g = applyMask(m);
    drawFormat(g, m); drawVersion(g);
    const s = penalty(g);
    if (s < bestScore) { bestScore = s; best = g; bestMask = m; }
  }
  return { matrix: best, size, version, mask: bestMask };
}

/** Render a matrix into an <img> inside `box`. */
export function drawQr(box, text, { scale = 10, dark = "#1E4A2B", light = "#ffffff", px = 190, alt = "QR code" } = {}) {
  const enc = encode(text, { ecl: "M" });
  const m = enc.matrix, n = enc.size, quiet = 4;
  const dim = (n + quiet * 2) * scale;
  const cv = document.createElement("canvas");
  cv.width = dim; cv.height = dim;
  const ctx = cv.getContext("2d");
  ctx.fillStyle = light; ctx.fillRect(0, 0, dim, dim);
  ctx.fillStyle = dark;
  for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) {
    if (m[y][x]) ctx.fillRect((x + quiet) * scale, (y + quiet) * scale, scale, scale);
  }
  const img = new Image();
  img.width = px; img.height = px; img.alt = alt;
  img.style.imageRendering = "pixelated";
  img.src = cv.toDataURL("image/png");
  box.innerHTML = "";
  box.appendChild(img);
}
