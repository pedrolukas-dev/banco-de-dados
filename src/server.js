const express = require('express');
const pool = require('./db');

const app = express();
app.use(express.json());

// 1) GET /api/veterinarios — lista veterinários
app.get('/api/veterinarios', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM veterinarios');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2) GET /api/animais — usa vw_animais_detalhados
app.get('/api/animais', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM vw_animais_detalhados');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 3) GET /api/agenda/:data — usa vw_consultas_completas filtrada
app.get('/api/agenda/:data', async (req, res) => {
    try {
        const { data } = req.params;
        const [rows] = await pool.query('SELECT * FROM vw_consultas_completas WHERE DATE(data_hora) = ?', [data]);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 4) POST /api/consultas — chama CALL sp_agendar_consulta
app.post('/api/consultas', async (req, res) => {
    try {
        const { animal_id, veterinario_id, data_hora, valor } = req.body;
        await pool.query('CALL sp_agendar_consulta(?, ?, ?, ?)', [animal_id, veterinario_id, data_hora, valor]);
        res.status(201).json({ message: 'Consulta agendada com sucesso!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 5) PUT /api/consultas/:id/concluir — chama CALL sp_concluir_consulta
app.put('/api/consultas/:id/concluir', async (req, res) => {
    try {
        const { id } = req.params;
        const { diagnostico } = req.body;
        await pool.query('CALL sp_concluir_consulta(?, ?)', [id, diagnostico]);
        res.json({ message: 'Consulta concluída com sucesso!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 6) POST /api/pagamentos/:consulta_id — chama CALL sp_registrar_pagamento
app.post('/api/pagamentos/:consulta_id', async (req, res) => {
    try {
        const { consulta_id } = req.params;
        const { valor_pago, forma_pagamento } = req.body;
        await pool.query('CALL sp_registrar_pagamento(?, ?, ?)', [consulta_id, valor_pago, forma_pagamento]);
        res.status(201).json({ message: 'Pagamento registrado com sucesso!' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 7) GET /api/relatorios/dashboard — query do dashboard financeiro
app.get('/api/relatorios/dashboard', async (req, res) => {
    try {
        const query = `
            SELECT 
                COUNT(c.id) AS total_consultas,
                SUM(c.valor) AS faturamento_bruto,
                SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END) AS total_recebido,
                SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END) AS total_pendente,
                ROUND((SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END) / NULLIF(SUM(c.valor), 0)) * 100, 2) AS percentual_inadimplencia
            FROM consultas c
            LEFT JOIN pagamentos p ON c.id = p.consulta_id
        `;
        const [rows] = await pool.query(query);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 8) GET /api/relatorios/inadimplentes — usa vw_inadimplentes
app.get('/api/relatorios/inadimplentes', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM vw_inadimplentes');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Inicia o servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
