import type { NextConfig } from "next";
import path from "node:path";

const nextConfig: NextConfig = {
  // Pin Turbopack root to web/ so it ignores the legacy lockfiles
  // (frontend/, frontend_legacy/, root) sitting elsewhere in the monorepo.
  turbopack: {
    root: path.join(__dirname),
  },
};

export default nextConfig;
