-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE systems( 
    system_id    SERIAL PRIMARY KEY,
    system_code    VARCHAR(50) NOT NULL UNIQUE,
    system_name    VARCHAR(200) NOT NULL
);
