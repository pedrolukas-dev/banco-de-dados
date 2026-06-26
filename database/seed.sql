-- =================================================================
-- SCRIPT DE CARGA DE DADOS DE EXEMPLO (SEED) - PETVIDA
-- =================================================================

USE petvida;

-- 1) Inserindo 5 Espécies
INSERT INTO especies (nome) VALUES 
('Cachorro'), ('Gato'), ('Pássaro'), ('Peixe'), ('Réptil');

-- 2) Inserindo 3 Veterinários
INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES
('Dr. Carlos Silva', 'CRMV-SP12345', 'Clínica Geral', '(11) 98888-1111'),
('Dra. Juliana Mendes', 'CRMV-SP67890', 'Felinos', '(11) 98888-2222'),
('Dr. André Souza', 'CRMV-SP54321', 'Animais Silvestres', '(11) 98888-3333');

-- 3) Inserindo 8 Tutores
INSERT INTO tutores (nome, cpf, email, telefone) VALUES
('Marcos Oliveira', '111.111.111-11', 'marcos@email.com', '(11) 97777-0001'),
('Ana Costa', '222.222.222-22', 'ana@email.com', '(11) 97777-0002'),
('Roberto Santos', '333.333.333-33', 'roberto@email.com', '(11) 97777-0003'),
('Camila Lima', '444.444.444-44', 'camila@email.com', '(11) 97777-0004'),
('Lucas Pereira', '555.555.555-55', 'lucas@email.com', '(11) 97777-0005'),
('Beatriz Rocha', '666.666.666-66', 'beatriz@email.com', '(11) 97777-0006'),
('Ricardo Alves', '777.777.777-77', 'ricardo@email.com', '(11) 97777-0007'),
('Amanda Souza', '888.888.888-88', 'amanda@email.com', '(11) 97777-0008');

-- 4) Inserindo 15 Animais (Intercalando espécies e tutores)
INSERT INTO animais (nome, especie_id, raca, data_nascimento, tutor_id) VALUES
('Thor', 1, 'Golden Retriever', '2021-05-10', 1), -- Tutor 1, Cachorro
('Luna', 2, 'Siamês', '2022-03-15', 1),           -- Tutor 1, Gato
('Mel', 1, 'Poodle', '2020-08-20', 2),             -- Tutor 2, Cachorro
('Max', 1, 'Pastor Alemão', '2019-01-12', 3),      -- Tutor 3, Cachorro
('Fred', 3, 'Calopsita', '2023-01-01', 3),         -- Tutor 3, Pássaro
('Pipoca', 2, 'Persa', '2021-11-30', 4),           -- Tutor 4, Gato
('Nemo', 4, 'Peixe Palhaço', '2024-02-10', 4),     -- Tutor 4, Peixe
('Rex', 1, 'Vira-lata', '2018-07-04', 5),          -- Tutor 5, Cachorro
('Mia', 2, 'Angorá', '2022-06-18', 5),             -- Tutor 5, Gato
('Ziggy', 5, 'Iguana', '2020-10-05', 6),           -- Tutor 6, Réptil
('Bela', 1, 'Labrador', '2022-09-14', 6),          -- Tutor 6, Cachorro
('Cookie', 1, 'Chihuahua', '2023-04-22', 7),       -- Tutor 7, Cachorro
('Simba', 2, 'Sem Raça Definida', '2023-07-11', 7),-- Tutor 7, Gato
('Bob', 1, 'Pug', '2021-12-25', 8),                -- Tutor 8, Cachorro
('Frida', 2, 'Bengal', '2020-02-14', 8);           -- Tutor 8, Gato

-- 5) Inserindo 20 Consultas 
-- (Ajustei algumas para a data de hoje, passadas e futuras para validar as views)
INSERT INTO consultas (animal_id, veterinario_id, data_hora, diagnostico, valor, status) VALUES
(1, 1, '2026-06-20 10:00:00', 'Check-up anual, animal saudável.', 150.00, 'concluida'),
(2, 2, '2026-06-21 14:30:00', 'Suspeita de gastrite, medicado.', 180.00, 'concluida'),
(3, 1, '2026-06-22 09:00:00', 'Limpeza de tártaro agendada.', 150.00, 'concluida'),
(4, 1, '2026-06-23 11:00:00', 'Otite externa crônica, aplicação de otomax.', 160.00, 'concluida'),
(5, 3, '2026-06-24 16:00:00', 'Corte de asas e unhas.', 90.00, 'concluida'),
(6, 2, '2026-06-25 15:00:00', 'Vacinação quádrupla felina.', 130.00, 'concluida'),
-- Consultas de HOJE (Para testar a vw_agenda_hoje)
(7, 3, CONCAT(CURDATE(), ' 08:30:00'), 'Consulta de rotina aquário.', 120.00, 'concluida'),
(1, 1, CONCAT(CURDATE(), ' 10:00:00'), 'Retorno tratamento otite.', 100.00, 'em_atendimento'),
(8, 1, CONCAT(CURDATE(), ' 14:00:00'), NULL, 150.00, 'agendada'),
(9, 2, CONCAT(CURDATE(), ' 16:30:00'), NULL, 150.00, 'agendada'),
-- Outras Consultas do mês
(10, 3, '2026-06-26 10:30:00', 'Suplementação de cálcio para réptil.', 200.00, 'concluida'),
(11, 1, '2026-06-27 11:30:00', NULL, 150.00, 'agendada'),
(12, 1, '2026-06-27 13:00:00', NULL, 150.00, 'agendada'),
(13, 2, '2026-06-28 09:30:00', NULL, 180.00, 'agendada'),
(14, 1, '2026-06-28 15:00:00', NULL, 150.00, 'agendada'),
(15, 2, '2026-06-29 10:00:00', NULL, 180.00, 'agendada'),
(2, 2, '2026-06-29 14:00:00', NULL, 120.00, 'agendada'),
(3, 1, '2026-06-30 11:00:00', NULL, 150.00, 'agendada'),
(4, 1, '2026-06-30 16:00:00', NULL, 150.00, 'agendada'),
(1, 1, '2026-06-15 09:00:00', 'Problema de pele, uso de shampoo.', 150.00, 'concluida');

-- 6) Inserindo 20 Pagamentos correspondentes às 20 consultas anteriores
-- Note que algumas concluídas estão 'pendente' ou sem registro para simular inadimplência.
INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, data_pagamento, status) VALUES
(1, 150.00, 'pix', '2026-06-20 10:45:00', 'pago'),
(2, 180.00, 'cartao', '2026-06-21 15:10:00', 'pago'),
(3, 150.00, 'dinheiro', '2026-06-22 09:40:00', 'pago'),
(4, 160.00, 'cartao', '2026-06-23 11:35:00', 'pago'),
(5, 90.00, 'pix', '2026-06-24 16:20:00', 'pago'),
(6, 0.00, 'dinheiro', NULL, 'pendente'), -- Inadimplente: serviço feito, mas não pago.
(7, 120.00, 'pix', CONCAT(CURDATE(), ' 09:00:00'), 'pago'),
(8, 0.00, 'cartao', NULL, 'pendente'),
(9, 0.00, 'pix', NULL, 'pendente'),
(10, 0.00, 'dinheiro', NULL, 'pendente'), -- Outro inadimplente
(11, 0.00, 'convenio', NULL, 'pendente'),
(12, 0.00, 'cartao', NULL, 'pendente'),
(13, 0.00, 'pix', NULL, 'pendente'),
(14, 0.00, 'dinheiro', NULL, 'pendente'),
(15, 0.00, 'convenio', NULL, 'pendente'),
(16, 0.00, 'cartao', NULL, 'pendente'),
(17, 0.00, 'pix', NULL, 'pendente'),
(18, 0.00, 'dinheiro', NULL, 'pendente'),
(19, 0.00, 'cartao', NULL, 'pendente'),
(20, 150.00, 'pix', '2026-06-15 09:50:00', 'pago');