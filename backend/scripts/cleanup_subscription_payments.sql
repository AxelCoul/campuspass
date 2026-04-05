-- Nettoyage ponctuel des paiements d'abonnement bloqués (à exécuter manuellement sur PostgreSQL si besoin).
-- Adapter les délais selon ta politique métier.

-- 1) Marquer en échec les tentatives très anciennes encore en CREATED ou PENDING
--    (le backend peut aussi expirer automatiquement via subscription.payment.expire-after-minutes).
UPDATE subscription_payments
SET status = 'FAILED'
WHERE status IN ('CREATED', 'PENDING')
  AND created_at < NOW() - INTERVAL '7 days';

-- 2) Optionnel : ne traiter que les CREATED abandonnés (sans paiement initié côté Yenga)
-- UPDATE subscription_payments SET status = 'FAILED'
-- WHERE status = 'CREATED' AND created_at < NOW() - INTERVAL '48 hours';
