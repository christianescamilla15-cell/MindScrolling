/**
 * social.js — Social feed + follows + streaks
 *
 * Endpoints:
 *   POST /social/follow           — follow a user
 *   DELETE /social/follow/:id     — unfollow
 *   GET  /social/following        — list who you follow
 *   GET  /social/feed             — feed of friends' activity (likes/vaults)
 *   GET  /social/streak           — get current streak info
 *   POST /social/streak/checkin   — record daily activity (updates streak)
 *   GET  /social/qotd             — quote of the day
 */

import { supabase } from "../db/client.js";

export default async function socialRoutes(fastify) {

  // ── POST /social/follow ───────────────────────────────────────────────────
  fastify.post("/follow", async (request, reply) => {
    const deviceId = request.deviceId;
    const { user_id } = request.body || {};

    if (!user_id) {
      return reply.status(400).send({ error: "user_id required" });
    }
    if (user_id === deviceId) {
      return reply.status(400).send({ error: "Cannot follow yourself" });
    }

    const { error } = await supabase.from("follows").upsert(
      { follower_id: deviceId, following_id: user_id },
      { onConflict: "follower_id,following_id" }
    );

    if (error) {
      return reply.status(500).send({ error: "Failed to follow" });
    }
    return reply.send({ ok: true });
  });

  // ── DELETE /social/follow/:id ─────────────────────────────────────────────
  fastify.delete("/follow/:id", async (request, reply) => {
    const deviceId = request.deviceId;
    const { id } = request.params;

    await supabase.from("follows")
      .delete()
      .eq("follower_id", deviceId)
      .eq("following_id", id);

    return reply.send({ ok: true });
  });

  // ── GET /social/following ─────────────────────────────────────────────────
  fastify.get("/following", async (request, reply) => {
    const deviceId = request.deviceId;

    const { data, error } = await supabase
      .from("follows")
      .select("following_id, created_at, users!follows_following_id_fkey(display_name)")
      .eq("follower_id", deviceId)
      .order("created_at", { ascending: false });

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch following" });
    }

    const following = (data || []).map(f => ({
      user_id: f.following_id,
      display_name: f.users?.display_name || "Anonymous",
      since: f.created_at,
    }));

    return reply.send({ following });
  });

  // ── GET /social/feed ──────────────────────────────────────────────────────
  fastify.get("/feed", async (request, reply) => {
    const deviceId = request.deviceId;
    const limit = Math.min(parseInt(request.query.limit || "20"), 50);

    // Get who I follow
    const { data: follows } = await supabase
      .from("follows")
      .select("following_id")
      .eq("follower_id", deviceId);

    const friendIds = (follows || []).map(f => f.following_id);
    if (friendIds.length === 0) {
      return reply.send({ feed: [], message: "Follow friends to see their activity" });
    }

    // Get their recent activity
    const { data, error } = await supabase
      .from("social_activity")
      .select("id, device_id, quote_id, action_type, created_at, quotes(text, author, category), users!social_activity_device_id_fkey(display_name)")
      .in("device_id", friendIds)
      .order("created_at", { ascending: false })
      .limit(limit);

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch feed" });
    }

    const feed = (data || []).map(item => ({
      id: item.id,
      user: item.users?.display_name || "Anonymous",
      action: item.action_type,
      quote: {
        id: item.quote_id,
        text: item.quotes?.text,
        author: item.quotes?.author,
        category: item.quotes?.category,
      },
      at: item.created_at,
    }));

    return reply.send({ feed });
  });

  // ── GET /social/streak ────────────────────────────────────────────────────
  fastify.get("/streak", async (request, reply) => {
    const deviceId = request.deviceId;

    const { data } = await supabase
      .from("users")
      .select("streak, longest_streak, last_active_date, streak_updated_at")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (!data) {
      return reply.send({ streak: 0, longest: 0, active_today: false });
    }

    const today = new Date().toISOString().split("T")[0];
    const activeToday = data.last_active_date === today;

    return reply.send({
      streak: data.streak || 0,
      longest: data.longest_streak || 0,
      last_active: data.last_active_date,
      active_today: activeToday,
    });
  });

  // ── POST /social/streak/checkin ───────────────────────────────────────────
  fastify.post("/streak/checkin", async (request, reply) => {
    const deviceId = request.deviceId;
    const today = new Date().toISOString().split("T")[0];

    // Get current streak data
    const { data: user } = await supabase
      .from("users")
      .select("streak, longest_streak, last_active_date")
      .eq("device_id", deviceId)
      .maybeSingle();

    if (!user) {
      return reply.status(404).send({ error: "User not found" });
    }

    const lastActive = user.last_active_date;
    let newStreak = user.streak || 0;

    if (lastActive === today) {
      // Already checked in today
      return reply.send({ streak: newStreak, longest: user.longest_streak || 0, already: true });
    }

    // Calculate if streak continues
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split("T")[0];

    if (lastActive === yesterdayStr) {
      newStreak += 1; // Continue streak
    } else {
      newStreak = 1; // Reset streak
    }

    const longest = Math.max(newStreak, user.longest_streak || 0);

    await supabase.from("users").update({
      streak: newStreak,
      longest_streak: longest,
      last_active_date: today,
      streak_updated_at: new Date().toISOString(),
    }).eq("device_id", deviceId);

    return reply.send({ streak: newStreak, longest, milestone: newStreak % 7 === 0 });
  });

  // ── GET /social/qotd ─────────────────────────────────────────────────────
  fastify.get("/qotd", async (request, reply) => {
    const lang = request.query.lang || "en";
    const today = new Date().toISOString().split("T")[0];

    // Check if QOTD exists for today
    let { data: qotd } = await supabase
      .from("quote_of_day")
      .select("quote_id, quotes(id, text, author, category, swipe_dir)")
      .eq("active_date", today)
      .eq("lang", lang)
      .maybeSingle();

    if (!qotd) {
      // Generate QOTD: pick a random highly-liked quote
      const { data: candidates } = await supabase
        .from("quotes")
        .select("id")
        .eq("lang", lang)
        .eq("pack_name", "free")
        .limit(100);

      if (candidates && candidates.length > 0) {
        const pick = candidates[Math.floor(Math.random() * candidates.length)];

        await supabase.from("quote_of_day").insert({
          quote_id: pick.id,
          active_date: today,
          lang,
        });

        const { data: quote } = await supabase
          .from("quotes")
          .select("id, text, author, category, swipe_dir")
          .eq("id", pick.id)
          .single();

        return reply.send({ date: today, quote });
      }
      return reply.send({ date: today, quote: null });
    }

    return reply.send({ date: today, quote: qotd.quotes });
  });
}
