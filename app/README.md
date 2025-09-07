# Express API Project

Este é um projeto básico do Node.js que configura uma API Express com configuração CORS e análise automática de JSON.

Para saber como executar este projeto veja em [RUN.MD](/run.md)

## Project Structure

```
express-api-project
├── src
│   ├── index.js          # Entry point of the application
│   ├── routes
│   │   └── api.js        # API routes
│   └── middleware
│       └── cors.js       # CORS middleware
├── package.json           # NPM configuration file
└── README.md              # Project documentation
```

## Getting Started

1. Clone the repository:

   ```
   git clone git@github.com:The-Kadabra/desafio-meli.git
   ```

2. Navigate to the project directory:

   ```
   cd app
   ```

3. Install the dependencies:

   ```
   npm install
   ```

4. Start the application:
   ```
   npm start
   ```

## API Endpoints

- `GET /api` - Returns a 200 status.
