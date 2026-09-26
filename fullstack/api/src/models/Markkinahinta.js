const mongoose = require('mongoose');

const markkinahintaSchema = new mongoose.Schema({
  kortti_nimi: { type: String, required: true, trim: true },
  kunto: { type: String, trim: true, default: '' },
  harvinaisuus: { type: String, trim: true, default: '' },
  setti: { type: String, trim: true, default: '' },
  hinta_eur: { type: Number, default: null },
  varastossa_kpl: { type: Number, default: 0 },
  myynnissa_kpl: { type: Number, default: 0 },
}, {
  collection: 'markkinahinnasto',
});

markkinahintaSchema.index({ kortti_nimi: 'text' });
markkinahintaSchema.index({ setti: 1 });

module.exports = mongoose.model('Markkinahinta', markkinahintaSchema);
