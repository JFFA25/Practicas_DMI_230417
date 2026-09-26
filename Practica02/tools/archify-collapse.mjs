/**
 * Inyecta grupos colapsables en el HTML generado por Archify.
 *
 * Archify no tiene soporte nativo de collapse, asi que este post-proceso anade
 * un nodo resumen por grupo. El marco del cluster (structural-frame) se mantiene
 * visible para que el grupo conserve su footprint y no aparezca un hueco.
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

const attr = (v) => String(v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

const summarySvg = (g) => {
  const cx = g.x + g.w / 2;
  const cy = g.y + g.h / 2;
  return `
        <g id="archify-summary-${g.id}" class="archify-summary" data-node-id="archify-summary-${g.id}" data-node-label="${attr(g.label)}" data-archify-summary="${g.id}" tabindex="0" role="button" aria-expanded="false" style="cursor:pointer">
          <title>${attr(g.label)} - ${attr(g.sublabel)}</title>
          <rect x="${g.x}" y="${g.y}" width="${g.w}" height="${g.h}" rx="6" class="c-mask"/>
          <rect x="${g.x}" y="${g.y}" width="${g.w}" height="${g.h}" rx="6" class="${g.fill}" stroke-width="1.5" stroke-dasharray="5 3"/>
          <text data-node-label="" data-detail-anchor="" x="${cx}" y="${cy - 4}" class="t-primary" font-size="11" font-weight="600" text-anchor="middle">${attr(g.label)}</text>
          <text data-detail="context" x="${cx}" y="${cy + 11}" class="t-muted" font-size="9" text-anchor="middle">${attr(g.sublabel)}</text>
          <text data-detail="fine" x="${cx}" y="${cy + 21}" class="${g.text}" font-size="7" text-anchor="middle">▸ ${attr(g.tag)} · clic para expandir</text>
        </g>`;
};

const configJson = JSON.stringify(GROUPS.map((g) => ({
  id: g.id, members: g.members, edges: g.edges
})));

const style = `
    /* archify-collapse: grupos plegables inyectados por tools/archify-collapse.mjs */
    [data-archify-collapse]{ display: none !important; }
    .archify-summary:hover rect:nth-of-type(2){ stroke-width: 2.4; }
    .archify-summary:focus{ outline: none; }
    .archify-summary:focus-visible rect:nth-of-type(2){ stroke-width: 2.4; }
`;

const script = `
    /* archify-collapse */
    (function () {
      var GROUPS = ${configJson};
      var MARK = 'data-archify-collapse';
      var host = document.querySelector('svg');
      if (!host || host.dataset.archifyCollapseReady) return;
      host.dataset.archifyCollapseReady = '1';

      function sel(id) { return '[data-node-id="' + id + '"], [data-edge-id="' + id + '"]'; }

      function parts(g) {
        var out = [];
        g.members.concat(g.edges).forEach(function (id) {
          document.querySelectorAll(sel(id)).forEach(function (el) { out.push(el); });
        });
        return out;
      }

      GROUPS.forEach(function (g) {
        g.els = parts(g);
        g.summary = document.querySelector('[data-archify-summary="' + g.id + '"]');
      });

      function setExpanded(g, expanded) {
        g.els.forEach(function (el) {
          if (expanded) el.removeAttribute(MARK);
          else el.setAttribute(MARK, g.id);
        });
        if (g.summary) {
          g.summary.style.display = expanded ? 'none' : '';
          g.summary.setAttribute('aria-expanded', expanded ? 'true' : 'false');
        }
      }

      function toggle(g) { setExpanded(g, g.summary.style.display === 'none'); }

      GROUPS.forEach(function (g) {
        if (!g.summary) return;
        g.summary.addEventListener('click', function () { toggle(g); });
        g.summary.addEventListener('keydown', function (e) {
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(g); }
        });
        setExpanded(g, false);
      });

      // Una guided view que enfoque un miembro plegado abre su grupo.
      var expanded = {};
      function syncToView() {
        var active = document.querySelector('[data-active-view]');
        if (!active) return;
        var view = active.getAttribute('data-active-view');
        if (!view) return;
        GROUPS.forEach(function (g) { expanded[g.id] = !!g.summary && g.summary.style.display === 'none'; });
        document.querySelectorAll('[data-view-focus]').forEach(function (el) {
          el.removeAttribute('data-view-focus');
        });
        if (view === 'pantallas' || view === 'codigo' || view === 'completo' || view === 'targets') {
          GROUPS.forEach(function (g) {
            var panel = document.querySelector('[data-view="' + view + '"]');
            if (!panel) return;
            var focus = (panel.getAttribute('data-view-focus') || '').split(/\\s+/);
            if (focus.some(function (id) { return g.members.indexOf(id) >= 0; })) {
              setExpanded(g, true);
              expanded[g.id] = true;
            }
          });
        }
      }

      if (window.MutationObserver) {
        new MutationObserver(syncToView).observe(document.documentElement, { attributes: true, attributeFilter: ['data-active-view'] });
      }
    })();
`;

const target = process.argv[2];
if (!target) {
  console.error('uso: node tools/archify-collapse.mjs <ruta-al-html>');
  process.exit(1);
}

let html = readFileSync(target, 'utf8');
if (html.includes('archify-collapse: grupos plegables')) {
  console.log('ya inyectado: ' + target);
  process.exit(0);
}

const summaries = GROUPS.map(summarySvg).join('');
const host = html.lastIndexOf('</svg>');
if (host < 0) {
  console.error('no se encontro </svg> en ' + target);
  process.exit(1);
}
html = html.slice(0, host) + summaries + '\n' + html.slice(host);
html = html.replace('</head>', style + '</head>');
html = html.replace('</body>', script + '</body>');
writeFileSync(target, html, 'utf8');
console.log('colapso inyectado en ' + target);
