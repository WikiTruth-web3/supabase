
-- ============================================
-- 3. Trigger functions for token total amounts
-- ============================================

-- ============================================
-- Trigger: update token_total_amounts on payment
-- ============================================
-- payments: pay_type = 'OrderAmount' -> 'PaymentOrder', pay_type = 'DelayFee' -> 'PaymentDelayFee'
CREATE OR REPLACE FUNCTION update_token_total_amounts_on_payment()
RETURNS TRIGGER AS $$
DECLARE
    v_fund_type TEXT;
    v_id TEXT;
BEGIN
    v_fund_type := CASE NEW.pay_type
        WHEN 'OrderAmount' THEN 'PaymentOrder'
        WHEN 'DelayFee' THEN 'PaymentDelayFee'
        ELSE NULL
    END;
    IF v_fund_type IS NULL THEN
        RETURN NEW;
    END IF;
    v_id := v_fund_type || '-' || NEW.token;
    INSERT INTO token_total_amounts (id, fund_type, token, fund_manager_id, amount)
    VALUES (v_id, v_fund_type, NEW.token, 'fundManager', NEW.amount)
    ON CONFLICT (token, fund_type)
    DO UPDATE SET
        amount = token_total_amounts.amount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_token_total_amounts_on_payment
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION update_token_total_amounts_on_payment();


-- ============================================
-- Trigger: update token_total_amounts on order/refund withdraw
-- ============================================
-- order_refund_withdraws: withdraw_type = 'Order' -> 'OrderWithdraw', 'Refund' -> 'RefundWithdraw'
CREATE OR REPLACE FUNCTION update_token_total_amounts_on_withdraw()
RETURNS TRIGGER AS $$
DECLARE
    v_fund_type TEXT;
    v_id TEXT;
BEGIN
    v_fund_type := CASE NEW.withdraw_type
        WHEN 'Order' THEN 'OrderWithdraw'
        WHEN 'Refund' THEN 'RefundWithdraw'
        ELSE NULL
    END;
    IF v_fund_type IS NULL THEN
        RETURN NEW;
    END IF;
    v_id := v_fund_type || '-' || NEW.token;
    INSERT INTO token_total_amounts (id, fund_type, token, fund_manager_id, amount)
    VALUES (v_id, v_fund_type, NEW.token, 'fundManager', NEW.amount)
    ON CONFLICT (token, fund_type)
    DO UPDATE SET
        amount = token_total_amounts.amount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_token_total_amounts_on_withdraw
AFTER INSERT ON order_refund_withdraws
FOR EACH ROW
EXECUTE FUNCTION update_token_total_amounts_on_withdraw();


-- ============================================
-- Trigger: update token_total_amounts on rewards_added
-- ============================================
-- rewards_addeds -> 'RewardAdded'
CREATE OR REPLACE FUNCTION update_token_total_amounts_on_rewards_added()
RETURNS TRIGGER AS $$
DECLARE
    v_fund_type TEXT := 'RewardAdded';
    v_id TEXT;
BEGIN
    v_id := v_fund_type || '-' || NEW.token;
    INSERT INTO token_total_amounts (id, fund_type, token, fund_manager_id, amount)
    VALUES (v_id, v_fund_type, NEW.token, 'fundManager', NEW.amount)
    ON CONFLICT (token, fund_type)
    DO UPDATE SET
        amount = token_total_amounts.amount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_token_total_amounts_on_rewards_added
AFTER INSERT ON rewards_addeds
FOR EACH ROW
EXECUTE FUNCTION update_token_total_amounts_on_rewards_added();


-- ============================================
-- Trigger: update token_total_amounts on rewards_withdraw
-- ============================================
-- rewards_withdraws -> 'RewardWithdraw'
CREATE OR REPLACE FUNCTION update_token_total_amounts_on_rewards_withdraw()
RETURNS TRIGGER AS $$
DECLARE
    v_fund_type TEXT := 'RewardWithdraw';
    v_id TEXT;
BEGIN
    v_id := v_fund_type || '-' || NEW.token;
    INSERT INTO token_total_amounts (id, fund_type, token, fund_manager_id, amount)
    VALUES (v_id, v_fund_type, NEW.token, 'fundManager', NEW.amount)
    ON CONFLICT (token, fund_type)
    DO UPDATE SET
        amount = token_total_amounts.amount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_token_total_amounts_on_rewards_withdraw
AFTER INSERT ON rewards_withdraws
FOR EACH ROW
EXECUTE FUNCTION update_token_total_amounts_on_rewards_withdraw();
