USE petvida;

DELIMITER $$

-- 1) sp_agendar_consulta
CREATE PROCEDURE sp_agendar_consulta(
    IN p_animal_id INT,
    IN p_vet_id INT,
    IN p_data_hora DATETIME,
    IN p_valor DECIMAL(10,2)
)
BEGIN
    DECLARE v_existe_animal INT;
    DECLARE v_existe_vet INT;
    DECLARE v_horario_ocupado INT;
    DECLARE v_consulta_id INT;

    SELECT COUNT(*) INTO v_existe_animal FROM animais WHERE id = p_animal_id;
    IF v_existe_animal = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Animal não cadastrado.';
    END IF;

    SELECT COUNT(*) INTO v_existe_vet FROM veterinarios WHERE id = p_vet_id;
    IF v_existe_vet = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Veterinário não cadastrado.';
    END IF;

    SELECT COUNT(*) INTO v_horario_ocupado FROM consultas 
    WHERE veterinario_id = p_vet_id AND data_hora = p_data_hora AND status != 'cancelada';
    IF v_horario_ocupado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: O veterinário já possui consulta nesse horário.';
    END IF;

    START TRANSACTION;
        INSERT INTO consultas (animal_id, veterinario_id, data_hora, valor, status)
        VALUES (p_animal_id, p_vet_id, p_data_hora, p_valor, 'agendada');
        
        SET v_consulta_id = LAST_INSERT_ID();
        
        INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status)
        VALUES (v_consulta_id, 0.00, 'pix', 'pendente');
    COMMIT;
END $$

-- 2) sp_concluir_consulta
CREATE PROCEDURE sp_concluir_consulta(
    IN p_consulta_id INT,
    IN p_diagnostico TEXT
)
BEGIN
    DECLARE v_existe_consulta INT;
    
    SELECT COUNT(*) INTO v_existe_consulta FROM consultas WHERE id = p_consulta_id;
    IF v_existe_consulta = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Consulta não encontrada.';
    END IF;

    UPDATE consultas 
    SET status = 'concluida', diagnostico = p_diagnostico 
    WHERE id = p_consulta_id;
END $$

-- 3) sp_registrar_pagamento
CREATE PROCEDURE sp_registrar_pagamento(
    IN p_consulta_id INT,
    IN p_forma VARCHAR(20)
)
BEGIN
    DECLARE v_existe_pagamento INT;
    DECLARE v_status_atual VARCHAR(20);
    DECLARE v_valor_consulta DECIMAL(10,2);

    SELECT COUNT(*), status, valor_pago INTO v_existe_pagamento, v_status_atual, v_valor_consulta
    FROM pagamentos WHERE consulta_id = p_consulta_id GROUP BY id;

    IF v_existe_pagamento IS NULL OR v_existe_pagamento = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Registro de pagamento não encontrado para esta consulta.';
    END IF;

    IF v_status_atual = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Esta consulta já foi paga.';
    END IF;
    
    SELECT valor INTO v_valor_consulta FROM consultas WHERE id = p_consulta_id;

    UPDATE pagamentos 
    SET status = 'pago', forma_pagamento = p_forma, valor_pago = v_valor_consulta, data_pagamento = NOW()
    WHERE consulta_id = p_consulta_id;
END $$

-- 4) sp_cancelar_consulta
CREATE PROCEDURE sp_cancelar_consulta(
    IN p_consulta_id INT
)
BEGIN
    DECLARE v_existe_consulta INT;

    SELECT COUNT(*) INTO v_existe_consulta FROM consultas WHERE id = p_consulta_id;
    IF v_existe_consulta = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Consulta não encontrada.';
    END IF;

    START TRANSACTION;
        UPDATE consultas SET status = 'cancelada' WHERE id = p_consulta_id;
        UPDATE pagamentos SET status = 'cancelado' WHERE consulta_id = p_consulta_id;
    COMMIT;
END $$

-- 5) sp_cadastrar_animal
CREATE PROCEDURE sp_cadastrar_animal(
    IN p_nome VARCHAR(50),
    IN p_especie_id INT,
    IN p_raca VARCHAR(50),
    IN p_nascimento DATE,
    IN p_tutor_id INT
)
BEGIN
    DECLARE v_existe_especie INT;
    DECLARE v_existe_tutor INT;

    SELECT COUNT(*) INTO v_existe_especie FROM especies WHERE id = p_especie_id;
    IF v_existe_especie = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Espécie informada não existe.';
    END IF;

    SELECT COUNT(*) INTO v_existe_tutor FROM tutores WHERE id = p_tutor_id;
    IF v_existe_tutor = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Tutor informado não existe.';
    END IF;

    INSERT INTO animais (nome, especie_id, raca, data_nascimento, tutor_id)
    VALUES (p_nome, p_especie_id, p_raca, p_nascimento, p_tutor_id);

    SELECT LAST_INSERT_ID() AS id_animal_criado;
END $$

DELIMITER ;
