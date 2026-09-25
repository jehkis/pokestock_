require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const { connectDB } = require('./src/db');
const cardsRouter = require('./src/routes/cards');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/health', (req, res) => res.json({ ok: true, service: 'pokestock-api' }));
app.use('/api/cards', cardsRouter);

app.use('/api', (req, res) => res.status(404).json({ virhe: 'Reittiä ei löytynyt' }));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ virhe: 'Palvelinvirhe', details: err.message });
});

async function start() {
  await connectDB();
  app.listen(PORT, () => {
    console.log(`[api] PokeStock API kuuntelee portissa ${PORT}`);
  });
}

start().catch((err) => {
  console.error('[api] Käynnistys epäonnistui:', err);
  process.exit(1);
});
