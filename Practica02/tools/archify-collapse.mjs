/**
 * Inyecta grupos colapsables en el HTML generado por Archify.
 *
 * Archify no tiene soporte nativo de collapse, asi que este post-proceso anade
 * un nodo resumen por grupo. Decisiones de diseno (verificadas contra el
 * viewer): el estado colapsado se aplica con CSS estatico, sin mutar el DOM al
 * arrancar, porque el reader de Archify mide `data-reader-layout` en
 * requestAnimationFrame y cualquier cambio tardio hace que waitForStableLayout
 * nunca converja. Los resúmenes NO declaran data-node-id para que el reader no
 * intente resolver un passport inexistente.
 *
 * Uso: node tools/archify-collapse.mjs <ruta-al-html>
 */
import { readFileSync, writeFileSync } from 'node:fs';

const GROUPS = [
  {
    id: 'pantallas',
    members: ['counter_funcs', 'counter_simple'],
    edges: ['main-to-funcs', 'fonts-to-funcs', 'fonts-to-simple'],
    fill: 'c-frontend',
    text: 't-frontend',
    label: 'presentation/counter/',
    sublabel: 'CounterFunctionsScreen y CounterScreen',
    tag: '2 pantallas',
    x: 510, y: 244, w: 300, h: 52
  },
  {
    id: 'targets',
    members: ['android', 'ios', 'linux', 'macos', 'web', 'windows'],
    edges: ['build-to-android', 'build-to-ios', 'build-to-linux', 'build-to-macos', 'build-to-web', 'build-to-windows'],
    fill: 'c-external',
    text: 't-external',
    label: 'Targets de compilación',
    sublabel: 'android · ios · linux · macos · web · windows',
    tag: '6 destinos',
    x: 311, y: 436, w: 360, h: 52
  }
];

const MARKER = 'archify-collapse: grupos plegables';
const attr = (v) => String(v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/** Marca nodos y aristas de cada grupo con atributos propios. */
const tagMembers = (html) => GROUPS.reduce((acc, g) => {
  let out = acc;
  g.members.forEach((id) => {
    out = out.split(`data-node-id="${id}"`).join(`data-node-id="${id}" data-archify-member="${g.id}"`);
  });
  g.edges.forEach((id) => {
    out = out.split(`data-edge-id="${id}"`).join(`data-edge-id="${id}" data-archify-edge="${g.id}"`);
  });
  return out;
}, html);

const summarySvg = (g) => {
  const cx = g.x + g.w / 2;
  const cy = g.y + g.h / 2;
  return `
        <g class="archify-summary" data-archify-summary="${g.id}" tabindex="0" role="button" aria-expanded="false" aria-label="${attr(g.label)}: ${attr(g.sublabel)}">
          <title>${attr(g.label)} — ${attr(g.sublabel)} (${attr(g.tag)})</title>
          <rect x="${g.x}" y="${g.y}" width="${g.w}" height="${g.h}" rx="6" class="c-mask"/>
          <rect x="${g.x}" y="${g.y}" width="${g.w}" height="${g.h}" rx="6" class="${g.fill}" stroke-width="1.5" stroke-dasharray="5 3"/>
          <text x="${cx}" y="${cy - 4}" class="t-primary" font-size="11" font-weight="600" text-anchor="middle">${attr(g.label)}</text>
          <text x="${cx}" y="${cy + 11}" class="t-muted" font-size="9" text-anchor="middle">${attr(g.sublabel)}</text>
          <text x="${cx}" y="${cy + 21}" class="${g.text}" font-size="7" text-anchor="middle">▸ ${attr(g.tag)} · clic para expandir</text>
        </g>`;
};

const styleFor = (g) => {
  const sel = `[data-archify-member="${g.id}"], [data-archify-edge="${g.id}"]`;
  return `
    ${sel} { display: none !important; }
    html[data-archify-open~="${g.id}"] ${sel} { display: inline !important; }
    html[data-archify-open~="${g.id}"] [data-archify-summary="${g.id}"] { display: none; }
    .archify-summary { cursor: pointer; }
    .archify-summary:hover rect:nth-of-type(2) { stroke-width: 2.4; }
    .archify-summary:focus { outline: none; }
    .archify-summary:focus-visible rect:nth-of-type(2) { stroke-width: 2.4; }`;
};

const script = `
    (function () {
      var open = document.documentElement;
      function toggle(id) {
        var cur = (open.getAttribute('data-archify-open') || '').split(/\\s+/).filter(Boolean);
        var i = cur.indexOf(id);
        if (i >= 0) cur.splice(i, 1); else cur.push(id);
        if (cur.length) open.setAttribute('data-archify-open', cur.join(' '));
        else open.removeAttribute('data-archify-open');
        document.querySelectorAll('[data-archify-summary="' + id + '"]').forEach(function (s) {
          s.setAttribute('aria-expanded', i >= 0 ? 'false' : 'true');
        });
      }
      document.addEventListener('click', function (e) {
        var s = e.target.closest && e.target.closest('[data-archify-summary]');
        if (s) toggle(s.getAttribute('data-archify-summary'));
      });
      document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ') return;
        var s = document.activeElement && document.activeElement.closest
          ? document.activeElement.closest('[data-archify-summary]') : null;
        if (s) { e.preventDefault(); toggle(s.getAttribute('data-archify-summary')); }
      });
    })();
`;

const target = process.argv[2];
if (!target) {
  console.error('uso: node tools/archify-collapse.mjs <ruta-al-html>');
  process.exit(1);
}

let html = readFileSync(target, 'utf8');
if (html.includes(MARKER)) {
  console.log('ya inyectado: ' + target);
  process.exit(0);
}

html = tagMembers(html);

const host = html.lastIndexOf('</svg>');
if (host < 0) {
  console.error('no se encontro </svg> en ' + target);
  process.exit(1);
}
html = html.slice(0, host) + GROUPS.map(summarySvg).join('') + '\n' + html.slice(host);

const style = `\n    /* ${MARKER} */${GROUPS.map(styleFor).join('')}\n`;
html = html.replace('</head>', style + '</head>');
html = html.replace('</body>', script + '</body>');

writeFileSync(target, html, 'utf8');
console.log('colapso inyectado en ' + target);
