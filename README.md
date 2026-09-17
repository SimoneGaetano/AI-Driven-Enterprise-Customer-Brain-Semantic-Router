# AI-Driven Enterprise Customer Brain & Semantic Router
Una pipeline industriale di backend puro per l'ingestione, la classificazione semantica e l'orchestrazione asincrona multi-database sviluppata a budget zero in ambiente locale. Il sistema è progettato per intercettare flussi costanti di comunicazioni aziendali non strutturate (ticket tecnici complessi, reclami legali, lead commerciali), analizzarne l'intento tramite modelli LLM deterministici (Semantic Routing) e smistare il carico computazionale su tre sotto-pipeline disaccoppiate e indipendenti, restituendo un report manageriale sincrono.

## 🛠️ Stack Tecnologico & Architettura
*   **Orchestratore/Backend:** n8n (Esecuzione self-hosted in locale v1+)
*   **Database Relazionale:** PostgreSQL 15 (Data persistence per vincoli ACID e audit log legali)
*   **Database NoSQL:** MongoDB 6 (Persistenza documentale polimorfa per schemi commerciali flessibili)
*   **Database Vettoriale:** Simple Vector Store (Motore RAG locale In-Memory per recupero contestuale)
*   **Engine IA & Embeddings:** Groq Cloud API (Modello llama-3.3-7b-versatile) & OpenAI Embeddings
*   **Ambiente d'Infrastruttura:** Docker Desktop (Isolamento dei servizi e Docker Network dedicata `n8n-network`)
*   **Database Client:** Beekeeper Studio & MongoDB Compass (Data inspection e amministrazione schemi)
*   **API Testing Client:** Postman (Simulazione client esterno e convalida delle risposte sincrone)

## 🔄 Flusso Logico dei Dati
Il workflow gestisce un'architettura Hub-and-Spoke disaccoppiata tramite sotto-workflow indipendenti per ottimizzare la context window e abbattere i costi delle API:

*   **Pipeline di Ingestione e Routing (Workflow Padre):** Production Webhook Trigger (Endpoint sincrono `v1/customer-brain-ingest` per mantenere attiva la connessione con il client) ➔ Code Node (Isolamento dei metadati e pre-sanitizzazione del testo) ➔ Groq API (Basic LLM Chain impostata a Temperature = 0 per una classificazione deterministica ad alta velocità) ➔ Switch Node (Intercettazione del codice categorico rigido `1`, `2` o `3` e deviazione immediata dell'impulso grafico).
*   **Sub-Workflow A (Advanced AI RAG Engine):** Execute Workflow Trigger ➔ Tools Agent (Configurato senza memoria di chat per isolare il ticket) ➔ Simple Vector Store & OpenAI Embeddings (Interrogazione semantica sui manuali tecnici condivisi tramite Docker Volume) ➔ Code Node (Formattazione del report di fallback in caso di contesto non trovato).
*   **Sub-Workflow B (Relational Database Audit):** Execute Workflow Trigger ➔ Edit Fields (Data Adapter per l'estrazione sicura e la tipizzazione delle variabili) ➔ PostgreSQL (Esecuzione di una query SQL nativa `INSERT INTO` all'interno della tabella `customer_audit_logs`).
*   **Sub-Workflow C (NoSQL Document Store):** Execute Workflow Trigger ➔ Edit Fields (Normalizzazione dei campi commerciali) ➔ MongoDB (Inserimento fluido del documento JSON integro all'interno della collezione `commercial_leads`).
*   **Pipeline di Consolidamento e Risposta (Finale):** Merge Node (Configurato in modalità `Append` con sblocco rapido su `Wait for Any Input` per evitare lo stallo dei rami spenti) ➔ Edit Fields (Tracciamento della linea temporale tramite puntatori storici espliciti per recuperare i metadati originari del Padre ed eliminare il payload spazzatura accumulato) ➔ Respond to Webhook (Rilascio immediato del report manageriale finale compilato in risposta sincrona verso Postman).

## 🧪 Interfaccia di Test & Integrazione API (Postman)
L'infrastruttura è configurata per comportarsi come un vero microservizio BaaS (Backend as a Service). Per convalidare il routing semantico e la persistenza polimorfa, le chiamate vengono simulate tramite client Postman con i seguenti endpoint e payload strutturati:

*   **Configurazione Richiesta Globale:**
    *   **Metodo:** `POST`
    *   **URL Produzione Locale:** `http://localhost:5678/webhook/v1/customer-brain-ingest`
    *   **Headers:** `Content-Type: application/json`

*   **Payload di Test 1 (Ramo Assistenza Tecnica ➔ RAG Engine):**
    ```json
    {
      "customer_id": "MV-9942",
      "email": "logistica.modena@motorvalley-hub.it",
      "text": "Buongiorno, l'impianto di automazione industriale ha riscontrato un blocco sul braccio meccanico custom dell'isola 3. L'albero di trasmissione ha un attrito anomalo. Abbiamo urgenza, verificate i manuali della macchina."
    }
    ```
*   **Payload di Test 2 (Ramo Reclamo Legale ➔ PostgreSQL ACID Logs):**
    ```json
    {
      "customer_id": "MV-4412",
      "email": "direzione.bologna@motorvalley-hub.it",
      "text": "Con la presente comunichiamo che, a causa del mancato rispetto dello SLA di consegna del software di automazione, i nostri legali procederanno a richiedere la penale contrattuale. Valuteremo vie legali se non riceviamo risposta entro 48 ore."
    }
    ```
*   **Payload di Test 3 (Ramo Commerciale ➔ MongoDB NoSQL Store):**
    ```json
    {
      "customer_id": "MV-1102",
      "email": "acquisti.imola@motorvalley-hub.it",
      "text": "Siamo interessati ad ampliare la nostra isola robotizzata con 2 nuovi bracci meccanici. Potete inviarci un preventivo commerciale per le licenze software aggiuntive e i costi di installazione?"
    }
    ```

## 🔒 Considerazioni sulla Sicurezza & Cybersecurity
Il perimetro infrastrutturale è isolato localmente all'interno della rete Docker, esponendo verso l'esterno solo l'endpoint del Webhook Padre che agisce da API Gateway centralizzato. A livello di sicurezza del dato, l'architettura implementa il pattern del *Data Adapter* intermedio (`Edit Fields`) prima delle persistente relazionali e NoSQL, fungendo da fail-safe strutturale: il sistema convalida e normalizza i tipi di dato, impedendo l'inserimento di valori `null` o `undefined` che provocherebbero il rollback forzato delle transazioni su PostgreSQL. Inoltre, il codice JavaScript centrale applica l'escaping preventivo degli apostrofi, neutralizzando anomalie sintattiche causate da stringhe non strutturate fornite dagli utenti.

## 📈 Scalabilità & Analisi dei Costi (Local vs Cloud TCO)
Progetto originariamente ingegnerizzato in locale per ottimizzazione delle risorse hardware e gestione dei database a budget zero.

*   **Analisi dei costi Cloud (VPS):** Per una messa in produzione aziendale capace di reggere flussi costanti, l'intera suite Docker (n8n + Postgres + Mongo) prevede la migrazione su una VPS Linux Dedicata (es. Aruba Cloud / Hetzner) a un costo stimato di ~12.00€/mese, abbattendo i costi computazionali dell'infrastruttura IA grazie alle API ad alte prestazioni di Groq.
*   **Scalabilità Orizzontale:** Il design pattern basato su sotto-workflow indipendenti (Sub-Workflows) consente una scalabilità orizzontale nativa. In produzione, ogni singolo modulo di persistenza può essere spostato su istanze n8n separate o distribuito su nodi Worker dedicati (Queue Mode gestita via Redis) senza dover alterare o modificare la logica di routing del workflow centrale.

## 👨‍💻 Note di Sviluppo
Ho sviluppato questo terzo progetto per dimostrare una forte skill in ambito di architettura software di livello enterprise B2B: la transizione da automazioni monolitiche a sistemi disaccoppiati a microservizi orchestrati. Durante lo sviluppo locale su Docker ho dovuto combattere con un severo problema di stallo hardware (timeout permanenti) sul nodo Merge finale: n8n rimaneva appeso in modalità *Wait for All Inputs* perché lo Switch a monte attivava un solo ramo asincrono alla volta. Ho risolto il problema riconfigurando il Merge in modalità `Append` con sblocco sul primo dato utile in arrivo. Inoltre, ho affrontato e risolto un bug di data leakage (campi del report compilati come `N/A`) causato dallo scope locale della variabile `$json` in n8n v1+, che oscurava i metadati del Padre dopo l'esecuzione dei sotto-workflow; ho superato il blocco bypassando la memoria relativa dell'ultimo nodo e forzando l'orchestratore a eseguire un tracciamento storico esplicito dei nodi di origine per fondere metadati e risposte dei database in un unico report manageriale sincrono.
