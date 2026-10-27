/**
 * High-performance, zero-dependency in-memory sliding window rate limiter
 * Protects public endpoints from automated request floods and upstream quota exhaustion.
 */

function createRateLimiter({ windowMs = 60 * 1000, max = 100, message = 'Too many requests. Please try again later.' }) {
  const hits = new Map();

  // Periodic cleanup of stale entries every 2 minutes
  const cleanupInterval = setInterval(() => {
    const now = Date.now();
    for (const [key, record] of hits.entries()) {
      if (now - record.resetTime > windowMs) {
        hits.delete(key);
      }
    }
  }, 2 * 60 * 1000);

  // Prevent cleanup from blocking process exit
  if (cleanupInterval.unref) {
    cleanupInterval.unref();
  }

  return function rateLimiter(req, res, next) {
    const ip = req.ip || req.connection.remoteAddress || 'unknown-client';
    const now = Date.now();

    let record = hits.get(ip);
    if (!record || now > record.resetTime) {
      record = {
        count: 1,
        resetTime: now + windowMs
      };
      hits.set(ip, record);
    } else {
      record.count++;
    }

    const remaining = Math.max(0, max - record.count);
    const resetSeconds = Math.ceil((record.resetTime - now) / 1000);

    res.setHeader('X-RateLimit-Limit', max);
    res.setHeader('X-RateLimit-Remaining', remaining);
    res.setHeader('X-RateLimit-Reset', resetSeconds);

    if (record.count > max) {
      res.setHeader('Retry-After', resetSeconds);
      return res.status(429).json({
        success: false,
        error: 'RATE_LIMIT_EXCEEDED',
        message: message,
        retryAfterSeconds: resetSeconds
      });
    }

    next();
  };
}

const generalLimiter = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 120, // 120 requests per minute per IP for regular browsing/polling
  message: 'Request rate limit exceeded. Please wait a moment before refreshing.'
});

const aiLimiter = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 20, // 20 requests per minute per IP for AI endpoints
  message: 'AI request limit exceeded. Please wait a minute before sending more queries.'
});

// Dedicated Contact Submission Limiter: 5 requests / 15 min / IP to prevent spam & mail floods
const contactLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per 15 min per IP
  message: 'Too many contact submissions from this IP. Please wait 15 minutes before submitting again.'
});

module.exports = {
  createRateLimiter,
  generalLimiter,
  aiLimiter,
  contactLimiter
};
