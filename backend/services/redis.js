import { createClient } from 'redis';

let redis = null;

const REDIS_HOST = process.env.REDIS_HOST || 'redis';
const REDIS_PORT = process.env.REDIS_PORT || '6379';
const REDIS_URL =
  process.env.REDIS_URL || `redis://${REDIS_HOST}:${REDIS_PORT}`;

export async function connectToRedis() {
  // 🚀 Skip Redis connection during testing
  if (process.env.NODE_ENV === 'test') {
    console.log('⚡ Skipping Redis connection in test mode');
    return;
  }

  try {
    redis = createClient({ url: REDIS_URL });

    redis.on('error', (err) => {
      console.error('Redis runtime error:', err.message);
    });

    await redis.connect();
    console.log(`✅ Redis connected: ${REDIS_URL}`);
  } catch (error) {
    console.error('❌ Error connecting to Redis:', error.message);
  }
}

export function getRedisClient() {
  return redis;
}
