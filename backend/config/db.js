import mongoose from 'mongoose';

const MONGO_HOST = process.env.MONGO_HOST || 'mongo';
const MONGO_PORT = process.env.MONGO_PORT || '27017';
const MONGO_DB   = process.env.MONGO_DB   || 'wanderlust';

const MONGODB_URI =
  process.env.MONGODB_URI ||
  `mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}`;

export default async function connectDB() {
  // 🚀 Skip DB connection during testing
  if (process.env.NODE_ENV === 'test') {
    console.log('⚡ Skipping MongoDB connection in test mode');
    return;
  }

  try {
    await mongoose.connect(MONGODB_URI);
    console.log(`✅ Database connected: ${MONGODB_URI}`);
  } catch (err) {
    console.error('❌ MongoDB connection failed');
    console.error(err.message);
    process.exit(1);
  }

  mongoose.connection.on('error', (err) => {
    console.error('MongoDB runtime error:', err.message);
  });
}
