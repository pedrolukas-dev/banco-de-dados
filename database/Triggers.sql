USE petvida;

CREATE TABLE IF NOT EXISTS log_auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    acao VARCHAR(20) NOT NULL,
    registro_id INT NOT NULL,
    detalhes TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

-- a) trg_after_insert_consulta
CREATE TRIGGER trg_after_insert_consulta
AFTER INSERT ON consultas
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES ('consultas', 'INSERT', NEW.id, CONCAT('Nova consulta agendada para o animal ID: ', NEW.animal_id, ' com o valor de R$ ', NEW.valor));
END $$

-- b) trg_after_update_consulta_status
CREATE TRIGGER trg_after_update_consulta_status
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
        VALUES ('consultas', 'UPDATE_STATUS', NEW.id, CONCAT('Status alterado de "', OLD.status, '" para "', NEW.status, '"'));
    END IF;
END $$

-- c) trg_before_delete_consulta
CREATE TRIGGER trg_before_delete_consulta
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN
    DECLARE v_status_pagamento VARCHAR(20);
    
    SELECT status INTO v_status_pagamento FROM pagamentos WHERE consulta_id = OLD.id;
    
    IF v_status_pagamento = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro de Segurança: Não é possível excluir uma consulta que já foi paga.';
    END IF;
END $$

-- d) trg_after_insert_animal
CREATE TRIGGER trg_after_insert_animal
AFTER INSERT ON animais
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES ('animais', 'INSERT', NEW.id, CONCAT('Novo animal cadastrado: ', NEW.nome, ' (Raça: ', NEW.raca, ')'));
END $$

-- e) trg_before_update_pagamento
CREATE TRIGGER trg_before_update_pagamento
BEFORE UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    IF NEW.status = 'pago' AND OLD.status <> 'pago' THEN
        SET NEW.data_pagamento = NOW();
    END IF;
END $$

DELIMITER ;