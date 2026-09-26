// Tayttaa MongoDB:n yleisella markkinahintaviitteella (~36 600 riv.).
// Aja: npm run seed:hinnat  (tai: node seed/seed-markkinahinnasto.js)
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { connectDB } = require('../src/db');
const Markkinahinta = require('../src/models/Markkinahinta');

async function seed() {
  await connectDB();

  const existing = await Markkinahinta.countDocuments();
  if (existing > 0) {
    console.log(`[seed:hinnat] Kannassa on jo ${existing} riviä. Ei tehda mitaan.`);
    console.log('[seed:hinnat] Tyhjenna ensin jos haluat siemenata uudelleen: db.markkinahinnasto.deleteMany({})');
    await mongoose.disconnect();
    return;
  }

  const raw = fs.readFileSync(path.join(__dirname, 'markkinahinnasto.json'), 'utf-8');
  const rows = JSON.parse(raw);

  const BATCH = 2000;
  for (let i = 0; i < rows.length; i += BATCH) {
    const chunk = rows.slice(i, i + BATCH);
    await Markkinahinta.insertMany(chunk, { ordered: false });
    console.log(`[seed:hinnat] ${Math.min(i + BATCH, rows.length)} / ${rows.length}`);
  }

  console.log(`[seed:hinnat] Valmis. Lisatty ${rows.length} riviä.`);
  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error('[seed:hinnat] Epaonnistui:', err);
  process.exit(1);
});
