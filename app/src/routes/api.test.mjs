import request from 'supertest';
import express from 'express';
import apiRoutes from './api.js';

const app = express();
app.use(express.json());
app.use('/api', apiRoutes);


it('deve retornar status 200 e uma lista de produtos', async () => {
    const response = await request(app).get('/api/products');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('products');
    expect(Array.isArray(response.body.products)).toBe(true);

    expect(response.body.products.length).toBeGreaterThan(0);

    const product = response.body.products[0];
    expect(product).toHaveProperty('name');
    expect(product).toHaveProperty('imageUrl');
    expect(product).toHaveProperty('description');
    expect(product).toHaveProperty('price');
    expect(product).toHaveProperty('rating');
    expect(product).toHaveProperty('specs');
});
