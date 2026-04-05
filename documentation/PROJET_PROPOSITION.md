# Proposition de projet — Plateforme de réductions étudiantes

## 1. Présentation du projet

Le projet consiste à développer une **plateforme de réductions étudiantes** permettant aux étudiants de bénéficier d’offres exclusives chez des commerçants partenaires.

Le système comprend **3 applications** :

1. **Application mobile étudiant**
2. **Application mobile commerçant**
3. **Interface web administrateur**

**Inspiré par des plateformes comme :**

- **UNiDAYS**
- **Uber Eats**

---

## 2. Objectifs du projet

### Objectifs étudiants

- Trouver des réductions
- Générer un QR Code
- Utiliser une réduction en magasin

### Objectifs commerçants

- Attirer des étudiants
- Scanner les QR codes
- Gérer leurs offres

### Objectifs administrateur

- Valider les commerçants
- Ajouter des partenaires
- Contrôler les offres

---

## 3. Acteurs du système

### Étudiant

**Peut :**

- créer un compte
- consulter des offres
- générer un coupon
- utiliser une réduction

### Commerçant

**Peut :**

- créer un commerce
- ajouter des offres
- scanner les QR codes

### Administrateur

**Peut :**

- gérer les utilisateurs
- valider les commerces
- gérer les offres

---

## 4. Architecture du système

Architecture **3 couches** moderne.

| Couche        | Technologie  |
|---------------|-------------|
| Frontend mobile | **Flutter** |
| Backend        | **Spring Boot** |
| Admin panel    | **Angular** |
| Base de données | **PostgreSQL** |

**Schéma :**

```
Flutter App (Étudiant)
        |
Flutter App (Commerçant)  ——→  API REST  ——→  Spring Boot Backend
        |                                              |
Angular Admin Panel                                    |
        |                                              ↓
        └——————————————————————————————→  PostgreSQL Database
```

---

## 5. Fonctionnalités principales

### Authentification

- Inscription
- Connexion
- Récupération mot de passe
- Gestion profil

### Gestion des commerces

- Créer un commerce
- Modifier un commerce
- Localisation
- Validation admin

### Gestion des offres

- Créer une offre
- Modifier une offre
- Supprimer une offre
- Définir réduction %

### Coupons QR

- Générer QR code
- Scanner QR code
- Validation réduction
- Historique des coupons

### Notifications

- Nouvelle offre
- Expiration offre
- Promotions

---

## 6. Liste complète des écrans

### App Étudiant (Flutter)

**Authentification**

1. Écran splash  
2. Onboarding  
3. Connexion  
4. Inscription  
5. Mot de passe oublié  

**Accueil**

6. Accueil  
7. Recherche  
8. Catégories  
9. Liste des commerces  
10. Détail commerce  

**Offres**

11. Liste offres  
12. Détail offre  
13. Générer coupon  
14. QR code coupon  

**Utilisation**

15. Scanner commerce  
16. Validation coupon  
17. Succès réduction  

**Profil**

18. Profil utilisateur  
19. Modifier profil  
20. Historique coupons  

### App Commerçant (Flutter)

21. Connexion commerçant  
22. Dashboard commerce  
23. Liste offres  
24. Créer offre  
25. Modifier offre  

**Scan**

26. Scanner QR étudiant  
27. Validation coupon  

### Admin Panel (Angular)

28. Dashboard admin  
29. Gestion utilisateurs  
30. Gestion commerces  
31. Validation commerce  
32. Gestion offres  

---

## 7. Parcours utilisateur

### Étudiant

1. Ouvrir app  
2. Se connecter  
3. Voir offres  
4. Choisir offre  
5. Générer QR code  
6. Montrer QR au commerçant  
7. Commerçant scanne  
8. Réduction appliquée  

### Commerçant

1. Ouvrir app  
2. Scanner QR  
3. Vérifier validité  
4. Confirmer réduction  

---

## 8. Sécurité

Système sécurisé avec :

- **JWT** (authentification)
- **Validation QR unique**
- **Expiration coupon**
- **Anti-fraude**

---

## 9. Technologies

| Rôle      | Technologie   |
|-----------|----------------|
| Mobile    | Flutter        |
| Backend   | Spring Boot    |
| Admin     | Angular        |
| Database  | PostgreSQL     |

---

## 10. Roadmap de développement

| Phase | Contenu |
|-------|---------|
| **Phase 1** | Architecture backend, base de données, authentification |
| **Phase 2** | API offres, API coupons, QR code |
| **Phase 3** | App étudiant Flutter |
| **Phase 4** | App commerçant Flutter |
| **Phase 5** | Admin Angular |

---

## Maquettes

Voir l’image des maquettes dans le dossier `documentation/assets/` : **maquettes-app-students-deals.png**

*(Placer dans ce dossier la capture d’écran des maquettes si elle n’y figure pas encore.)*
