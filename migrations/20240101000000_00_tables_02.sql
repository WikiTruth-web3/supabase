
-- ============================================
-- payments table (Payment record table)
-- Can only insert, cannot update
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  
  id TEXT NOT NULL, -- Transaction hash - log index
  box_id NUMERIC(78, 0) NOT NULL,
  user_id TEXT NOT NULL, -- UserId (bytes32 hex)
  pay_type TEXT NOT NULL CHECK (pay_type IN ('OrderAmount', 'DelayFee')),
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (box_id) REFERENCES boxes(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL, 
  amount NUMERIC(78, 0) NOT NULL, 
  timestamp NUMERIC(78, 0) NOT NULL,
  transaction_hash BYTEA NOT NULL, 
  -- block_number NUMERIC(78, 0) NOT NULL
);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;


-- ============================================
-- order_refund_withdraws table (Withdraw record table)
-- Can only insert, cannot update
-- ============================================
CREATE TABLE IF NOT EXISTS order_refund_withdraws (
  
  id TEXT NOT NULL, -- eventName-withdrawType-Transaction hash 
  token TEXT NOT NULL, 
  box_id_list NUMERIC(78, 0)[] NOT NULL, -- Box ID list
  user_id TEXT NOT NULL, -- UserId (bytes32 hex)
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  withdraw_type TEXT NOT NULL CHECK (withdraw_type IN ('Order', 'Refund')),
  amount NUMERIC(78, 0) NOT NULL,
  timestamp NUMERIC(78, 0) NOT NULL,
  transaction_hash BYTEA NOT NULL,
  -- block_number NUMERIC(78, 0) NOT NULL
);

-- ============================================
-- box_user_order_amounts table (Box user (buyer/bidder) each token amount
-- ============================================

CREATE TABLE IF NOT EXISTS box_user_order_amounts (
  
  id TEXT NOT NULL, -- user_id-box_id-token composite key
  box_id NUMERIC(78, 0) NOT NULL, -- box_id
  user_id TEXT NOT NULL, -- UserId (bytes32 hex)
  token TEXT NOT NULL, 
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (box_id) REFERENCES boxes(id) ON DELETE CASCADE,
  
  currentAmount NUMERIC(78, 0) NOT NULL DEFAULT 0,
  
  -- Unique constraint: Each user has only one record for each token in each box
  UNIQUE(user_id, box_id, token)
);

ALTER TABLE box_user_order_amounts ENABLE ROW LEVEL SECURITY;


-- ============================================
-- rewards_addeds table (Reward added event record table)
-- Can only insert, cannot update
-- ============================================
-- Event sync script will write chain events to this table, triggers will listen to this table and update aggregate tables
CREATE TABLE IF NOT EXISTS rewards_addeds (
  
  id TEXT NOT NULL, -- eventName-reward_added-Transaction hash 
  box_id NUMERIC(78, 0) NOT NULL, 
  token TEXT NOT NULL, -- Token address
  user_id TEXT NOT NULL, 
  -- reward_type TEXT NOT NULL CHECK (reward_type IN ('Minter', 'Seller', 'Completer')), 
  amount NUMERIC(78, 0) NOT NULL,
  timestamp NUMERIC(78, 0) NOT NULL,
  transaction_hash BYTEA NOT NULL,
  -- block_number NUMERIC(78, 0) NOT NULL,
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (box_id) REFERENCES boxes(id) ON DELETE CASCADE
);

ALTER TABLE rewards_addeds ENABLE ROW LEVEL SECURITY;

-- ============================================
-- box_rewards table (Box total reward amount aggregation table)
-- ============================================

CREATE TABLE IF NOT EXISTS box_rewards (
  
  id TEXT NOT NULL, -- box_id-user_id-token composite key
  box_id NUMERIC(78, 0) NOT NULL,
  user_id TEXT NOT NULL, 
  token TEXT NOT NULL, 
  PRIMARY KEY (id),
  FOREIGN KEY (box_id) REFERENCES boxes(id) ON DELETE CASCADE,
  totalAmount NUMERIC(78, 0) NOT NULL DEFAULT 0,
  UNIQUE(box_id, user_id, token)
);

ALTER TABLE box_rewards ENABLE ROW LEVEL SECURITY;

-- ============================================
-- rewards_withdraws table (User total withdrawal amount detail table)
-- Can only insert, cannot update
-- ============================================

CREATE TABLE IF NOT EXISTS rewards_withdraws (
  
  id TEXT NOT NULL, -- user_id-rewards-token composite key
  user_id TEXT NOT NULL, 
  token TEXT NOT NULL, 
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  amount NUMERIC(78, 0) NOT NULL DEFAULT 0
);

ALTER TABLE rewards_withdraws ENABLE ROW LEVEL SECURITY;

-- ============================================
-- user_rewards table (User reward amount detail table)
-- ============================================

CREATE TABLE IF NOT EXISTS user_rewards (
  
  id TEXT NOT NULL, -- user_id-user_rewards-token composite key
  user_id TEXT NOT NULL, 
  token TEXT NOT NULL, 
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  currentAmount NUMERIC(78, 0) NOT NULL DEFAULT 0,
  totalAmount NUMERIC(78, 0) NOT NULL DEFAULT 0,
  UNIQUE(user_id, token)
);

ALTER TABLE user_rewards ENABLE ROW LEVEL SECURITY;

-- ============================================
-- token_total_amounts table (Token total amount table)
-- ============================================

CREATE TABLE IF NOT EXISTS token_total_amounts (
  
  id TEXT NOT NULL, -- fundType-tokenAddress composite key
  fund_type TEXT NOT NULL CHECK (fund_type IN (
    'PaymentOrder',    
    'PaymentDelayFee',    
    'OrderWithdraw',   
    'RefundWithdraw',  
    'RewardAdded',    
    'RewardWithdraw'  
  )),
  token TEXT NOT NULL, 
  fund_manager_id TEXT NOT NULL DEFAULT 'fundManager',
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (fund_manager_id) REFERENCES fund_manager_state(id) ON DELETE CASCADE,
  
  amount NUMERIC(78, 0) NOT NULL DEFAULT 0,
  
  -- Unique constraint (contains network field)
  UNIQUE(token, fund_type)
);

ALTER TABLE token_total_amounts ENABLE ROW LEVEL SECURITY;

