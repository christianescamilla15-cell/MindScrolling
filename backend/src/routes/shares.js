/**
 * Share quotes between MindScrolling users.
 *
 * POST /api/shares        — share a quote with a friend
 * GET  /api/shares/pending — get unread shared quotes
 * POST /api/shares/:id/seen — mark as seen
 * GET  /api/shares/search-user — search users by display name
 */

module.exports = async function sharesRoutes(fastify) {
  const db = fastify.db;

  // Share a quote with a friend
  fastify.post('/api/shares', async (request, reply) => {
    const { from_device_id, to_device_id, quote_id } = request.body;

    if (!from_device_id || !to_device_id || !quote_id) {
      return reply.code(400).send({ error: 'Missing required fields' });
    }

    // Verify both users exist
    const sender = await db.query('SELECT device_id, display_name FROM users WHERE device_id = $1', [from_device_id]);
    const receiver = await db.query('SELECT device_id FROM users WHERE device_id = $1', [to_device_id]);

    if (!sender.rows.length) return reply.code(404).send({ error: 'Sender not found' });
    if (!receiver.rows.length) return reply.code(404).send({ error: 'Friend not found. They need MindScrolling installed.' });

    // Create share
    const result = await db.query(
      `INSERT INTO shared_quotes (from_device_id, to_device_id, quote_id)
       VALUES ($1, $2, $3) RETURNING id, created_at`,
      [from_device_id, to_device_id, quote_id]
    );

    return {
      id: result.rows[0].id,
      from: sender.rows[0].display_name || 'A friend',
      created_at: result.rows[0].created_at,
    };
  });

  // Get pending (unread) shared quotes
  fastify.get('/api/shares/pending', async (request, reply) => {
    const { device_id } = request.query;
    if (!device_id) return reply.code(400).send({ error: 'device_id required' });

    const result = await db.query(
      `SELECT sq.id, sq.quote_id, sq.from_device_id, sq.created_at,
              u.display_name as from_name,
              q.text, q.author, q.category, q.lang
       FROM shared_quotes sq
       JOIN quotes q ON sq.quote_id = q.id
       LEFT JOIN users u ON sq.from_device_id = u.device_id
       WHERE sq.to_device_id = $1 AND sq.seen = false
       ORDER BY sq.created_at DESC LIMIT 10`,
      [device_id]
    );

    return { shares: result.rows, count: result.rows.length };
  });

  // Mark share as seen
  fastify.post('/api/shares/:id/seen', async (request, reply) => {
    const { id } = request.params;
    await db.query('UPDATE shared_quotes SET seen = true WHERE id = $1', [id]);
    return { status: 'ok' };
  });

  // Search users by display name (for friend finder)
  fastify.get('/api/shares/search-user', async (request, reply) => {
    const { q, exclude_device_id } = request.query;
    if (!q || q.length < 2) return { users: [] };

    const result = await db.query(
      `SELECT device_id, display_name FROM users
       WHERE display_name ILIKE $1 AND device_id != $2
       LIMIT 10`,
      [`%${q}%`, exclude_device_id || '']
    );

    return { users: result.rows };
  });
};
