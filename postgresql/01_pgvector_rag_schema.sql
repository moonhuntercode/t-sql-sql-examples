-- ==============================================================================
-- Script: postgresql/01_pgvector_rag_schema.sql
-- Motor: PostgreSQL 15+ / 16+ con extensión pgvector
-- Descripción: Esquema normalizado (3FN) para pipelines RAG e Inteligencia
--              Artificial, separando metadatos de embeddings pesados, con
--              índices HNSW y búsqueda híbrida (Full Text Search + Vectorial).
-- ==============================================================================

-- 1. Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Esquema Relacional Normalizado (3FN)

-- Tabla Padre: Documentos y Metadatos (Ligera, óptima para escaneos y caché)
DROP TABLE IF EXISTS documento_chunks CASCADE;
DROP TABLE IF EXISTS documentos CASCADE;

CREATE TABLE documentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Hija: Fragmentos (Chunks) y Embeddings (Carga densa aislada)
-- Utiliza dimensión 1536 (OpenAI text-embedding-3-small) o 768 / 384 según necesidad
CREATE TABLE documento_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    documento_id UUID NOT NULL,
    chunk_index INT NOT NULL,
    contenido TEXT NOT NULL,
    embedding VECTOR(1536) NOT NULL,
    tsv_contenido TSVECTOR GENERATED ALWAYS AS (to_tsvector('spanish', contenido)) STORED,
    CONSTRAINT FK_Chunk_Documento FOREIGN KEY (documento_id)
        REFERENCES documentos(id) ON DELETE CASCADE,
    CONSTRAINT UQ_Documento_Chunk UNIQUE (documento_id, chunk_index)
);

-- 3. Índices Estratégicos

-- A) Índice relacional B-Tree para JOINs inmediatos
CREATE INDEX idx_chunks_documento_id ON documento_chunks(documento_id);

-- B) Índice GIN para consultas JSONB sobre metadatos
CREATE INDEX idx_documentos_metadata ON documentos USING GIN(metadata);

-- C) Índice GIN para Búsqueda Léxica (Full Text Search)
CREATE INDEX idx_chunks_tsv ON documento_chunks USING GIN(tsv_contenido);

-- D) Índice HNSW para Búsqueda Semántica de Vectores (Distancia Coseno)
CREATE INDEX idx_chunks_embedding_hnsw 
ON documento_chunks 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- 4. Función de Búsqueda Semántica K-Nearest Neighbors (KNN)
CREATE OR REPLACE FUNCTION buscar_chunks_semanticos(
    query_embedding VECTOR(1536),
    limite INT DEFAULT 5
)
RETURNS TABLE (
    chunk_id UUID,
    documento_id UUID,
    titulo VARCHAR(255),
    contenido TEXT,
    similitud DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        c.id AS chunk_id,
        d.id AS documento_id,
        d.titulo,
        c.contenido,
        1 - (c.embedding <=> query_embedding) AS similitud
    FROM documento_chunks c
    INNER JOIN documentos d ON c.documento_id = d.id
    ORDER BY c.embedding <=> query_embedding ASC
    LIMIT limite;
$$;
