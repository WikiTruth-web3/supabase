
-- ============================================
-- 2. Trigger: update box_user_order_amounts on OrderAmount payment
-- ============================================
-- Only process payments with pay_type = 'OrderAmount'
CREATE OR REPLACE FUNCTION update_box_user_order_amounts_on_payment()
RETURNS TRIGGER AS $$
DECLARE
    v_id TEXT;
BEGIN
    IF NEW.pay_type != 'OrderAmount' THEN
        RETURN NEW;
    END IF;
    v_id := NEW.user_id || '-' || NEW.box_id::TEXT || '-' || NEW.token;
    INSERT INTO box_user_order_amounts (id, box_id, user_id, token, currentAmount)
    VALUES (v_id, NEW.box_id, NEW.user_id, NEW.token, NEW.amount)
    ON CONFLICT (user_id, box_id, token)
    DO UPDATE SET
        currentAmount = box_user_order_amounts.currentAmount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_box_user_order_amounts_on_payment
AFTER INSERT ON payments
FOR EACH ROW
WHEN (NEW.pay_type = 'OrderAmount')
EXECUTE FUNCTION update_box_user_order_amounts_on_payment();


-- ============================================
-- 3. Trigger: clear box_user_order_amounts on order/refund withdraw
-- ============================================
-- When an order or refund withdrawal happens, clear currentAmount for each box
CREATE OR REPLACE FUNCTION clear_box_user_order_amounts_on_withdraw()
RETURNS TRIGGER AS $$
DECLARE
    v_box_id NUMERIC(78, 0);
BEGIN
    IF NEW.box_id_list IS NULL OR array_length(NEW.box_id_list, 1) = 0 THEN
        RETURN NEW;
    END IF;
    FOREACH v_box_id IN ARRAY NEW.box_id_list
    LOOP
        UPDATE box_user_order_amounts
        SET currentAmount = 0
        WHERE user_id = NEW.user_id
            AND box_id = v_box_id
            AND token = NEW.token;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_clear_box_user_order_amounts_on_withdraw
AFTER INSERT ON order_refund_withdraws
FOR EACH ROW
EXECUTE FUNCTION clear_box_user_order_amounts_on_withdraw();
