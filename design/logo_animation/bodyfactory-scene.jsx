const { CompositionStage, useComposition, animate, interpolate, Easing, clamp } = window;

let ORANGE = '#F2481B';
let ORANGE_HI = '#FF8A4C';
let BRAND = 'BODY FACTORY';
let SUB = 'GYM';
const CREAM = '#F3EFEC';

const MOTION = {
  enter: Easing.easeOutExpo,
  snap: Easing.easeOutBack,
  push: Easing.easeInOutQuart,
};

// --- logo geometry (viewBox -160 -110 320 320) ---
const TL = [-100, -45];
const TR = [100, -45];
const BM = [0, 130];
const J = [0, 16];

const EDGES = [
  { a: TL, b: TR, n: [0, -1], spin: -16 },
  { a: TR, b: BM, n: [0.87, 0.5], spin: 20 },
  { a: BM, b: TL, n: [-0.87, 0.5], spin: -20 },
];
const SPOKES = [TL, TR, BM];
const dist = (p, q) => Math.hypot(p[0] - q[0], p[1] - q[1]);

function LogoMark({ T, cueA, cueC, size, formed }) {
  const sw = 4.4;
  const edges = EDGES.map((e, i) => {
    if (formed) return { e, d: 0, rot: 0, op: 1, w: sw };
    const t0 = cueA + 0.45 + i * 0.62;
    const d = animate({ from: 340, to: 0, start: t0, end: t0 + 1.0, ease: MOTION.enter })(T);
    const rot = animate({ from: e.spin, to: 0, start: t0, end: t0 + 1.0, ease: MOTION.enter })(T);
    const op = animate({ from: 0, to: 1, start: t0, end: t0 + 0.3, ease: Easing.easeOutQuad })(T);
    const flash = animate({ from: 1, to: 0, start: t0 + 0.92, end: t0 + 1.45, ease: Easing.easeOutQuad })(T);
    return { e, d, rot, op, w: sw + flash * 5.5 };
  });

  const spokes = SPOKES.map((v, i) => {
    const len = dist(J, v);
    if (formed) return { v, len, off: 0, op: 1 };
    const t0 = cueC + 0.15 + i * 0.28;
    const p = animate({ from: 0, to: 1, start: t0, end: t0 + 0.75, ease: MOTION.enter })(T);
    return { v, len, off: len * (1 - p), op: p > 0 ? 1 : 0 };
  });

  const nodeR = formed ? 0 : animate({ from: 0, to: 1, start: cueC + 0.9, end: cueC + 1.5, ease: MOTION.snap })(T) * 9
    * animate({ from: 1, to: 0.0, start: cueC + 1.4, end: cueC + 2.0, ease: Easing.easeInQuad })(T);
  const ringP = formed ? 1 : animate({ from: 0, to: 1, start: cueC + 1.15, end: cueC + 2.3, ease: Easing.easeOutQuart })(T);
  const ringOn = !formed && ringP > 0 && ringP < 1;

  const glow = formed ? 16 : 8 + 26 * animate({ from: 1, to: 0, start: cueC + 1.15, end: cueC + 2.4, ease: Easing.easeOutQuad })(T)
    + 6 * (0.5 + 0.5 * Math.sin(T * 1.4));

  return (
    <svg width={size} height={size} viewBox="-160 -110 320 320" style={{ overflow: 'visible', display: 'block', filter: `drop-shadow(0 0 ${glow}px rgba(242,72,27,0.55))` }}>
      {ringOn ? (
        <circle cx={J[0]} cy={J[1]} r={10 + ringP * 165} fill="none" stroke={ORANGE_HI} strokeWidth={2.5} opacity={(1 - ringP) * 0.7} />
      ) : null}
      {spokes.map((s, i) => (
        <line key={'s' + i} x1={J[0]} y1={J[1]} x2={s.v[0]} y2={s.v[1]} stroke={ORANGE} strokeWidth={sw} strokeLinecap="round"
          strokeDasharray={s.len} strokeDashoffset={s.off} opacity={s.op} />
      ))}
      {edges.map((x, i) => (
        <g key={'e' + i} opacity={x.op} transform={`translate(${x.e.n[0] * x.d} ${x.e.n[1] * x.d}) rotate(${x.rot})`}>
          <line x1={x.e.a[0]} y1={x.e.a[1]} x2={x.e.b[0]} y2={x.e.b[1]} stroke={ORANGE} strokeWidth={x.w} strokeLinecap="round" />
        </g>
      ))}
      {nodeR > 0.05 ? <circle cx={J[0]} cy={J[1]} r={nodeR} fill={ORANGE_HI} /> : null}
    </svg>
  );
}

function Wordmark({ T, cue, formed, scale }) {
  const words = BRAND.split(' ');
  let li = 0;
  const subP = formed ? 1 : animate({ from: 0, to: 1, start: cue + 1.5, end: cue + 2.4, ease: MOTION.enter })(T);
  const ruleP = formed ? 1 : animate({ from: 0, to: 1, start: cue + 0.9, end: cue + 1.8, ease: MOTION.enter })(T);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 26 * scale, transform: 'translateZ(0)' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 34 * scale, color: CREAM, lineHeight: 1 }}>
        {words.map((w, wi) => (
          <div key={wi} style={{ display: 'flex', fontFamily: 'Oswald, sans-serif', fontWeight: 400, fontSize: 100 * scale, letterSpacing: 0.16 * 92 * scale, paddingLeft: 0.16 * 92 * scale }}>
            {w.split('').map((ch, i) => {
              const t0 = cue + 0.25 + (li++) * 0.055;
              const p = formed ? 1 : animate({ from: 0, to: 1, start: t0, end: t0 + 0.55, ease: MOTION.enter })(T);
              return <span key={i} style={{ opacity: p, transform: `translateY(${(1 - p) * 34 * scale}px)`, display: 'inline-block' }}>{ch}</span>;
            })}
          </div>
        ))}
      </div>
      <div style={{ width: (120 + 300 * ruleP) * scale, height: 2 * scale, background: ORANGE, opacity: ruleP }} />
      <div style={{ fontFamily: 'Jost, sans-serif', fontWeight: 400, fontSize: 38 * scale, color: ORANGE, opacity: subP, letterSpacing: (0.3 + 0.35 * subP) * 38 * scale, paddingLeft: (0.3 + 0.35 * subP) * 38 * scale }}>{SUB}</div>
    </div>
  );
}

function Piece() {
  const { T, CUES, authoredTotal } = useComposition();
  const A = CUES.Assemble, C = CUES.Core, W = CUES.Wordmark, L = CUES.Launch;

  // gentle camera drift through the whole build
  const camScale = animate({ from: 1.06, to: 1.0, start: A, end: L, ease: Easing.easeOutSine })(T);

  // launch: tile forms, then the whole icon zooms up like an app opening
  const tileOp = animate({ from: 0, to: 1, start: L + 0.05, end: L + 0.6, ease: Easing.easeOutQuad })(T);
  const tileShrink = animate({ from: 1, to: 0.78, start: L + 0.05, end: L + 0.75, ease: MOTION.enter })(T);
  const zoom = animate({ from: 1, to: 8.5, start: L + 0.95, end: L + 2.45, ease: MOTION.push })(T);
  const iconScale = tileShrink * zoom * camScale;
  const iconOp = animate({ from: 1, to: 0, start: L + 2.0, end: L + 2.45, ease: Easing.easeInQuad })(T);
  const tileR = animate({ from: 104, to: 0, start: L + 0.95, end: L + 2.35, ease: MOTION.push })(T);

  const wordOut = animate({ from: 1, to: 0, start: L + 0.1, end: L + 0.65, ease: Easing.easeInQuad })(T);
  const wordShift = animate({ from: 0, to: 40, start: L + 0.1, end: L + 0.7, ease: Easing.easeInQuad })(T);

  // splash — the app that just opened
  const splashOp = animate({ from: 0, to: 1, start: L + 2.15, end: L + 2.8, ease: Easing.easeOutQuad })(T);
  const splashRise = animate({ from: 26, to: 0, start: L + 2.15, end: L + 3.1, ease: MOTION.enter })(T);
  const barP = animate({ from: 0, to: 1, start: L + 2.6, end: L + 3.9, ease: Easing.easeInOutSine })(T);
  const outFade = animate({ from: 0, to: 1, start: authoredTotal - 0.6, end: authoredTotal, ease: Easing.easeInQuad })(T);

  return (
    <div style={{ position: 'absolute', inset: 0, background: '#000', overflow: 'hidden', fontFamily: 'Jost, sans-serif' }}>
      {/* faint floor glow */}
      <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(120% 90% at 50% 42%, rgba(242,72,27,0.13) 0%, rgba(0,0,0,0) 62%)', opacity: clamp((T - A - 0.6) / 1.6, 0, 1) * (1 - splashOp) }} />

      {/* icon layer: tile + mark, zoomed together */}
      <div style={{ position: 'absolute', left: '50%', top: 400, width: 0, height: 0, transform: `scale(${iconScale})`, opacity: iconOp }}>
        <div style={{ position: 'absolute', left: -260, top: -260, width: 520, height: 520, borderRadius: tileR, border: `2px solid rgba(242,72,27,${0.55 * tileOp})`, background: `rgba(9,9,9,${0.9 * tileOp})`, opacity: tileOp, boxShadow: `0 0 ${80 * tileOp}px rgba(242,72,27,${0.25 * tileOp})` }} />
        <div style={{ position: 'absolute', left: -260, top: -260, width: 520, height: 520, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <LogoMark T={T} cueA={A} cueC={C} size={430} formed={false} />
        </div>
      </div>

      {/* wordmark under the mark */}
      <div style={{ position: 'absolute', left: 0, right: 0, top: 700, display: 'flex', justifyContent: 'center', opacity: wordOut, transform: `translateY(${wordShift}px) scale(${camScale})` }}>
        <Wordmark T={T} cue={W} formed={false} scale={1} />
      </div>

      {/* opened app splash */}
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 54, opacity: splashOp, transform: `translateY(${splashRise}px)` }}>
        <LogoMark T={T} cueA={A} cueC={C} size={300} formed={true} />
        <Wordmark T={T} cue={W} formed={true} scale={0.62} />
        <div style={{ width: 320, height: 3, background: 'rgba(255,255,255,0.12)', marginTop: 30 }}>
          <div style={{ width: `${barP * 100}%`, height: '100%', background: ORANGE }} />
        </div>
      </div>

      <div style={{ position: 'absolute', inset: 0, background: '#000', opacity: outFade, pointerEvents: 'none' }} />
    </div>
  );
}

function BodyFactoryVideo(props) {
  ORANGE = props.accent || '#F2481B';
  ORANGE_HI = props.accentHi || '#FF8A4C';
  BRAND = (props.brandName || 'BODY FACTORY').toUpperCase();
  SUB = (props.subName || 'GYM').toUpperCase();
  return (
    <CompositionStage width={1920} height={1080} bg="#000000" scenes={window.OM_SCENES} playback={window.OM_PLAYBACK}>
      <Piece />
    </CompositionStage>
  );
}

window.BodyFactoryVideo = BodyFactoryVideo;
