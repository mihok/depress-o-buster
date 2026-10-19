// Rasterize an SVG to an exact-size PNG with a transparent or solid background.
// Usage: node rasterize.js <svg> <out.png> <size> [bg|transparent]
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const fs = require('fs');
(async () => {
  const [svgPath, outPath, sizeStr, bg = 'transparent'] = process.argv.slice(2);
  const size = Number(sizeStr);
  let svg = fs.readFileSync(svgPath, 'utf8');
  // Force the root element to the requested pixel size.
  svg = svg.replace(/<svg([^>]*?)\swidth="[^"]*"/, '<svg$1').replace(/<svg([^>]*?)\sheight="[^"]*"/, '<svg$1')
           .replace('<svg', `<svg width="${size}" height="${size}"`);
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
  const page = await browser.newPage({ deviceScaleFactor: 1, viewport: { width: size, height: size } });
  const style = bg === 'transparent' ? 'background:transparent' : `background:${bg}`;
  await page.setContent(`<!doctype html><html><body style="margin:0;${style}">${svg}</body></html>`);
  await page.screenshot({ path: outPath, omitBackground: bg === 'transparent', clip: { x: 0, y: 0, width: size, height: size } });
  await browser.close();
  console.log('wrote', outPath, size);
})().catch(e => { console.error(e); process.exit(1); });
