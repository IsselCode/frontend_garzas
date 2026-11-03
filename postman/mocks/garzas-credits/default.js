// Local, synthetic read-only examples from ENDPOINTS_CREDITOS.md.
const http = require('http');
const credits = Array.from({ length: 45 }, (_, index) => ({
  sale_folio: `CRED-${String(index + 1).padStart(3, '0')}`,
  client_id: index + 1,
  commercial_name: index === 44 ? 'Peña %_\\ Norte' : `Rancho ${index + 1}`,
  total: 1000.0,
  amount_paid: index < 25 ? 400.0 : 1000.0,
  sale_pending_amount: index < 25 ? 600.0 : 0.0,
  created_at: '2026-11-02T10:00:00+00:00',
}));

http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');
  res.setHeader('Content-Type', 'application/json');
  const send = (status, body) => {
    res.statusCode = status;
    res.end(JSON.stringify(body));
  };
  if (req.method !== 'GET' || url.pathname !== '/api/v1/sales/credit/pending') {
    return send(501, { error: { code: 'not_modeled', detail: 'Route not modeled' } });
  }
  const query = url.searchParams;
  const status = query.get('status') || 'pending';
  const search = (query.get('search') || '').trim().replace(/\s+/g, ' ');
  const page = Number(query.get('page') || 1);
  const limit = Number(query.get('limit') || 20);
  const start = query.get('start_at');
  const end = query.get('end_at');
  if (!['pending', 'paid', 'all'].includes(status) || [...search].length > 45 ||
      (query.has('search') && query.get('search') === '') ||
      !Number.isInteger(page) || page < 1 || !Number.isInteger(limit) || limit < 1 || limit > 100 ||
      Boolean(start) !== Boolean(end) ||
      (start && (!/([+-]\d{2}:\d{2}|Z)$/.test(start) || !/([+-]\d{2}:\d{2}|Z)$/.test(end) ||
        !(Date.parse(start) < Date.parse(end))))) {
    return send(422, { error: { code: 'validation_error', detail: 'Filtros de crédito inválidos', meta: [] } });
  }
  // A deterministic, synthetic failure for exercising frontend recovery.
  if (search === 'FALLAR') {
    return send(500, { error: { code: 'test_failure', detail: 'No se pudieron consultar los créditos', meta: [] } });
  }
  const matches = credits.filter(credit =>
    (status === 'all' || (status === 'pending') === (credit.sale_pending_amount > 0)) &&
    (!search || credit.commercial_name.toLocaleLowerCase().includes(search.toLocaleLowerCase())) &&
    (!start || (Date.parse(start) <= Date.parse(credit.created_at) && Date.parse(credit.created_at) < Date.parse(end)))
  );
  send(200, {
    items: matches.slice((page - 1) * limit, page * limit),
    page, limit, total: matches.length, total_pages: Math.ceil(matches.length / limit),
  });
}).listen(process.env.PORT);
