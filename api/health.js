// GET /api/health/mail -- says whether reset and verify mail can actually go out,
// without sending anything. Password reset answers 200 either way (so it can't
// leak which emails have accounts), which hid a dead Resend key for months.
module.exports = async function handler(req, res) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const binding = !!(globalThis.__env && globalThis.__env.EMAIL);
  const key = process.env.RESEND_API_KEY;
  let resend = 'unset';
  if (key) {
    try {
      const r = await fetch('https://api.resend.com/domains', { headers: { Authorization: `Bearer ${key}` } });
      // A send-only key is refused here with restricted_api_key, which still proves it is alive.
      const body = r.ok ? null : await r.json().catch(() => null);
      resend = r.ok || (body && body.name === 'restricted_api_key') ? 'ok' : 'invalid';
    } catch {
      resend = 'unreachable';
    }
  }

  const ok = binding || resend === 'ok';
  return res.status(ok ? 200 : 503).json({ ok, binding, resend });
};
