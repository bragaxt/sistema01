// src/server.js (Corrigido)

// Importa as dependências necessárias
const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Inicializa o aplicativo Express
const app = express();

// Configura o middleware CORS para permitir requisições do seu frontend
app.use(cors());

// Configura o middleware para o parsing de JSON
// Isso é essencial para o backend entender os dados enviados pelo frontend
app.use(express.json());

// --- INÍCIO DA ALTERAÇÃO ---
// Importa as rotas de cidades que você já definiu
const cityRoutes = require('./routes/cityRoutes');

// Serve os arquivos estáticos da pasta 'Public' (como index.html, script.js, style.css)
app.use(express.static('src/Public'));

// Define uma rota de teste na raiz
app.get('/', (req, res) => {
  // Envia o arquivo principal da sua aplicação
  res.sendFile(__dirname + '/Public/index.html');
});

// Usa as rotas de cidades com o prefixo '/api/cities'
// Agora o servidor sabe o que fazer com GET, POST, PUT, DELETE para /api/cities
app.use('/api/cities', cityRoutes);

// A rota antiga foi removida daqui para evitar duplicidade, pois já está em cityRoutes.js
// --- FIM DA ALTERAÇÃO ---

// Define a porta do servidor, buscando do arquivo .env ou usando 3001 como padrão
const PORT = process.env.PORT || 3000;

// Inicia o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
  console.log(`Acesse a aplicação em http://localhost:${PORT}`);
});
