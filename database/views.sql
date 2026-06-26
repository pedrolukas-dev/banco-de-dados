USE petvida;

CREATE OR REPLACE VIEW vw_consultas_completas AS
SELECT 
    c.data_hora,
    c.status,
    c.diagnostico,
    c.valor,
    a.nome AS animal,
    e.nome AS especie,
    t.nome AS tutor,
    t.telefone,
    v.nome AS veterinario,
    v.especialidade,
    p.forma_pagamento,
    p.status AS status_pagamento
FROM consultas c
INNER JOIN animais a ON c.animal_id = a.id
INNER JOIN especies e ON a.especie_id = e.id
INNER JOIN tutores t ON a.tutor_id = t.id
INNER JOIN veterinarios v ON c.veterinario_id = v.id
LEFT JOIN pagamentos p ON p.consulta_id = c.id;

CREATE OR REPLACE VIEW vw_agenda_hoje AS
SELECT * FROM vw_consultas_completas
WHERE DATE(data_hora) = CURDATE()
ORDER BY data_hora ASC;

CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT 
    YEAR(data_hora) AS ano,
    MONTH(data_hora) AS mes,
    veterinario,
    COUNT(*) AS total_consultas,
    SUM(valor) AS faturamento_total
FROM vw_consultas_completas
WHERE status_pagamento = 'pago'
GROUP BY YEAR(data_hora), MONTH(data_hora), veterinario;

CREATE OR REPLACE VIEW vw_animais_detalhados AS
SELECT 
    a.id AS id_animal,
    a.nome AS nome_animal,
    e.nome AS especie,
    t.nome AS nome_tutor,
    COUNT(c.id) AS quantidade_consultas
FROM animais a
INNER JOIN especies e ON a.especie_id = e.id
INNER JOIN tutores t ON a.tutor_id = t.id
LEFT JOIN consultas c ON c.animal_id = a.id
GROUP BY a.id, a.nome, e.nome, t.nome;

CREATE OR REPLACE VIEW vw_inadimplentes AS
SELECT 
    data_hora,
    tutor,
    telefone,
    animal,
    valor,
    status_pagamento
FROM vw_consultas_completas
WHERE status = 'concluida' 
  AND (status_pagamento = 'pendente' OR status_pagamento IS NULL);