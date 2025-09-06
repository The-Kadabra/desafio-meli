import express from 'express';
import morgan from 'morgan';
import cors from './middleware/cors.mjs';
import customErrors from './middleware/customErrors.mjs';
import apiRoutes from './routes/api.mjs';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(morgan('combined'));
app.use(cors);
app.use(express.json());

app.use('/api', apiRoutes);

app.use(customErrors);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
