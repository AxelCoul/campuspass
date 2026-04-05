-- Migration optionnelle : aligner les anciennes propositions commerçant (PENDING) sur le statut PROPOSED.
-- À exécuter une fois après déploiement du code qui introduit PROPOSED.
-- Vérifier d'abord le nombre de lignes : SELECT status, COUNT(*) FROM offers GROUP BY status;

UPDATE offers
SET status = 'PROPOSED'
WHERE status = 'PENDING';
