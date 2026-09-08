/**
 * ENTERPRISE CUSTOMER BRAIN - MONGODB CONFIGURATION SCRIPT
 * Stack: MongoDB 6.0+ / Enterprise Catalog Ingestion
 * 
 * Istruzioni per il deploy locale via MongoDB Compass o mongosh:
 * 1. Connettersi all'istanza locale Docker Desktop.
 * 2. Aprire la MongoDB Shell (mongosh).
 * 3. Eseguire i seguenti comandi per inizializzare l'ambiente.
 */

// 1. Inizializzazione e switch sul database aziendale dedicato
use enterprise_brain;

// 2. Creazione esplicita della collezione per i lead commerciali flessibili
db.createCollection("commercial_leads");

// 3. Nota Architetturale (Polyglot Persistence):
// Essendo MongoDB un database NoSQL Documentale, lo schema è polimorfo e dinamico.
// Il sotto-workflow "03 - SUB - NoSQL Document Store" di n8n eseguirà l'upsert 
// iniettando i documenti con la seguente struttura JSON standardizzata:
/*
{
  "_id": ObjectId("..."),
  "lead_id": "LEAD-MV-1102",
  "contact_email": "acquisti.imola@motorvalley-hub.it",
  "ingestion_source": "SEMANIC_ROUTER_V3",
  "raw_request": "Siamo interessati ad ampliare la nostra isola robotizzata...",
  "sanitized_request": "Siamo interessati ad ampliare la nostra isola robotizzata...",
  "system_metrics": {
    "text_length": 150,
    "processed_at": "2026-09-07T15:32:20.392Z"
  }
}
*/

print("Database 'enterprise_brain' e collezione 'commercial_leads' inizializzati con successo.");
