-- ============================================
-- 1. Systems（系統表）
-- ============================================
CREATE TABLE department
    ( dept_id    INTEGER NOT NULL PRIMARY KEY
    , dept_name  VARCHAR(50) NOT NULL
    ) ;
CREATE TABLE train_systems(dept_id INTEGER NOT NULL PRIMARY KEY, dept_name INTEGER NOT NULL) ;
