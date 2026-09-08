###AI-Driven Enterprise Customer Brain & Semantic Router

An asynchronous, decoupled micro-services backend architecture developed in a local environment.

The system acts as an AI Gateway capable of ingesting high-volume unstructured communications (technical tickets, legal claims, commercial leads), analyzing user intent via deterministic Semantic Routing, and orchestrating downstream execution across multiple relational, NoSQL document, and vector semantic databases.

🛠️ Stack Tecnologico & Architettura

Orchestratore/Backend: n8n (Esecuzione self-hosted v1+, configurato per risposte sincrone).

Database Relazionale: PostgreSQL 15 (Data persistence e vincoli ACID per audit log legali).

Database NoSQL: MongoDB 6 (Persistenza documentale polimorfa per lead commerciali flessibili).

Database Vettoriale Semantico: Simple Vector Store In-Memory (Motore RAG locale per recupero contestuale).

Engine IA & Embeddings: Groq Cloud API (Modello llama-3.3-7b-versatile a Temperature = 0 per classificazione rigida) & OpenAI Embeddings (text-embedding-3-small per vettorizzazione semantica).

Ambiente d'Infrastruttura: Docker Desktop (Isolamento dei servizi e Docker Network bridge dedicata n8n-network).

Database Clients: Beekeeper Studio (SQL inspection) & MongoDB Compass (NoSQL document inspection).

🔄 Flusso Logico dei Dati

Il sistema implementa un design pattern Hub-and-Spoke strutturato in 4 macro-fasi sequenziali per abbattere il consumo di token e ottimizzare la context window.

Fase 1 — Ingestione & Sanitizzazione (Padre)

L'endpoint HTTP Webhook_Enterprise_Ingest riceve il payload dal client e mantiene attiva la connessione sincrona.

Il nodo JavaScript JS_Sanitize_and_Prepare:

Isola i metadati dell'utente.
Applica la sanitizzazione Regex per l'escaping degli apostrofi.
Protegge l'infrastruttura da crash sintattici SQL.
Fase 2 — Semantic Routing (Padre)

Il testo pulito viene analizzato da una Basic LLM Chain impostata a Temperature = 0 per garantire un comportamento deterministico.

L'IA restituisce esclusivamente un codice categorico rigido:

1 → Assistenza
2 → Legale
3 → Commerciale

Il codice viene intercettato da un nodo Switch che biforca fisicamente il flusso grafico su 3 rami indipendenti [riferimento Switch node criteria].

Fase 3 — Orchestrazione dei Sub-Workflows Disaccoppiati (Moduli)

Lo Switch aziona i nodi nativi Execute Workflow, invocando tre file .json indipendenti dotati di un proprio memory layout isolato.

Sub-Workflow A — Advanced AI RAG Engine

Un Tools Agent interroga il database vettoriale (Simple Vector Store) alimentato da modelli di Embedding per estrarre soluzioni dai manuali tecnici locali, applicando regole di protezione in caso di contesti vuoti.

Sub-Workflow B — Relational Audit Store

Un adattatore dati Edit Fields:

Isola le variabili.
Inietta i log transazionali nella tabella di PostgreSQL.
Utilizza query SQL native protette.
Sub-Workflow C — NoSQL Document Store

Un adattatore dedicato:

Mappa il payload commerciale.
Inserisce il payload come documento JSON integro all'interno della collezione di MongoDB.
Fase 4 — Consolidamento & Output Sincrono (Padre)

I rami asincroni convergono in un nodo Merge in modalità Append con sblocco immediato (Wait for Any Input).

Un blocco finale di Data Lineage (Edit Fields) esegue un tracciamento della linea temporale del workflow, recuperando i metadati nativi del Padre tramite puntatori espliciti.

Il report manageriale compilato viene spedito al client tramite il nodo Respond to Webhook, chiudendo la connessione.

🔒 Considerazioni sulla Sicurezza & Cybersecurity

L'architettura garantisce l'isolamento perimetrale dei dati sensibili all'interno della rete chiusa di Docker.

I sotto-workflow non accedono direttamente alla rete esterna, ma vengono attivati esclusivamente dall'orchestratore centrale (Hub) che agisce da API Gateway protetto.

Il sistema implementa il pattern del Data Adapter intermedio (Edit Fields) prima delle persistenza relazionali e NoSQL, fungendo da fail-safe architetturale:

Normalizza i tipi di dato.
Previene crash hardware di tipo timestamp o undefined.
Gestisce chiamate parziali o corrotte dal client.
📈 Scalabilità & Analisi dei Costi (Local vs Cloud TCO)

Il progetto è stato strutturato originariamente in locale su Docker per ottimizzazione delle risorse hardware e gestione di test a budget zero.

Analisi dei Costi Cloud (VPS / IaaS)

Per una produzione su larga scala capace di gestire flussi costanti di comunicazioni, l'intero stack:

n8n
PostgreSQL
MongoDB

prevede la migrazione su una VPS Linux Dedicata (es. Aruba Cloud / Hetzner) a un costo stimato di circa 12,00 €/mese, mantenendo i costi computazionali dell'IA ottimizzati grazie all'utilizzo dei modelli ad alte prestazioni di Groq Cloud.

Disaccoppiamento Orizzontale

L'architettura modulare consente una scalabilità orizzontale nativa.

In produzione, ogni sotto-workflow può essere:

Spostato su istanze n8n separate.
Convertito in microservizi containerizzati.
Distribuito su un cluster Kubernetes.

Il tutto senza dover alterare la logica del Router Semantico Padre.

🛠️ Note Tecniche di Sviluppo

Durante lo sviluppo e il testing dell'infrastruttura sono state affrontate e risolte le seguenti criticità architetturali.

1. Gestione dello Stallo Hardware nel Merge

Nella prima release, il nodo Merge configurato in modalità Wait for All Inputs generava timeout permanenti a causa della natura mutuamente esclusiva dello Switch a monte.

Il problema è stato risolto riconfigurando il Merge in modalità Append a sblocco rapido, consentendo il passaggio del singolo ramo attivo.

2. Risoluzione del Data Leakage Transazionale

A causa dello scope limitato della variabile locale $json in n8n v1+, i dati provenienti dai sotto-workflow non includevano i metadati di ingestione del Padre, restituendo valori vuoti o N/A.

La criticità è stata superata:

Bypassando la memoria relativa dell'ultimo nodo.
Forzando l'orchestratore a eseguire un tracciamento storico esplicito dei nodi di origine.
Fondendo metadati e risposte dei database in un report manageriale unico.
