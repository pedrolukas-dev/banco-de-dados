SELECT 
    RANK() OVER (ORDER BY SUM(c.valor) DESC) AS posicao,
    t.nome AS tutor,
    SUM(c.valor) AS total_gasto,
    COUNT(c.id) AS qtd_consultas
FROM tutores t
JOIN animais a ON t.id = a.tutor_id
JOIN consultas c ON a.id = c.animal_id
GROUP BY t.id, t.nome
ORDER BY total_gasto DESC;

SELECT 
    DATE_FORMAT(c.data_hora, '%Y-%m') AS mes_ano,
    COUNT(c.id) AS total_consultas,
    SUM(c.valor) AS faturamento_bruto,
    SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END) AS total_recebido,
    SUM(CASE WHEN p.status = 'pendente' THEN p.valor_pago ELSE 0 END) AS total_pendente
FROM consultas c
LEFT JOIN pagamentos p ON c.id = p.consulta_id
GROUP BY mes_ano
ORDER BY mes_ano DESC;

SELECT 
    a.nome AS animal,
    t.nome AS tutor,
    MAX(c.data_hora) AS ultima_consulta,
    DATEDIFF(CURDATE(), MAX(