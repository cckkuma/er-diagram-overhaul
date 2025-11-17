-- ============================================
-- 1. Systems（系統表）
-- ============================================
-- 修正後 (移除了 system_name 後面的多餘逗號)
CREATE TABLE systems (
    system_id SERIAL PRIMARY KEY,
    system_code VARCHAR(50) NOT NULL UNIQUE,
    system_name VARCHAR(200) NOT NULL
);

-- 註釋
COMMENT ON TABLE systems IS '列車系統表';
