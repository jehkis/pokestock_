const mongoose = require('mongoose');

const poromagiaHinnastoSchema = new mongoose.Schema({
  kortti_nimi: { type: String, required: true, trim: true },
  kunto: { type: String, trim: true, default: '' },
  harvinaisuus: { type: String, trim: true, default: '' },
  setti: { type: String, trim: true, default: '' },
  hinta_eur: { type: Number, default: null },
  varastossa_kpl: { type: Number, default: 0 },
  myymalassa_kpl: { type: Number, default: 0 },
}, {
  collection: 'poromagia_hinnasto',
});

poromagiaHinnastoSchema.index({ kortti_nimi: 'text' });
poromagiaHinnastoSchema.index({ setti: 1 });

module.exports = mongoose.model('PoromagiaHinnasto', poromagiaHinnastoSchema);
