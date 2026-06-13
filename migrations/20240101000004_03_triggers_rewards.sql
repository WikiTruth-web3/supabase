
-- ============================================
-- 1. Trigger: update box_rewards totalAmount on rewards_added
-- ============================================
-- When a reward is added, accumulate to box_rewards.totalAmount
CREATE OR REPLACE FUNCTION update_box_rewards_on_rewards_added()
RETURNS TRIGGER AS $$
DECLARE
    v_id TEXT;
BEGIN
    v_id := NEW.box_id::TEXT || '-' || NEW.user_id || '-' || NEW.token;
    INSERT INTO box_rewards (id, box_id, user_id, token, totalAmount)
    VALUES (v_id, NEW.box_id, NEW.user_id, NEW.token, NEW.amount)
    ON CONFLICT (box_id, user_id, token)
    DO UPDATE SET
        totalAmount = box_rewards.totalAmount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_box_rewards_on_rewards_added
AFTER INSERT ON rewards_addeds
FOR EACH ROW
EXECUTE FUNCTION update_box_rewards_on_rewards_added();


-- ============================================
-- 2. Trigger: update user_rewards currentAmount/totalAmount on rewards_added
-- ============================================
-- When a reward is added, accumulate to user_rewards.currentAmount and totalAmount
CREATE OR REPLACE FUNCTION update_user_rewards_on_rewards_added()
RETURNS TRIGGER AS $$
DECLARE
    v_id TEXT;
BEGIN
    v_id := NEW.user_id || '-user_rewards-' || NEW.token;
    INSERT INTO user_rewards (id, user_id, token, currentAmount, totalAmount)
    VALUES (v_id, NEW.user_id, NEW.token, NEW.amount, NEW.amount)
    ON CONFLICT (user_id, token)
    DO UPDATE SET
        currentAmount = user_rewards.currentAmount + NEW.amount,
        totalAmount = user_rewards.totalAmount + NEW.amount;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_rewards_on_rewards_added
AFTER INSERT ON rewards_addeds
FOR EACH ROW
EXECUTE FUNCTION update_user_rewards_on_rewards_added();


-- ============================================
-- 3. Trigger: clear user_rewards.currentAmount on rewards_withdraw
-- ============================================
-- When a rewards withdrawal happens, clear the user's currentAmount
CREATE OR REPLACE FUNCTION clear_user_rewards_on_withdraw()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_rewards
    SET currentAmount = 0
    WHERE user_id = NEW.user_id AND token = NEW.token;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_clear_user_rewards_on_withdraw
AFTER INSERT ON rewards_withdraws
FOR EACH ROW
EXECUTE FUNCTION clear_user_rewards_on_withdraw();


-- ============================================
-- 4. Trigger: clear box_user_order_amounts.currentAmount when reward is added to a box
-- ============================================
-- When a reward is added, it means the box funds are allocated.
-- The buyer's current order amount should be set to 0.
CREATE OR REPLACE FUNCTION clear_box_order_amount_on_reward_added()
RETURNS TRIGGER AS $$
DECLARE
    v_buyer_id TEXT;
BEGIN
    SELECT buyer_id INTO v_buyer_id FROM boxes WHERE id = NEW.box_id;
    IF v_buyer_id IS NOT NULL THEN
        UPDATE box_user_order_amounts
        SET currentAmount = 0
        WHERE user_id = v_buyer_id
            AND box_id = NEW.box_id
            AND token = NEW.token;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_clear_box_order_amount_on_reward_added
AFTER INSERT ON rewards_addeds
FOR EACH ROW
EXECUTE FUNCTION clear_box_order_amount_on_reward_added();

