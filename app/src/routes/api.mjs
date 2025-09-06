import express from 'express';
import { readFileSync } from 'fs';

const products = JSON.parse(
  readFileSync(new URL('../../data/products.json', import.meta.url))
);

const router = express.Router();

router.get('/health', (req, res) => {
  res.sendStatus(200);
});

router.get('/products', (req, res) => {
  try {
    res.status(200).json({ products });
  } catch {
    res.status(500).json({ error: 'Erro ao buscar produtos.' });
  }
});

export default router;
