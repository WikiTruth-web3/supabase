
-- ============================================
-- boxes indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_boxes_token_id ON boxes(token_id);
CREATE INDEX IF NOT EXISTS idx_boxes_status ON boxes(status);
CREATE INDEX IF NOT EXISTS idx_boxes_minter_id ON boxes(minter_id);
-- CREATE INDEX IF NOT EXISTS idx_boxes_owner_address ON boxes(owner_address);
CREATE INDEX IF NOT EXISTS idx_boxes_publisher_id ON boxes(publisher_id);
CREATE INDEX IF NOT EXISTS idx_boxes_seller_id ON boxes(seller_id);
CREATE INDEX IF NOT EXISTS idx_boxes_buyer_id ON boxes(buyer_id);
CREATE INDEX IF NOT EXISTS idx_boxes_completer_id ON boxes(completer_id);
CREATE INDEX IF NOT EXISTS idx_boxes_create_timestamp ON boxes(create_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_boxes_price ON boxes(price);
CREATE INDEX IF NOT EXISTS idx_boxes_box_info_cid ON boxes(box_info_cid);
CREATE INDEX IF NOT EXISTS idx_boxes_listed_mode ON boxes(listed_mode);

-- boxes composite indexes
CREATE INDEX IF NOT EXISTS idx_boxes_status_price ON boxes(status, price);
CREATE INDEX IF NOT EXISTS idx_boxes_status_create_timestamp ON boxes(status, create_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_boxes_status_listed_mode ON boxes(status, listed_mode);

-- ============================================
-- metadata_boxes indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_type_of_crime ON metadata_boxes(type_of_crime);
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_country ON metadata_boxes(country);
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_state ON metadata_boxes(state);
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_event_date ON metadata_boxes(event_date);
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_mint_method ON metadata_boxes(mint_method);

-- metadata_boxes full text search indexes (GIN indexes)
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_title_gin ON metadata_boxes USING gin(to_tsvector('english', COALESCE(title, '')));
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_description_gin ON metadata_boxes USING gin(to_tsvector('english', COALESCE(description, '')));
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_label_gin ON metadata_boxes USING gin(label);

-- metadata_boxes composite indexes
CREATE INDEX IF NOT EXISTS idx_metadata_boxes_type_country ON metadata_boxes(type_of_crime, country);

-- ============================================
-- users indexes
-- ============================================

-- ============================================
-- user_addresses indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_addresses_is_blacklisted ON user_addresses(is_blacklisted);

-- ============================================
-- payments indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_payments_box_id ON payments(box_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_token ON payments(token);
CREATE INDEX IF NOT EXISTS idx_payments_timestamp ON payments(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_payments_pay_type ON payments(pay_type);

-- ============================================
-- order_refund_withdraws indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_order_refund_withdraws_user_id ON order_refund_withdraws(user_id);
CREATE INDEX IF NOT EXISTS idx_order_refund_withdraws_token ON order_refund_withdraws(token);
CREATE INDEX IF NOT EXISTS idx_order_refund_withdraws_timestamp ON order_refund_withdraws(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_order_refund_withdraws_withdraw_type ON order_refund_withdraws(withdraw_type);

-- ============================================
-- rewards_addeds indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_rewards_addeds_box_id ON rewards_addeds(box_id);
CREATE INDEX IF NOT EXISTS idx_rewards_addeds_user_id ON rewards_addeds(user_id);
CREATE INDEX IF NOT EXISTS idx_rewards_addeds_token ON rewards_addeds(token);
CREATE INDEX IF NOT EXISTS idx_rewards_addeds_timestamp ON rewards_addeds(timestamp DESC);

-- ============================================
-- box_rewards indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_box_rewards_box_id ON box_rewards(box_id);
CREATE INDEX IF NOT EXISTS idx_box_rewards_user_id ON box_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_box_rewards_box_user ON box_rewards(box_id, user_id);
CREATE INDEX IF NOT EXISTS idx_box_rewards_token ON box_rewards(token);

-- ============================================
-- user_rewards indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_rewards_user_id ON user_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_user_rewards_token ON user_rewards(token);

-- ============================================
-- rewards_withdraws indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_rewards_withdraws_user_id ON rewards_withdraws(user_id);
CREATE INDEX IF NOT EXISTS idx_rewards_withdraws_token ON rewards_withdraws(token);

-- ============================================
-- box_bidders indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_box_bidders_id ON box_bidders(id); -- id is boxId-UserId
CREATE INDEX IF NOT EXISTS idx_box_bidders_box_id ON box_bidders(box_id);
CREATE INDEX IF NOT EXISTS idx_box_bidders_bidder_id ON box_bidders(bidder_id);

-- ============================================
-- box_user_order_amounts indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_box_user_order_amounts_user_id ON box_user_order_amounts(user_id);
CREATE INDEX IF NOT EXISTS idx_box_user_order_amounts_box_id ON box_user_order_amounts(box_id);
CREATE INDEX IF NOT EXISTS idx_box_user_order_amounts_token ON box_user_order_amounts(token);
CREATE INDEX IF NOT EXISTS idx_box_user_order_amounts_user_box ON box_user_order_amounts(user_id, box_id);
CREATE INDEX IF NOT EXISTS idx_box_user_order_amounts_user_box_token ON box_user_order_amounts(user_id, box_id, token);

-- ============================================
-- token_total_amounts indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_token_total_amounts_token ON token_total_amounts(token);
CREATE INDEX IF NOT EXISTS idx_token_total_amounts_fund_type ON token_total_amounts(fund_type);
CREATE INDEX IF NOT EXISTS idx_token_total_amounts_fund_manager_id ON token_total_amounts(fund_manager_id);

