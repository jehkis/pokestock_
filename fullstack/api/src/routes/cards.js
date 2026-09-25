const express = require('express');
const mongoose = require('mongoose');
const Card = require('../models/Card');

const router = express.Router();

function isValidId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

// GET /api/cards
// Query params: kategoria, search, sort (nimi|arvo|kategoria|kunto), order (asc|desc), myyty (true|false)
router.get('/', async (req, res) => {
  try {
    const { kategoria, search, sort = 'arvo', order = 'desc', myyty } = req.query;
    const filter = {};

    if (kategoria && kategoria !== 'Kaikki') {
      filter.kategoria = kategoria;
    }
    if (myyty === 'true') filter['myyty.tila'] = true;
    if (myyty === 'false') filter['myyty.tila'] = { $ne: true };
    if (search) {
      filter.$or = [
        { nimi: { $regex: search, $options: 'i' } },
        { numero: { $regex: search, $options: 'i' } },
      ];
    }

    const sortableFields = ['nimi', 'arvo', 'kategoria', 'kunto', 'lisatty'];
    const sortField = sortableFields.includes(sort) ? sort : 'arvo';
    const sortOrder = order === 'asc' ? 1 : -1;

    const cards = await Card.find(filter).sort({ [sortField]: sortOrder });
    res.json(cards);
  } catch (err) {
    res.status(500).json({ virhe: 'Korttien haku epäonnistui', details: err.message });
  }
});

// GET /api/cards/stats  -- kokonaisarvo ja lukumäärä kategorioittain
router.get('/stats', async (req, res) => {
  try {
    const byCategory = await Card.aggregate([
      { $match: { 'myyty.tila': { $ne: true } } },
      {
        $group: {
          _id: '$kategoria',
          lkm: { $sum: 1 },
          yhteisarvo: { $sum: '$arvo' },
        },
      },
      { $sort: { yhteisarvo: -1 } },
    ]);

    const totalAgg = await Card.aggregate([
      { $match: { 'myyty.tila': { $ne: true } } },
      { $group: { _id: null, yhteisarvo: { $sum: '$arvo' }, lkm: { $sum: 1 } } },
    ]);

    const soldCount = await Card.countDocuments({ 'myyty.tila': true });

    res.json({
      kategoriat: byCategory.map((c) => ({ kategoria: c._id, lkm: c.lkm, yhteisarvo: Math.round(c.yhteisarvo * 100) / 100 })),
      yhteensa: {
        lkm: totalAgg[0]?.lkm || 0,
        yhteisarvo: Math.round((totalAgg[0]?.yhteisarvo || 0) * 100) / 100,
      },
      myyty: soldCount,
    });
  } catch (err) {
    res.status(500).json({ virhe: 'Tilastojen haku epäonnistui', details: err.message });
  }
});

// GET /api/cards/:id
router.get('/:id', async (req, res) => {
  if (!isValidId(req.params.id)) return res.status(400).json({ virhe: 'Virheellinen id' });
  try {
    const card = await Card.findById(req.params.id);
    if (!card) return res.status(404).json({ virhe: 'Korttia ei löytynyt' });
    res.json(card);
  } catch (err) {
    res.status(500).json({ virhe: 'Kortin haku epäonnistui', details: err.message });
  }
});

// POST /api/cards
router.post('/', async (req, res) => {
  try {
    const { nimi, numero, kategoria, kunto, arvo } = req.body;
    const card = new Card({ nimi, numero, kategoria, kunto, arvo });
    await card.save();
    res.status(201).json(card);
  } catch (err) {
    if (err.name === 'ValidationError') {
      return res.status(400).json({ virhe: 'Virheellinen data', details: err.message });
    }
    res.status(500).json({ virhe: 'Kortin lisäys epäonnistui', details: err.message });
  }
});

// PUT /api/cards/:id  -- korvaa muokattavat kentät
router.put('/:id', async (req, res) => {
  if (!isValidId(req.params.id)) return res.status(400).json({ virhe: 'Virheellinen id' });
  try {
    const { nimi, numero, kategoria, kunto, arvo } = req.body;
    const card = await Card.findByIdAndUpdate(
      req.params.id,
      { nimi, numero, kategoria, kunto, arvo },
      { new: true, runValidators: true }
    );
    if (!card) return res.status(404).json({ virhe: 'Korttia ei löytynyt' });
    res.json(card);
  } catch (err) {
    if (err.name === 'ValidationError') {
      return res.status(400).json({ virhe: 'Virheellinen data', details: err.message });
    }
    res.status(500).json({ virhe: 'Kortin päivitys epäonnistui', details: err.message });
  }
});

// PATCH /api/cards/:id/myyty  -- merkitse myydyksi / palauta myymättömäksi
router.patch('/:id/myyty', async (req, res) => {
  if (!isValidId(req.params.id)) return res.status(400).json({ virhe: 'Virheellinen id' });
  try {
    const { tila, hinta, ostaja } = req.body;
    const update = {
      'myyty.tila': !!tila,
      'myyty.pvm': tila ? new Date() : null,
      'myyty.hinta': tila ? (hinta ?? null) : null,
      'myyty.ostaja': tila ? (ostaja || '') : '',
    };
    const card = await Card.findByIdAndUpdate(req.params.id, { $set: update }, { new: true });
    if (!card) return res.status(404).json({ virhe: 'Korttia ei löytynyt' });
    res.json(card);
  } catch (err) {
    res.status(500).json({ virhe: 'Myyntitilan päivitys epäonnistui', details: err.message });
  }
});

// DELETE /api/cards/:id
router.delete('/:id', async (req, res) => {
  if (!isValidId(req.params.id)) return res.status(400).json({ virhe: 'Virheellinen id' });
  try {
    const card = await Card.findByIdAndDelete(req.params.id);
    if (!card) return res.status(404).json({ virhe: 'Korttia ei löytynyt' });
    res.json({ ok: true, poistettu: card._id });
  } catch (err) {
    res.status(500).json({ virhe: 'Kortin poisto epäonnistui', details: err.message });
  }
});

module.exports = router;
