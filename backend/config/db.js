import mongoose from 'mongoose';

const MONGO_HOST = process.env.MONGO_HOST || 'mongo-service';
const MONGO_PORT = process.env.MONGO_PORT || '27017';
const MONGO_DB   = process.env.MONGO_DB   || 'wanderlust';

// Final connection string
const MONGODB_URI =
  process.env.MONGODB_URI ||
  `mongodb://${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}`;

export default async function connectDB() {
  try {
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ Database connected successfully: ${MONGODB_URI}`);
  } catch (err) {
    console.error('❌ MongoDB connection failed');
    console.error(err.message);
    process.exit(1);
  }

  const dbConnection = mongoose.connection;

  dbConnection.on('error', (err) => {
    console.error('MongoDB runtime error:', err.message);
  });
}
