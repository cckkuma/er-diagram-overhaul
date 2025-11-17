-- 1. 車輛表
CREATE TABLE vehicles (
    vehicle_id INTEGER NOT NULL PRIMARY KEY,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL COMMENT '車輛編號: 001A, 001B, MRV001',
    vehicle_type ENUM('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '車輛類型',
    train_set VARCHAR(10) COMMENT '列車組號: 001, 002...',
    power_type ENUM('750DC', 'DIESEL') NOT NULL COMMENT '供能方式',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ;

-- 2. 系統表 (支援多層級結構)
CREATE TABLE systems (
    system_id INTEGER NOT NULL PRIMARY KEY,
    system_code VARCHAR(50) UNIQUE NOT NULL COMMENT '系統編碼',
    system_name VARCHAR(100) NOT NULL COMMENT '系統名稱: Brake system, piping, hang valve...',
    parent_system_id INT NULL COMMENT '父系統ID (NULL=頂層系統)',
    level_type ENUM('SYSTEM', 'SUBSYSTEM', 'COMPONENT') NOT NULL COMMENT '層級',
    applicable_to SET('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '適用車型',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_system_id) REFERENCES systems(system_id)
) ;

-- 3. 零件表
CREATE TABLE parts (
    part_id INTEGER NOT NULL PRIMARY KEY,
    drawing_number VARCHAR(100) UNIQUE NOT NULL COMMENT '圖號/型號',
    part_name VARCHAR(200) NOT NULL COMMENT '零件名稱: O-ring (P9, NBR)',
    unit_price DECIMAL(10, 2) COMMENT '單價',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ;

-- 4. 系統零件關聯表 (記錄每個零件在哪個系統使用及用量)
CREATE TABLE system_parts (
    id INTEGER NOT NULL PRIMARY KEY,
    system_id INT NOT NULL COMMENT '系統ID',
    part_id INT NOT NULL COMMENT '零件ID',
    quantity_per_vehicle INT NOT NULL COMMENT '每輛車用量',
    applicable_to SET('SUT_A', 'SUT_B', 'MRV') NOT NULL COMMENT '適用車型',
    manual_reference VARCHAR(100) COMMENT 'Manual參考',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (system_id) REFERENCES systems(system_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ;

-- 5. 庫存表 (現有庫存 + 新採購)
CREATE TABLE stock_inventory (
    inventory_id INTEGER NOT NULL PRIMARY KEY,
    part_id INT NOT NULL COMMENT '零件ID',
    stock_code VARCHAR(50) COMMENT '倉庫編號 (舊有庫存才有)',
    quantity INT NOT NULL DEFAULT 0 COMMENT '數量',
    source_type ENUM('現有庫存', '新採購') NOT NULL COMMENT '來源',
    supplier VARCHAR(100) COMMENT '供應商 (新採購才有)',
    purchase_date DATE COMMENT '採購日期',
    remarks TEXT COMMENT '備註: 可記錄多個stock code問題',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ;

-- ============================================
-- 創建索引
-- ============================================
CREATE INDEX idx_vehicle_type ON vehicles(vehicle_type);
CREATE INDEX idx_parent_system ON systems(parent_system_id);
CREATE INDEX idx_system_parts_system ON system_parts(system_id);
CREATE INDEX idx_system_parts_part ON system_parts(part_id);
CREATE INDEX idx_inventory_part ON stock_inventory(part_id);
CREATE INDEX idx_inventory_source ON stock_inventory(source_type);
