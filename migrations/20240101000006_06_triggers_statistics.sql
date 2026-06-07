
-- ============================================
-- 4. Trigger functions for statistical state
-- ============================================

-- ============================================
-- Trigger function: update box_status_statistical table (INSERT)
-- ============================================
-- Listen to: boxes table INSERT -> BoxCreated
CREATE OR REPLACE FUNCTION update_box_status_statistical_on_box_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- New box created: total_supply +1, corresponding status supply +1
    INSERT INTO box_status_statistical (
        id, total_supply,
        status_0_supply, status_1_supply, status_2_supply, status_3_supply,
        status_4_supply, status_5_supply, status_6_supply, status_7_supply
    )
    VALUES (
        'box_status_statistical', 1,
        CASE WHEN NEW.status = 0 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 1 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 2 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 3 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 4 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 5 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 6 THEN 1 ELSE 0 END,
        CASE WHEN NEW.status = 7 THEN 1 ELSE 0 END
    )
    ON CONFLICT (id)
    DO UPDATE SET
        total_supply = box_status_statistical.total_supply + 1,
        status_0_supply = box_status_statistical.status_0_supply + CASE WHEN NEW.status = 0 THEN 1 ELSE 0 END,
        status_1_supply = box_status_statistical.status_1_supply + CASE WHEN NEW.status = 1 THEN 1 ELSE 0 END,
        status_2_supply = box_status_statistical.status_2_supply + CASE WHEN NEW.status = 2 THEN 1 ELSE 0 END,
        status_3_supply = box_status_statistical.status_3_supply + CASE WHEN NEW.status = 3 THEN 1 ELSE 0 END,
        status_4_supply = box_status_statistical.status_4_supply + CASE WHEN NEW.status = 4 THEN 1 ELSE 0 END,
        status_5_supply = box_status_statistical.status_5_supply + CASE WHEN NEW.status = 5 THEN 1 ELSE 0 END,
        status_6_supply = box_status_statistical.status_6_supply + CASE WHEN NEW.status = 6 THEN 1 ELSE 0 END,
        status_7_supply = box_status_statistical.status_7_supply + CASE WHEN NEW.status = 7 THEN 1 ELSE 0 END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_box_status_statistical_on_box_insert
AFTER INSERT ON boxes
FOR EACH ROW
EXECUTE FUNCTION update_box_status_statistical_on_box_insert();


-- ============================================
-- Trigger function: update box_status_statistical table (UPDATE)
-- ============================================
-- Listen to: boxes table UPDATE status -> BoxStatusChanged
CREATE OR REPLACE FUNCTION update_box_status_statistical_on_box_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Only process status field change
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    -- Update statistical: old status -1, new status +1, total_supply unchanged
    INSERT INTO box_status_statistical (
        id,
        status_0_supply, status_1_supply, status_2_supply, status_3_supply,
        status_4_supply, status_5_supply, status_6_supply, status_7_supply
    )
    VALUES (
        'box_status_statistical',
        CASE WHEN NEW.status = 0 THEN 1 WHEN OLD.status = 0 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 1 THEN 1 WHEN OLD.status = 1 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 2 THEN 1 WHEN OLD.status = 2 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 3 THEN 1 WHEN OLD.status = 3 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 4 THEN 1 WHEN OLD.status = 4 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 5 THEN 1 WHEN OLD.status = 5 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 6 THEN 1 WHEN OLD.status = 6 THEN -1 ELSE 0 END,
        CASE WHEN NEW.status = 7 THEN 1 WHEN OLD.status = 7 THEN -1 ELSE 0 END
    )
    ON CONFLICT (id)
    DO UPDATE SET
        status_0_supply = box_status_statistical.status_0_supply + CASE WHEN NEW.status = 0 THEN 1 WHEN OLD.status = 0 THEN -1 ELSE 0 END,
        status_1_supply = box_status_statistical.status_1_supply + CASE WHEN NEW.status = 1 THEN 1 WHEN OLD.status = 1 THEN -1 ELSE 0 END,
        status_2_supply = box_status_statistical.status_2_supply + CASE WHEN NEW.status = 2 THEN 1 WHEN OLD.status = 2 THEN -1 ELSE 0 END,
        status_3_supply = box_status_statistical.status_3_supply + CASE WHEN NEW.status = 3 THEN 1 WHEN OLD.status = 3 THEN -1 ELSE 0 END,
        status_4_supply = box_status_statistical.status_4_supply + CASE WHEN NEW.status = 4 THEN 1 WHEN OLD.status = 4 THEN -1 ELSE 0 END,
        status_5_supply = box_status_statistical.status_5_supply + CASE WHEN NEW.status = 5 THEN 1 WHEN OLD.status = 5 THEN -1 ELSE 0 END,
        status_6_supply = box_status_statistical.status_6_supply + CASE WHEN NEW.status = 6 THEN 1 WHEN OLD.status = 6 THEN -1 ELSE 0 END,
        status_7_supply = box_status_statistical.status_7_supply + CASE WHEN NEW.status = 7 THEN 1 WHEN OLD.status = 7 THEN -1 ELSE 0 END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_box_status_statistical_on_box_update
AFTER UPDATE ON boxes
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION update_box_status_statistical_on_box_update();
