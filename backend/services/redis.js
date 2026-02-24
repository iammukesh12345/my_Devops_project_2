import { createClient } from 'redis';

let redis = null;

const REDIS_HOST = process.env.REDIS_HOST || 'redis-service';
const REDIS_PORT = process.env.REDIS_PORT || '6379';

// Final Redis URL
const REDIS_URL =
  process.env.REDIS_URL || `redis://${REDIS_HOST}:${REDIS_PORT}`;

export async function connectToRedis() {
  try {
    redis = createClient({
      url: REDIS_URL,
      socket: {
        reconnectStrategy: (retries) => {
          console.log(`Redis reconnect attempt: ${retries}`);
          return Math.min(retries * 100, 3000);
        },
      },
      disableOfflineQueue: true,
    });

    redis.on('connect', () => {
      console.log(`✅ Redis Connected: ${REDIS_URL}`);
    });

    redis.on('error', (err) => {
      console.error('❌ Redis runtime error:', err.message);
    });

    await redis.connect();
  } catch (error) {
    console.error('❌ Error connecting to Redis:', error.message);
    console.log('⚠️ App will continue without Redis.');
  }
}

export function getRedisClient() {
  return redis;
}
