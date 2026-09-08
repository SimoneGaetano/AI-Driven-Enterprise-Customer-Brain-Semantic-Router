# AI-Driven Enterprise Customer Brain & Semantic Router

Un'architettura backend a microservizi asincrona e disaccoppiata, sviluppata inizialmente in ambiente locale.

Il sistema agisce come un AI Gateway in grado di acquisire comunicazioni non strutturate ad alto volume — come ticket tecnici, richieste legali e lead commerciali — analizzare l'intento dell'utente attraverso un Semantic Routing deterministico e orchestrare l'esecuzione downstream su molteplici database relazionali, NoSQL documentali e vettoriali semantici.

## 🛠️ Stack Tecnologico & Architettura
Orchestratore / Backend: n8n (esecuzione self-hosted v1+, configurato per risposte sincrone)
Database Relazionale: PostgreSQL 15 (persistenza dei dati e vincoli ACID per gli audit log legali)
Database NoSQL: MongoDB 6 (persistenza documentale polimorfa per lead commerciali flessibili)
Database Vettoriale Semantico: Simple Vector Store In-Memory (motore RAG locale per il recupero contestuale)
Engine IA & Embeddings: Groq Cloud API con modello llama-3.3-7b-versatile a Temperature = 0 per la classificazione rigida + OpenAI Embeddings text-embedding-3-small per la vettorizzazione semantica
Infrastruttura: Docker Desktop (isolamento dei servizi e Docker Network bridge dedicata n8n-network)
Database Clients: Beekeeper Studio (SQL inspection) & MongoDB Compass (NoSQL document inspection)
🔄 Flusso Logico dei Dati

Il sistema implementa un design pattern Hub-and-Spoke, strutturato in 4 macro-fasi sequenziali per ridurre il consumo di token e ottimizzare la context window.

Fase 1 — Ingestione & Sanitizzazione (Padre)

L'endpoint HTTP Webhook_Enterprise_Ingest riceve il payload dal client e mantiene attiva la connessione sincrona.

Il nodo JavaScript JS_Sanitize_and_Prepare:

Isola i metadati dell'utente.
Applica la sanitizzazione Regex per l'escaping degli apostrofi.
Protegge l'infrastruttura da crash sintattici SQL.
Fase 2 — Semantic Routing (Padre)

Il testo pulito viene analizzato da una Basic LLM Chain impostata a Temperature = 0, garantendo un comportamento deterministico.

L'IA restituisce esclusivamente un codice categorico rigido:

Codice	Categoria
1	Assistenza
2	Legale
3	Commerciale

Il codice viene intercettato da un nodo Switch che biforca fisicamente il flusso grafico su 3 rami indipendenti [riferimento Switch node criteria].

Fase 3 — Orchestrazione dei Sub-Workflows Disaccoppiati

Lo Switch aziona i nodi nativi Execute Workflow, invocando tre file .json indipendenti, ciascuno dotato di un proprio memory layout isolato.

Sub-Workflow A — Advanced AI RAG Engine

Un Tools Agent interroga il database vettoriale Simple Vector Store, alimentato da modelli di Embedding, per estrarre soluzioni dai manuali tecnici locali.

Il sistema applica inoltre regole di protezione nel caso in cui il recupero semantico non restituisca alcun contesto utile.

Sub-Workflow B — Relational Audit Store

Un adattatore dati Edit Fields:

Isola le variabili necessarie.
Normalizza il payload.
Inietta i log transazionali nella tabella PostgreSQL.
Utilizza query SQL native protette.
Sub-Workflow C — NoSQL Document Store

Un adattatore dedicato:

Mappa il payload commerciale.
Mantiene la struttura JSON originale.
Inserisce il documento all'interno della collezione MongoDB.
Fase 4 — Consolidamento & Output Sincrono (Padre)

I rami asincroni convergono in un nodo Merge configurato in modalità Append con sblocco immediato (Wait for Any Input).

Un blocco finale di Data Lineage (Edit Fields) esegue un tracciamento della linea temporale del workflow, recuperando i metadati nativi del Padre tramite puntatori espliciti.

Il report manageriale finale viene quindi inviato al client tramite il nodo Respond to Webhook, chiudendo la connessione.

## 🔒 Sicurezza & Cybersecurity

L'architettura garantisce l'isolamento perimetrale dei dati sensibili all'interno della rete chiusa di Docker.

I sotto-workflow non accedono direttamente alla rete esterna, ma vengono attivati esclusivamente dall'orchestratore centrale (Hub), che agisce come API Gateway protetto.

Il sistema implementa inoltre il pattern del Data Adapter intermedio (Edit Fields) prima della persistenza sui database relazionali e NoSQL.

Questo componente funge da fail-safe architetturale:

Normalizza i tipi di dato.
Previene errori relativi a timestamp o undefined.
Gestisce chiamate parziali o payload corrotti provenienti dal client.
Riduce il rischio di propagazione di dati malformati verso i database downstream.
## 📈 Scalabilità & Analisi dei Costi — Local vs Cloud TCO

Il progetto è stato strutturato originariamente in ambiente locale tramite Docker per ottimizzare le risorse hardware e consentire una gestione dei test a budget zero.

Analisi dei Costi Cloud — VPS / IaaS

Per una produzione su larga scala capace di gestire flussi costanti di comunicazioni, l'intero stack:

n8n
PostgreSQL
MongoDB

può essere migrato su una VPS Linux dedicata (es. Aruba Cloud / Hetzner) a un costo stimato di circa 12,00 €/mese.

L'utilizzo di modelli ad alte prestazioni tramite Groq Cloud permette inoltre di mantenere ottimizzati i costi computazionali dell'IA.

Disaccoppiamento Orizzontale

L'architettura modulare tramite Sub-Workflows consente una scalabilità orizzontale nativa.

In produzione, ogni sotto-workflow può essere:

Spostato su istanze n8n separate.
Convertito in microservizi containerizzati.
Distribuito su un cluster Kubernetes.

Il tutto senza dover modificare la logica del Router Semantico Padre.

## 🛠️ Note Tecniche di Sviluppo

Durante lo sviluppo e il testing dell'infrastruttura sono state affrontate e risolte diverse criticità architetturali.

1. Gestione dello Stallo Hardware nel Merge

Nella prima release, il nodo Merge configurato in modalità Wait for All Inputs generava timeout permanenti a causa della natura mutuamente esclusiva dello Switch a monte.

Lo Switch attivava infatti un solo ramo alla volta, impedendo al Merge di ricevere tutti gli input attesi.

Soluzione:

Il Merge è stato riconfigurato in modalità Append a sblocco rapido, consentendo al workflow di proseguire immediatamente con il singolo ramo attivo.

2. Risoluzione del Data Leakage Transazionale

A causa dello scope limitato della variabile locale $json in n8n v1+, i dati provenienti dai sotto-workflow non includevano correttamente i metadati di ingestione del Padre, generando valori vuoti o N/A.

La criticità è stata superata:

Bypassando la memoria relativa dell'ultimo nodo.
Forzando l'orchestratore a eseguire un tracciamento storico esplicito dei nodi di origine.
Recuperando i metadati originali del workflow Padre.
Fondendo metadati e risposte provenienti dai database downstream.
Generando un report manageriale unico e completo come output finale.
