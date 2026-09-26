const express = require('express');
const PoromagiaHinnasto = require('../models/PoromagiaHinnasto');

const router = express.Router();

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// GET /api/hinta-haku?nimi=Charizard&numero=12/108
// Etsii Poromagian hinnastosta kortin, jonka nimi alkaa annetulla nimella
// ja joka sisaltaa annetun numeron. Palauttaa parhaan (halvimman NM/M,
// ei-Reverse Holo) osuman seka muut loydetyt vaihtoehdot.
router.get('/', async (req, res) => {
  try {
    const { nimi, numero } = req.query;
    if (!nimi || !nimi.trim()) {
      return res.status(400).json({ virhe: 'Parametri "nimi" on pakollinen' });
    }

    const nimiRegex = new RegExp(`^${escapeRegex(nimi.trim())}\\b`, 'i');
    const query = { kortti_nimi: { $regex: nimiRegex } };

    if (numero && numero.trim()) {
      const numeroRegex = new RegExp(escapeRegex(numero.trim()), 'i');
      query.kortti_nimi.$regex = new RegExp(
        `^${escapeRegex(nimi.trim())}\\b(?=.*${escapeRegex(numero.trim())})`,
        'i'
      );
    }

    let candidates = await PoromagiaHinnasto.find(query).limit(50).lean();

    if (!candidates.length) {
      return res.json({ loytyi: false, ehdotukset: [] });
    }

    // Pisteytys: ei-Reverse Holo ensin, sitten NM/M-kunto, sitten halvin hinta
    const isReverse = (c) => /reverse holo/i.test(c.kortti_nimi);
    const rank = (c) => {
      let score = 0;
      if (!isReverse(c)) score += 100;
      if (c.kunto === 'NM/M') score += 10;
      if (c.hinta_eur != null) score += 1;
      return score;
    };
    candidates.sort((a, b) => {
      const rankDiff = rank(b) - rank(a);
      if (rankDiff !== 0) return rankDiff;
      const priceA = a.hinta_eur ?? Infinity;
      const priceB = b.hinta_eur ?? Infinity;
      return priceA - priceB;
    });

    const paras = candidates[0];
    const muut = candidates.slice(1, 6);

    res.json({
      loytyi: true,
      paras: {
        kortti_nimi: paras.kortti_nimi,
        setti: paras.setti,
        kunto: paras.kunto,
        harvinaisuus: paras.harvinaisuus,
        hinta_eur: paras.hinta_eur,
        varastossa_kpl: paras.varastossa_kpl,
      },
      ehdotukset: muut.map((c) => ({
        kortti_nimi: c.kortti_nimi,
        setti: c.setti,
        kunto: c.kunto,
        hinta_eur: c.hinta_eur,
        varastossa_kpl: c.varastossa_kpl,
      })),
    });
  } catch (err) {
    res.status(500).json({ virhe: 'Hintahaku epäonnistui', details: err.message });
  }
});

module.exports = router;
