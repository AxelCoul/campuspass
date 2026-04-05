# Améliorations proposées — Proposition de projet

Ce document complète la proposition initiale avec des précisions et des pistes d’amélioration pour clarifier le périmètre et la réalisation.

---

## 1. Clarifications sur la proposition actuelle

### 1.1 Numérotation des écrans

- Les écrans 15–17 (Scanner commerce, Validation coupon, Succès réduction) concernent plutôt **l’usage en magasin** : l’étudiant montre son QR, le commerçant scanne. À préciser si l’app étudiant a aussi un “scan” (ex. scanner un QR du commerce pour ouvrir une offre) ou si le scan est uniquement côté commerçant.
- **Recommandation :** distinguer clairement “écran où l’étudiant affiche son QR” et “écran où le commerçant scanne le QR”.

### 1.2 Cohérence des noms

- Dans les maquettes : “STUDENT DEALS” / “STUDENT APPS”. Dans le code : “CampusPass” (campuspass_app).
- **Recommandation :** choisir un nom unique (ex. “CampusPass” ou “Student Deals”) et l’utiliser partout (apps, admin, doc, maquettes).

### 1.3 Architecture schéma

- Le schéma en “arbre” peut laisser penser que les 3 frontends sont empilés. En réalité, les 3 apps appellent la même API.
- **Recommandation :** un schéma du type :

```
[App Étudiant]  [App Commerce]  [Admin Angular]
        \              |                /
         \             |               /
          \            v              /
           \----> API REST (Spring Boot)
                        |
                        v
                 PostgreSQL
```

---

## 2. Améliorations fonctionnelles

### 2.1 Prérequis pour les étudiants

- **Vérification du statut étudiant** (carte ISIC, email universitaire, pièce, etc.) pour limiter les abus.
- **Recommandation :** définir dès la Phase 1 comment on valide le statut (manuel par admin, automatique via domaine email, ou partenaire type ISIC).

### 2.2 Géo et “offres à proximité”

- Les objectifs parlent de “trouver des réductions” et les maquettes d’“offres à proximité”.
- **Recommandation :** prévoir en base (et dans l’API) : adresse du commerce, coordonnées GPS, rayon de recherche, et un endpoint du type “offres à proximité” (par position + rayon ou par ville).

### 2.3 Catégories d’offres

- Maquettes : Restauration, Supermarché, Loisirs.
- **Recommandation :** modéliser une entité “Catégorie” (nom, icône, ordre) et lier les offres aux catégories pour filtrage et affichage par onglets.

### 2.4 Limitation d’usage des coupons

- Pour “anti-fraude” et “QR unique”, il faut définir les règles : 1 utilisation par offre par étudiant ? Par jour ? Par commerce ?
- **Recommandation :** documenter ces règles (ex. “un coupon = une utilisation, durée de vie 15 min”) et les refléter dans le modèle de données et l’API.

### 2.5 Notifications

- La proposition mentionne : nouvelle offre, expiration, promotions.
- **Recommandation :** préciser les canaux (push, email, in-app) et, pour la roadmap, prévoir au moins les notifications in-app puis push (Firebase / FCM pour Flutter).

---

## 3. Améliorations techniques

### 3.1 API REST

- **Versionnement :** prévoir un préfixe d’API (ex. `/api/v1/`) pour faciliter les évolutions.
- **Documentation :** OpenAPI (Swagger) pour que les 3 frontends s’alignent sur les contrats (endpoints, DTOs, erreurs).
- **Pagination :** pour “liste offres”, “liste commerces”, “historique”, prévoir `page`, `size` (ou `limit`/`offset`) et un format de réponse standard (ex. `{ data: [], total, page }`).

### 3.2 Sécurité

- **JWT :** durée de vie courte (access token) + refresh token stocké proprement (httpOnly cookie ou stockage sécurisé côté app).
- **CORS :** configurer explicitement les origines autorisées (admin Angular, éventuellement web Flutter) dans le backend.
- **HTTPS** obligatoire en production pour l’API et les apps.

### 3.3 Base de données

- **Naming :** une convention claire (ex. snake_case pour les tables et colonnes) pour rester cohérent avec un éventuel schéma partagé (migrations SQL ou Flyway/Liquibase).
- **Historique :** garder un historique des utilisations de coupons (qui, quand, quel commerce, quelle offre) pour stats, litiges et anti-fraude.

### 3.4 Apps Flutter

- **Gestion d’état :** pour une app un peu riche (liste offres, profil, historique), prévoir une solution (Provider, Riverpod, Bloc) dès la Phase 3 pour éviter le refactoring plus tard.
- **Environnements :** fichier de config ou variables d’environnement pour l’URL de l’API (dev / staging / prod) sans recompiler à la main.

---

## 4. Roadmap affinée

| Phase | Détail suggéré |
|-------|----------------|
| **Phase 1** | Backend : schéma DB (users, commerces, offres, coupons, utilisations), auth (inscription/connexion JWT), CORS, Swagger. |
| **Phase 2** | Backend : CRUD offres, génération/validation de coupons (QR = id unique + expiration), endpoints “offres à proximité” si besoin. |
| **Phase 3** | App étudiant : auth, liste/détail offres, génération QR, historique. Gestion d’état + config API. |
| **Phase 4** | App commerçant : auth, dashboard, CRUD offres (si prévu), scan QR + appel API validation. |
| **Phase 5** | Admin Angular : auth, dashboard, validation commerces, gestion offres/utilisateurs, stats. |
| **Phase 6 (optionnel)** | Notifications (in-app puis push), amélioration UX, déploiement (backend + DB + apps). |

---

## 5. Résumé des actions recommandées

1. **Nom de produit** : un seul (CampusPass ou Student Deals) partout.  
2. **Schéma d’architecture** : mettre à jour le schéma pour montrer les 3 clients et une seule API.  
3. **Règles métier** : statut étudiant, usage unique / durée de vie des coupons, “offres à proximité”.  
4. **Données** : catégories, localisation des commerces, historique des utilisations.  
5. **Technique** : API versionnée, Swagger, pagination, CORS, JWT + refresh, gestion d’état Flutter, config d’environnement.  
6. **Roadmap** : ajouter une phase “notifications / déploiement” si besoin.

Ces améliorations peuvent être intégrées progressivement dans la proposition principale (`PROJET_PROPOSITION.md`) ou gardées comme cahier des charges détaillé à côté.
