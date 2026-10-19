// Unified AI handler — enrich, idea-base, notes
// Routes by ?type= to stay under Vercel Hobby 12-function limit.
const { sparkRequest } = require('./_lib/spark');
const { parseToken } = require('./posts');
const { getIp, checkRateLimit } = require('./_lib/ratelimit');

// --- gemma ---

// Cloudflare Workers AI -- no API key to obtain, rotate, or silently expire.
// gpt-oss-120b beat qwen3-30b, gemma-4 and qwen3.8 on a side-by-side 2026-10-19:
// sharper ideas, tighter briefs, and it is on the free plan (kimi, glm-5.3 and
// deepseek-v4 are not).
const GEMMA_MODEL = '@cf/openai/gpt-oss-120b';

async function callGemma(prompt, maxTokens = 1200, temperature = 0.9) {
  const ai = globalThis.__env && globalThis.__env.AI;
  if (!ai) throw new Error('AI binding unavailable');
  const out = await ai.run(GEMMA_MODEL, {
    messages: [{ role: 'user', content: prompt }],
    temperature,
    max_tokens: maxTokens
  });
  const msg = out && out.choices && out.choices[0] && out.choices[0].message;
  const raw = (out && out.response) || (msg && msg.content) || (msg && msg.reasoning) || '';
  // Workers AI sometimes hands back an already-parsed object rather than text.
  // Re-serialise it so callers keep their one contract: this returns a string.
  const text = typeof raw === 'string' ? raw : JSON.stringify(raw);
  return text.replace(/<think>[\s\S]*?<\/think>/g, '').trim();
}

// Models wrap JSON in prose or fences however they feel that day. Strip fences,
// then fall back to the first {...} in the text -- same tolerance the old daemon
// needed for its arrays. Returns null rather than throwing.
function parseJsonish(text) {
  const clean = String(text || '').replace(/^```(?:json)?\s*/i, '').replace(/```\s*$/, '').trim();
  try { return JSON.parse(clean); } catch { /* fall through */ }
  const start = clean.indexOf('{');
  const end = clean.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try { return JSON.parse(clean.slice(start, end + 1)); } catch { return null; }
}

// --- generate (cron: post one AI idea) ---

const words = t => new Set(String(t).toLowerCase().match(/[a-z0-9]+/g) || []);

// A repeat is a title sharing half its words with a recent one, or opening
// with a word two recent titles already open with.
function tooSimilar(title, recentTitles) {
  const mine = words(title);
  const first = String(title).trim().split(/\s+/)[0].toLowerCase();
  let sameOpening = 0;
  for (const other of recentTitles) {
    const theirs = words(other);
    const shared = [...mine].filter(w => theirs.has(w)).length;
    if (shared / (mine.size + theirs.size - shared) >= 0.5) return true;
    if (String(other).trim().split(/\s+/)[0].toLowerCase() === first) sameOpening++;
  }
  return sameOpening >= 2;
}

// Second opinion before anything posts. The writer at 0.9 still slips into
// "an app that tracks X" now and then; a cold read at 0.2 catches it. A judge
// that errors or mumbles lets the draft through: a broken judge must not
// silence the daily idea.
async function judgeIdea(idea, ask = callGemma) {
  let verdict;
  try {
    verdict = parseJsonish(await ask(
      `You review ideas for a public idea board and reject generic ones.\n` +
      `Generic: a tracker, list, reminder, dashboard, marketplace, social network or "AI assistant" anyone could name without knowing the people; a shared schedule, chore or bill app for roommates or families; or a vague problem.\n` +
      `Specific: a real group of people, one concrete job they do by hand today, and exactly what the app does about it.\n` +
      `Title: ${idea.title}\nContent: ${idea.content}\n\n` +
      `Reply with ONLY JSON: {"specific": true or false, "reason": "under 12 words"}`,
      300, 0.2
    ));
  } catch { return { ok: true }; }
  if (verdict && verdict.specific === false) return { ok: false, reason: String(verdict.reason || 'generic') };
  return { ok: true };
}

const GEN_CATEGORIES = ['tech', 'productivity', 'finance', 'health', 'sustainability'];

// Left to itself the model wrote "Shared X tracker for roommates" for a month.
// Starting from a named group of people forces a real, specific job to fix.
const GEN_ANGLES = ['night-shift nurses', 'wedding photographers', 'small landlords',
  'high school robotics coaches', 'beekeepers', 'independent pharmacists', 'food truck owners',
  'court interpreters', 'long-haul truckers', 'church treasurers', 'ESL tutors',
  'HVAC technicians', 'dog groomers', 'indie game devs', 'community theatre directors',
  'farmers market vendors', 'new immigrants filing taxes', 'used bookstore owners',
  'climbing gyms', 'school bus dispatchers', 'freelance translators', 'home care aides',
  'municipal clerks', 'tattoo artists', 'marine mechanics', 'youth soccer leagues',
  'podcast editors', 'museum registrars', 'solar installers', 'wildland firefighters'];

async function handleGenerate(req, res) {
  // Vercel strips inbound x-vercel-* headers, so this only passes for real cron
  // invocations. Manual trigger: daemon secret as bearer.
  const auth = req.headers.authorization || '';
  const isCron = !!req.headers['x-vercel-cron'];
  const isDaemon = process.env.SPARK_DAEMON_SECRET && auth === 'Bearer ' + process.env.SPARK_DAEMON_SECRET;
  if (!isCron && !isDaemon) return res.status(401).json({ error: 'Unauthorized' });

  const recent = await sparkRequest('posts?select=title&order=created_at.desc&limit=20');
  const titles = (Array.isArray(recent) ? recent : []).map(r => r.title);
  const recentTitles = titles.map(t => '- ' + t).join('\n');

  // The model copies the shape of whatever it is shown ("Shared X tracker for
  // roommates", five days running), so a rejected draft gets another try in a
  // fresh category. Three misses post nothing: a quiet day beats a repeat.
  let idea, category, text;
  for (let attempt = 0; attempt < 3; attempt++) {
    category = GEN_CATEGORIES[Math.floor(Math.random() * GEN_CATEGORIES.length)];
    const angle = GEN_ANGLES[Math.floor(Math.random() * GEN_ANGLES.length)];
    text = await callGemma(
      `Invent one software idea for a public idea board. Category: ${category}. Start from this group of people: ${angle}.\n` +
      `Find one specific, annoying job they do by hand today that software could kill. Not a generic tracker, list, calendar, splitter or "shared X". No apps for roommates or families.\n` +
      `Title: under 8 words, names the thing, no colon.\n` +
      `Content: two sentences, under 45 words total. First says the pain, second says what the app does. Plain words, no hype.\n` +
      `Already posted, do not repeat:\n${recentTitles}\n\n` +
      `Reply with ONLY JSON: {"title": "...", "content": "..."}`
    );
    idea = parseJsonish(text);
    if (idea && idea.title && idea.content && !tooSimilar(idea.title, titles)) {
      const verdict = await judgeIdea(idea);
      if (verdict.ok) break;
      idea = { generic: idea.title + ' (' + verdict.reason + ')' };
      continue;
    }
    if (idea && idea.title && idea.content) idea = { repeat: idea.title };
  }

  // 422, not 502: Cloudflare's edge swallows a 5xx body and serves its own
  // error page, which hid this failure entirely the first time it happened.
  if (!idea) return res.status(422).json({ error: 'Model returned unparseable idea', raw: text.slice(0, 300) });
  if (idea.repeat) return res.status(422).json({ error: 'Idea too close to a recent post', raw: idea.repeat });
  if (idea.generic) return res.status(422).json({ error: 'Judge called the idea generic', raw: idea.generic });
  if (!idea.title || !idea.content) return res.status(422).json({ error: 'Incomplete idea', raw: text.slice(0, 300) });

  const rows = await sparkRequest('posts', {
    method: 'POST',
    body: {
      id: 'post-' + Date.now() + '-' + Math.random().toString(36).slice(2, 8),
      title: String(idea.title).slice(0, 200),
      content: String(idea.content).slice(0, 2000),
      category,
      author_username: 'gemma',
      author_user_id: 'system',
      score: 0,
      created_at: new Date().toISOString()
    },
    useServiceRole: true
  });
  const row = Array.isArray(rows) ? rows[0] : rows;
  return res.status(201).json({ post: row });
}

// --- enrich ---

async function handleEnrich(req, res) {
  if (req.method === 'POST') {
    // Either a signed-in user, or the cron worker presenting the daemon secret
    // (same bearer check handleGenerate uses). The cron path skips the per-IP
    // limit: one scheduled call must not compete with real users' budget.
    const auth = req.headers.authorization || '';
    const isDaemon = !!process.env.SPARK_DAEMON_SECRET &&
      auth === 'Bearer ' + process.env.SPARK_DAEMON_SECRET;
    if (!isDaemon) {
      const user = parseToken(req.headers.authorization, req.headers.cookie);
      if (!user) return res.status(401).json({ error: 'Authentication required' });
      if (!checkRateLimit('enrich:' + getIp(req), 5, 60_000)) {
        return res.status(429).json({ error: 'Too many requests' });
      }
    }

    let { id, spec, plan } = req.body || {};
    if (!id) return res.status(400).json({ error: 'id required' });

    // No client-supplied spec/plan (daemon path) -> generate them with Gemma.
    if (!spec || !plan) {
      const rows = await sparkRequest(`posts?id=eq.${encodeURIComponent(id)}&select=title,content,category`);
      if (!Array.isArray(rows) || !rows.length) return res.status(404).json({ error: 'Post not found' });
      const p = rows[0];
      const text = await callGemma(
        `Idea: "${p.title}" (${p.category})\n${p.content}\n\n` +
        `Write a tight build brief.\n` +
        `spec: 3 to 5 markdown bullets, each under 15 words: the core screen, the one feature that matters, data source, what to leave out.\n` +
        `plan: 4 to 6 numbered steps, each under 15 words, first step shippable in a weekend.\n` +
        `No intro, no filler, no "user-friendly". Reply with ONLY JSON: {"spec": "...", "plan": "..."}`,
        1200
      );
      const gen = parseJsonish(text);
      if (!gen) return res.status(422).json({ error: 'Model returned unparseable enrichment', raw: text.slice(0, 300) });
      spec = gen.spec;
      plan = gen.plan;
      if (!spec || !plan) return res.status(422).json({ error: 'Incomplete enrichment', raw: text.slice(0, 300) });
    }

    await sparkRequest(`posts?id=eq.${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: {
        enriched: true,
        enrichment_plan: plan,
        enrichment_spec: spec,
        enrichment_completed_at: new Date().toISOString()
      },
      useServiceRole: true
    });

    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

// --- idea-base ---

async function handleIdeaBase(req, res) {
  if (req.method === 'GET') {
    const offset = Number.parseInt(req.query && req.query.offset, 10) || 0;
    const rows = await sparkRequest(`idea_bases?order=created_at.desc&limit=50&offset=${offset}`);
    return res.status(200).json({ ideaBases: Array.isArray(rows) ? rows : [] });
  }

  if (req.method === 'POST') {
    const user = parseToken(req.headers.authorization, req.headers.cookie);
    if (!user) return res.status(401).json({ error: 'Authentication required' });
    if (!checkRateLimit('ideabase:' + getIp(req), 2, 60_000)) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    const { topic, description } = req.body || {};
    if (!topic || typeof topic !== 'string' || topic.length > 200) {
      return res.status(400).json({ error: 'topic required (max 200 chars)' });
    }

    // The daemon that used to fill a queued topic is gone, so write the ideas now:
    // three in one call, posted as gemma, and the base links them.
    const text = await callGemma(
      `Topic: ${topic}\n${description ? `Context: ${String(description).slice(0, 500)}\n` : ''}` +
      `Invent three different software ideas on this topic. Each starts from a specific group of people and one annoying job they do by hand today. Not a generic tracker, list, calendar or "shared X".\n` +
      `Title under 8 words, no colon. Content two sentences, under 45 words: the pain, then what the app does. Plain words, no hype.\n` +
      `Reply with ONLY JSON: {"ideas": [{"title": "...", "content": "..."}]}`,
      2000
    );
    const ideas = ((parseJsonish(text) || {}).ideas || []).filter(i => i && i.title && i.content).slice(0, 3);
    if (!ideas.length) return res.status(422).json({ error: 'Model returned no ideas', raw: String(text).slice(0, 300) });

    const post_ids = [];
    for (const idea of ideas) {
      const id = 'post-' + Date.now() + '-' + Math.random().toString(36).slice(2, 8);
      await sparkRequest('posts', {
        method: 'POST',
        body: {
          id,
          title: String(idea.title).slice(0, 200),
          content: String(idea.content).slice(0, 2000),
          category: 'tech',
          author_username: 'gemma',
          author_user_id: 'system',
          score: 0,
          created_at: new Date().toISOString()
        },
        useServiceRole: true
      });
      post_ids.push(id);
    }

    const rows = await sparkRequest('idea_bases', {
      method: 'POST',
      body: {
        topic,
        description: description || null,
        post_ids,
        pending: false,
        created_by: user.userId,
        created_at: new Date().toISOString()
      },
      useServiceRole: true
    });

    const row = Array.isArray(rows) ? rows[0] : rows;
    return res.status(201).json({ ideaBase: row });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

// --- rfs (YC Requests for Startups, scraped + cached) ---

let rfsCache = { items: null, ts: 0 };
const RFS_TTL_MS = 12 * 60 * 60 * 1000;
const RFS_ENTRY_RE = /<div id="([\w-]+)"><div class="border[^"]*py-10[^"]*"><div class="w-full"><div class="mb-6"><h3[^>]*>([^<]+)<span.*?<\/h3><span[^>]*>By<!-- --> (.*?)<\/span><\/div>.*?whitespace-pre-wrap[^>]*>(.*?)<\/div><\/div><\/div><\/div><\/div><\/div>/gs;

function stripTags(s) {
  return s.replace(/<[^>]+>/g, '')
    .replace(/&#x27;|&#39;/g, "'").replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&') // last, so "&amp;quot;" stays "&quot;"
    .replace(/\s+/g, ' ').trim();
}

async function fetchRfs() {
  const res = await fetch('https://www.ycombinator.com/rfs', { headers: { 'User-Agent': 'Mozilla/5.0' } });
  if (!res.ok) throw new Error(`YC fetch failed: ${res.status}`);
  const html = await res.text();
  const items = [];
  let m;
  while ((m = RFS_ENTRY_RE.exec(html))) {
    items.push({
      slug: m[1],
      title: stripTags(m[2]),
      author: stripTags(m[3]),
      description: stripTags(m[4]),
      url: `https://www.ycombinator.com/rfs#${m[1]}`
    });
  }
  return items;
}

async function handleRfs(req, res) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const fresh = rfsCache.items && (Date.now() - rfsCache.ts) < RFS_TTL_MS;
  if (!fresh) {
    try {
      const items = await fetchRfs();
      if (items.length) rfsCache = { items, ts: Date.now() };
    } catch (err) {
      console.error('[AI] rfs fetch failed', err.message);
      // ponytail: serve stale cache on fetch failure, only 500 if we have nothing
      if (!rfsCache.items) return res.status(502).json({ error: 'Could not fetch YC RFS' });
    }
  }

  return res.status(200).json({ rfs: rfsCache.items || [], cachedAt: rfsCache.ts });
}

// --- notes ---

async function handleNotes(req, res) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const id = req.query && req.query.id;
  if (!id) return res.status(400).json({ error: 'id required' });

  const rows = await sparkRequest(
    `posts?id=eq.${encodeURIComponent(id)}&select=id,title,content,category,score,linked_repo,enrichment_plan,enrichment_spec,created_at`
  );

  if (!Array.isArray(rows) || rows.length === 0) {
    return res.status(404).json({ error: 'Post not found' });
  }

  const p = rows[0];
  const lines = [
    `---`,
    `id: ${p.id}`,
    `title: ${p.title}`,
    `category: ${p.category || 'tech'}`,
    `score: ${p.score || 0}`,
    p.linked_repo ? `repo: ${p.linked_repo}` : null,
    `created_at: ${p.created_at}`,
    `---`,
    ``,
    `# ${p.title}`,
    ``,
    p.content,
  ];

  if (p.enrichment_spec) lines.push('', '## Spec', '', p.enrichment_spec);
  if (p.enrichment_plan) lines.push('', '## Plan', '', p.enrichment_plan);

  const markdown = lines.filter(l => l !== null).join('\n');
  res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
  res.setHeader('Content-Disposition', `attachment; filename="spark-${p.id}.md"`);
  return res.status(200).send(markdown);
}

// --- router ---

module.exports = async function handler(req, res) {
  try {
    const type = req.query && req.query.type;
    if (type === 'enrich') return await handleEnrich(req, res);
    if (type === 'idea-base') return await handleIdeaBase(req, res);
    if (type === 'notes') return await handleNotes(req, res);
    if (type === 'rfs') return await handleRfs(req, res);
    if (type === 'generate') return await handleGenerate(req, res);
    return res.status(400).json({ error: 'type required: enrich | idea-base | notes | rfs | generate' });
  } catch (err) {
    console.error('[AI]', err.message);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
module.exports.tooSimilar = tooSimilar;
module.exports.judgeIdea = judgeIdea;
