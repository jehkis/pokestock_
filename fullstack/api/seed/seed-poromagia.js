// Tayttaa MongoDB:n Poromagian koko Pokemon-irtokorttivalikoimalla (viitehintoja varten).
// Aja: npm run seed:poromagia  (tai: node seed/seed-poromagia.js)
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { connectDB } = require('../src/db');
const PoromagiaHinnasto = require('../src/models/PoromagiaHinnasto');

async function seed() {
  await connectDB();

  const existing = await PoromagiaHinnasto.countDocuments();
  if (existing > 0) {
    console.log(`[seed:poromagia] Kannassa on jo ${existing} riviä. Ei tehda mitaan.`);
    console.log('[seed:poromagia] Tyhjenna ensin jos haluat siemenata uudelleen: db.poromagia_hinnasto.deleteMany({})');
    await mongoose.disconnect();
    return;
  }

  const raw = fs.readFileSync(path.join(__dirname, 'poromagia_hinnasto.json'), 'utf-8');
  const rows = JSON.parse(raw);

  const BATCH = 2000;
  for (let i = 0; i < rows.length; i += BATCH) {
    const chunk = rows.slice(i, i + BATCH);
    await PoromagiaHinnasto.insertMany(chunk, { ordered: false });
    console.log(`[seed:poromagia] ${Math.min(i + BATCH, rows.length)} / ${rows.length}`);
  }

  console.log(`[seed:poromagia] Valmis. Lisatty ${rows.length} riviä.`);
  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error('[seed:poromagia] Epaonnistui:', err);
  process.exit(1);
});
