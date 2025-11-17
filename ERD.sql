-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE systems (
    system_id SERIAL PRIMARY KEY,
    system_code VARCHAR(50) NOT NULL UNIQUE,
    system_name VARCHAR(200) NOT NULL,
    parent_system_id INTEGER,
    level INTEGER NOT NULL CHECK (level IN (1, 2)),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_system_id) REFERENCES systems(system_id) ON DELETE CASCADE
);

-- 索引
CREATE INDEX idx_systems_parent ON systems(parent_system_id);
CREATE INDEX idx_systems_level ON systems(level);

-- 註釋
COMMENT ON TABLE systems IS '列車系統結構表';
COMMENT ON COLUMN systems.level IS '1=主系統, 2=子系統';

