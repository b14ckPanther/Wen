const admin = require('firebase-admin');

const projectId = process.env.FIREBASE_PROJECT_ID || 'wen-dev-noor';

if (!admin.apps.length) {
  admin.initializeApp({
    projectId,
  });
}

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

const now = admin.firestore.Timestamp.now();

function buildSearchKeywords(...texts) {
  const tokens = new Set();
  texts
    .filter(Boolean)
    .forEach((text) => {
      text
        .toString()
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .filter(Boolean)
        .forEach((token) => {
          if (token.length >= 2) {
            tokens.add(token);
          }
        });
    });
  return Array.from(tokens);
}

async function seedCategories(batch) {
  const categories = [
    { id: 'restaurants', name: 'Restaurants', parentId: null },
    { id: 'cafes', name: 'Cafés', parentId: 'restaurants' },
    { id: 'retail', name: 'Retail & Shopping', parentId: null },
    { id: 'beauty', name: 'Beauty & Wellness', parentId: null },
    { id: 'services', name: 'Professional Services', parentId: null },
  ];

  categories.forEach((category) => {
    batch.set(db.collection('categories').doc(category.id), {
      name: category.name,
      parentId: category.parentId,
    });
  });
}

async function seedUsers(batch) {
  const users = [
    {
      id: 'admin-001',
      name: 'Wen Admin',
      email: 'admin@wen.dev',
      role: 'admin',
      plan: 'premium',
    },
    {
      id: 'owner-001',
      name: 'Layla Business Owner',
      email: 'layla@almadina.ae',
      role: 'owner',
      plan: 'standard',
    },
    {
      id: 'user-001',
      name: 'Omar Explorer',
      email: 'omar@wen.dev',
      role: 'user',
      plan: 'free',
    },
  ];

  users.forEach((user) => {
    batch.set(db.collection('users').doc(user.id), {
      name: user.name,
      email: user.email,
      role: user.role,
      plan: user.plan,
      createdAt: now,
      updatedAt: now,
    });
  });
}

async function seedBusinesses(batch) {
  const businesses = [
    {
      id: 'business-001',
      name: 'Al Madina Bistro',
      description:
        'Modern Emirati fusion cuisine with a rooftop terrace overlooking the creek.',
      categoryId: 'restaurants',
      location: new admin.firestore.GeoPoint(25.2048, 55.2708),
      ownerId: 'owner-001',
      plan: 'standard',
      approved: true,
      images: [],
    },
    {
      id: 'business-002',
      name: 'Palm Beauty Lounge',
      description:
        'Luxury beauty lounge specialising in organic treatments and spa experiences.',
      categoryId: 'beauty',
      location: new admin.firestore.GeoPoint(25.1291, 55.1170),
      ownerId: 'owner-001',
      plan: 'free',
      approved: false,
      images: [],
    },
  ];

  businesses.forEach((business) => {
    batch.set(db.collection('businesses').doc(business.id), {
      name: business.name,
      description: business.description,
      categoryId: business.categoryId,
      location: business.location,
      ownerId: business.ownerId,
      plan: business.plan,
      approved: business.approved,
      images: business.images,
      searchKeywords: buildSearchKeywords(
        business.name,
        business.description,
        business.categoryId,
      ),
      createdAt: now,
      updatedAt: now,
    });
  });
}

async function seedProducts(batch) {
  const products = [
    {
      id: 'product-001',
      businessId: 'business-001',
      name: 'Saffron Lamb Tagine',
      price: 95.0,
      image: null,
    },
    {
      id: 'product-002',
      businessId: 'business-001',
      name: 'Date & Cardamom Latte',
      price: 28.0,
      image: null,
    },
  ];

  products.forEach((product) => {
    batch.set(db.collection('products').doc(product.id), {
      businessId: product.businessId,
      name: product.name,
      price: product.price,
      image: product.image,
    });
  });
}

async function seedTransactions(batch) {
  const transactions = [
    {
      id: 'txn-001',
      userId: 'owner-001',
      plan: 'standard',
      status: 'succeeded',
      amount: 499.0,
      createdAt: now,
    },
    {
      id: 'txn-002',
      userId: 'owner-001',
      plan: 'premium',
      status: 'pending',
      amount: 999.0,
      createdAt: now,
    },
  ];

  transactions.forEach((txn) => {
    batch.set(db.collection('transactions').doc(txn.id), txn);
  });
}

async function seed() {
  console.log(`Seeding Firestore for project ${projectId}...`);
  const batch = db.batch();

  await seedCategories(batch);
  await seedUsers(batch);
  await seedBusinesses(batch);
  await seedProducts(batch);
  await seedTransactions(batch);

  await batch.commit();
  console.log('Seed data written successfully.');
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Error seeding Firestore:', error);
    process.exit(1);
  });
