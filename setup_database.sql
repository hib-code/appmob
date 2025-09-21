-- Script SQL pour créer la table clients dans Supabase
-- Exécutez ce script dans l'éditeur SQL de votre dashboard Supabase

-- Créer la table clients si elle n'existe pas
CREATE TABLE IF NOT EXISTS public.clients (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    notes TEXT,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Créer un index sur le nom pour les recherches
CREATE INDEX IF NOT EXISTS idx_clients_name ON public.clients(name);

-- Créer un index sur le téléphone pour les recherches
CREATE INDEX IF NOT EXISTS idx_clients_phone ON public.clients(phone);

-- Créer un index sur la date de création
CREATE INDEX IF NOT EXISTS idx_clients_created_at ON public.clients(created_at);

-- Activer RLS (Row Level Security)
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

-- Créer une politique pour permettre l'insertion (authentifié)
CREATE POLICY "Allow insert for authenticated users" ON public.clients
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Créer une politique pour permettre la lecture (authentifié)
CREATE POLICY "Allow read for authenticated users" ON public.clients
    FOR SELECT USING (auth.role() = 'authenticated');

-- Créer une politique pour permettre la mise à jour (authentifié)
CREATE POLICY "Allow update for authenticated users" ON public.clients
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Créer une politique pour permettre la suppression (authentifié)
CREATE POLICY "Allow delete for authenticated users" ON public.clients
    FOR DELETE USING (auth.role() = 'authenticated');

-- Créer le bucket de stockage pour les photos si il n'existe pas
INSERT INTO storage.buckets (id, name, public)
VALUES ('clients', 'clients', true)
ON CONFLICT (id) DO NOTHING;

-- Créer une politique pour le stockage des photos
CREATE POLICY "Allow upload for authenticated users" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'clients' AND auth.role() = 'authenticated');

CREATE POLICY "Allow read for authenticated users" ON storage.objects
    FOR SELECT USING (bucket_id = 'clients' AND auth.role() = 'authenticated');

-- Afficher la structure de la table
\d public.clients;
