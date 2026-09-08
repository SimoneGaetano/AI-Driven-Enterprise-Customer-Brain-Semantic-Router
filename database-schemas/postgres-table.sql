-- ============================================================
-- ENTERPRISE CUSTOMER BRAIN - POSTGRESQL AUDIT SCHEMA
-- Stack: PostgreSQL 15+ / Relational Audit Store
-- Target: Storicizzazione transazionale dei Reclami Legali
-- ============================================================

CREATE TABLE IF NOT EXISTS customer_audit_logs (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    issue_type VARCHAR(50) NOT NULL,
    log_context TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Indice di ottimizzazione per le interrogazioni sui clienti (Opzionale, consigliato per colloqui B2B)
CREATE INDEX IF NOT EXISTS idx_customer_audit_logs_customer_id 
ON customer_audit_logs(customer_id);
