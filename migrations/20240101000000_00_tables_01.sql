-- ============================================
-- users table (User table - UserId)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  
  id TEXT NOT NULL, -- UserId (bytes32 hex)
  
  PRIMARY KEY (id) -- Composite primary key contains network field
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- user_addresses table (User address table - User2)
-- ============================================
CREATE TABLE IF NOT EXISTS user_addresses (
  
  id TEXT NOT NULL, -- userAddress (address)
  
  PRIMARY KEY (id), 
  is_blacklisted BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;


-- ============================================
-- boxes 表 (Box main table)
-- ============================================
-- Box table stores chain event data, MetadataBox data is stored as an independent associated table
CREATE TABLE IF NOT EXISTS boxes (
  
  -- Basic identifier
  id NUMERIC(78, 0) NOT NULL, -- boxId 
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  token_id NUMERIC(78, 0) NOT NULL, -- NFT tokenId, same as boxId
  
  -- Chain event data fields
  box_info_cid TEXT, -- CID (for associating MetadataBox) in BoxCreated event
  private_key TEXT, 
  price NUMERIC(78, 0) NOT NULL DEFAULT 0, 
  deadline NUMERIC(78, 0) NOT NULL DEFAULT 0, 
  
  -- User relationships
  minter_id TEXT NOT NULL, -- UserId (bytes32 hex)
  publisher_id TEXT, -- UserId (bytes32 hex)
  seller_id TEXT, -- UserId (bytes32 hex)
  buyer_id TEXT, -- UserId (bytes32 hex)
  completer_id TEXT, -- UserId (bytes32 hex)
  
  -- Status and timestamps
  -- Status values: 0=Storing, 1=Selling, 2=Auctioning, 3=Paid, 4=Delaying, 5=Refunding, 6=Published, 7=Blacklisted
  status SMALLINT NOT NULL CHECK (status BETWEEN 0 AND 7),
  
  -- Transaction related
  -- listed_mode values: NULL=Not Listed, 1=Selling, 2=Auctioning
  listed_mode SMALLINT CHECK (listed_mode BETWEEN 1 AND 2), 
  accepted_token TEXT, 
  refund_permit BOOLEAN, 
  
  -- Timestamp fields
  create_timestamp NUMERIC(78, 0) NOT NULL, 
  publish_timestamp NUMERIC(78, 0), 
  listed_timestamp NUMERIC(78, 0), 
  purchase_timestamp NUMERIC(78, 0), 
  complete_timestamp NUMERIC(78, 0), 
  request_refund_deadline NUMERIC(78, 0), 
  arbitration_deadline NUMERIC(78, 0) 
);

ALTER TABLE boxes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- box_bidders table (Box bidder association table)
-- ============================================
CREATE TABLE IF NOT EXISTS box_bidders (
  
  
  id TEXT NOT NULL, -- boxId-UserId 
  box_id NUMERIC(78, 0) NOT NULL, -- boxId
  bidder_id TEXT NOT NULL, -- UserId (bytes32 hex)
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  FOREIGN KEY (box_id) REFERENCES boxes(id) ON DELETE CASCADE,
  FOREIGN KEY (bidder_id) REFERENCES users(id) ON DELETE CASCADE
);

ALTER TABLE box_bidders ENABLE ROW LEVEL SECURITY;

-- ============================================
-- metadata_boxes table (MetadataBox association table)
-- Can only insert, cannot update
-- ============================================
-- Store MetadataBox JSON data retrieved from IPFS, associated with boxes table via id (boxId)
CREATE TABLE IF NOT EXISTS metadata_boxes (
  
  id NUMERIC(78, 0) NOT NULL, -- boxId
  
  PRIMARY KEY (id), 
  FOREIGN KEY (id) REFERENCES boxes(id) ON DELETE CASCADE,
  
  -- BoxInfo fields
  type_of_crime TEXT, 
  label TEXT[], 
  title TEXT, 
  nft_image TEXT, 
  box_image TEXT, 
  nft_image_r2 TEXT,  -- cloudflare r2
  box_image_r2 TEXT,  -- cloudflare r2
  country TEXT, 
  state TEXT, 
  description TEXT, 
  event_date DATE, 
  create_date TIMESTAMP WITH TIME ZONE, 
  timestamp BIGINT, 
  mint_method TEXT CHECK (mint_method IN ('create', 'createAndPublish')),
  
  file_list TEXT[], 
  password TEXT, 
  
  encryption_slices_metadata_cid JSONB, -- { encryption_data, encryption_iv }
  encryption_file_cid JSONB[], -- [{ encryption_data, encryption_iv }, ...]
  encryption_passwords JSONB, -- { encryption_data, encryption_iv }
  public_key TEXT
);

ALTER TABLE metadata_boxes ENABLE ROW LEVEL SECURITY;


-- ============================================
-- box_status_statistical table (Statistical state table - singleton)
-- Listen to boxes table, when status changes, accumulate and subtract
-- ⚠️ Do not allow manual insertion/update, completely managed by triggers
-- ============================================
CREATE TABLE IF NOT EXISTS box_status_statistical (
  
  id TEXT NOT NULL DEFAULT 'box_status_statistical', -- Singleton ID
  
  PRIMARY KEY (id), -- Composite primary key contains network field
  total_supply NUMERIC(78, 0) NOT NULL DEFAULT 0,
  status_0_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Storing
  status_1_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Selling
  status_2_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Auctioning
  status_3_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Paid
  status_4_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Delaying 
  status_5_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Refunding
  status_6_supply NUMERIC(78, 0) NOT NULL DEFAULT 0, -- Published
  status_7_supply NUMERIC(78, 0) NOT NULL DEFAULT 0  -- Blacklisted
);

ALTER TABLE box_status_statistical ENABLE ROW LEVEL SECURITY;

-- Initialize box_status_statistical
INSERT INTO box_status_statistical (id)
VALUES 
  ('box_status_statistical')
ON CONFLICT DO NOTHING;

-- ============================================
-- fund_manager_state table (Fund manager state table - singleton)
-- ============================================
-- Note: It needs to be created before token_total_amounts, because of foreign key dependency
-- It has no practical function, but can be kept for future expansion
CREATE TABLE IF NOT EXISTS fund_manager_state (
  
  
  id TEXT NOT NULL DEFAULT 'fundManager', -- Singleton ID
  paused BOOLEAN NOT NULL DEFAULT FALSE,
  
  PRIMARY KEY (id) -- Composite primary key contains network field
);

ALTER TABLE fund_manager_state ENABLE ROW LEVEL SECURITY;

-- Initialize fund_manager_state
INSERT INTO fund_manager_state (id)
VALUES 
  ('fundManager')
ON CONFLICT DO NOTHING;


-- ============================================
-- forwarder_state table (Forwarder status table - singleton)
-- ============================================
CREATE TABLE IF NOT EXISTS forwarder_state (
  
  id TEXT NOT NULL DEFAULT 'forwarder', -- Singleton ID
  paused BOOLEAN NOT NULL DEFAULT FALSE,
  
  PRIMARY KEY (id) -- Composite primary key contains network field
);

ALTER TABLE forwarder_state ENABLE ROW LEVEL SECURITY;

-- Initialize forwarder_state
INSERT INTO forwarder_state (id)
VALUES 
  ('forwarder')
ON CONFLICT DO NOTHING;

-- ============================================
-- sync_status table (Sync status table - for event sync script)
-- ============================================
-- Each contract has independent sync status
CREATE TABLE IF NOT EXISTS sync_status (
  
  contract_name TEXT NOT NULL CHECK (contract_name IN ('BLIND_BOX', 'EXCHANGE', 'FUND_MANAGER', 'BOX_NFT', 'USER_MANAGER', 'FORWARDER')),
  last_synced_block NUMERIC(78, 0) NOT NULL DEFAULT 0,
  last_synced_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  PRIMARY KEY (contract_name) -- Composite primary key contains network field and contract name
);

ALTER TABLE sync_status ENABLE ROW LEVEL SECURITY;

-- Initialize sync_status records (create initial records for each network and each contract)
INSERT INTO sync_status (contract_name, last_synced_block, last_synced_at)
VALUES 
  ('BLIND_BOX', 0, NOW()),
  ('EXCHANGE', 0, NOW()),
  ('FUND_MANAGER', 0, NOW()),
  ('BOX_NFT', 0, NOW()),
  ('USER_MANAGER', 0, NOW()),
  ('FORWARDER', 0, NOW())
ON CONFLICT (contract_name) DO NOTHING;

