# Instructions complètes – Application Étudiant (Campus Pass)

## 1. Backend (déjà en place)

### Entités
- **SubscriptionPlan** : `name`, `type` (MONTHLY/YEARLY), `price`, `promoPrice`, `startPromoDate`, `endPromoDate`, `active`
- **StudentSubscription** : `studentId`, `planId`, `startDate`, `endDate`, `status` (ACTIVE/EXPIRED/CANCELLED)
- **SubscriptionPayment** : `studentId`, `planId`, `amount`, `paymentMethod` (ORANGE_MONEY/MTN_MOMO/MOOV_MONEY), `status`, `phoneNumber`, OTP mock

### Endpoints
| Méthode | URL | Description |
|--------|-----|-------------|
| POST | `/api/auth/register` | Inscription (body: firstName, lastName, email, password, phoneNumber, **university**, role=STUDENT) |
| POST | `/api/auth/login` | Connexion (email, password) |
| GET | `/api/plans` | Liste des plans actifs (public) |
| GET | `/api/plans/{id}` | Détail plan (public) |
| POST | `/api/subscription/subscribe` | Lancer paiement (JWT, body: planId, paymentMethod, phoneNumber) → retourne paymentId, amount, otpMock: "1234" |
| POST | `/api/subscription/confirm-otp` | Confirmer OTP (JWT, body: paymentId, otp) → active l’abonnement |
| GET | `/api/subscription/payments` | Historique paiements (JWT) |
| GET | `/api/student/me` | Profil + statut abo + totalSavings + loyaltyPoints (JWT) |
| GET | `/api/student/savings` | totalSaved, offersUsedCount, merchantsVisitedCount, history (JWT) |
| GET/POST/PUT/DELETE | `/api/admin/plans` | CRUD plans (admin) |

### Inscription étudiant
- `RegisterRequest` a un champ **university** (optionnel). Lors de l’inscription avec `role=STUDENT`, un **StudentProfile** est créé avec `university`.

### OTP Mobile Money (mock)
- Après `POST /api/subscription/subscribe`, la réponse contient `otpMock: "1234"`.
- Envoyer `POST /api/subscription/confirm-otp` avec `{"paymentId": <id>, "otp": "1234"}` pour valider.

---

## 2. Application Flutter (campuspass_app)

### Couleurs (thème startup)
- **Primaire** : `#6C4EFF` (violet)
- **Secondaire** : `#FF7A00` (orange promotions)
- **Succès** : `#00C853` (vert économies)
- **Background** : `#F5F6FA` (gris clair)

### Navigation principale (Bottom Navigation)
1. **Accueil** – Bannière promo, offres populaires, offres proches, sponsorisées
2. **Explorer** – Recherche + filtres (Restaurants, Supermarchés, Fast food, Loisirs, Cinéma)
3. **Mes économies** – Total économisé, nb offres utilisées, nb commerces, historique
4. **Notifications** – Liste des notifications
5. **Profil** – Infos, Mon abonnement, Mes paiements, Mes économies, Support, Déconnexion

### Parcours
1. **Splash** → (si pas connecté) **Onboarding** (3 écrans) → **Connexion** ou **Inscription**
2. **Inscription** : Nom, Prénom, Email, Téléphone, Mot de passe, Université, (carte étudiant option)
3. **Connexion** : Email/téléphone, Mot de passe, “Mot de passe oublié”
4. Après connexion : **Main Shell** (5 onglets)
5. Depuis Accueil ou Profil : **Abonnement** → choix plan (prix barré si promo) → **Paiement** (Orange / MTN / Moov) → **OTP** → **Succès**

### Écrans à implémenter (liste)
- Splash, Onboarding 1–3, Register, Login
- Home, Explore, CommerceDetail, OfferDetail
- Savings (Mes économies), LoyaltyPoints (optionnel)
- Notifications, Profile
- Subscription (liste plans), Payment (choix opérateur + numéro), PaymentOTP, PaymentSuccess, PaymentHistory
- Settings, Support
- QR (utiliser l’offre : afficher QR code)

### API base URL
- Même backend que commerce : `http://10.0.2.2:8081/api` (émulateur Android).
- Envoyer le token JWT dans `Authorization: Bearer <token>` pour `/api/student/**` et `/api/subscription/**`.

### Packages utiles
- `go_router` : routes (splash, onboarding, login, register, home, explore, savings, notifications, profile, subscription, payment, etc.)
- `dio` : appels API + interceptor pour le token
- `shared_preferences` ou `flutter_secure_storage` : stocker le token et l’userId après login/register

### Rôle étudiant
- **Utilisateur gratuit** : peut voir les offres (GET /api/offers).
- **Abonné** : peut en plus utiliser les réductions (générer/utiliser coupons, scanner côté commerce). Le backend peut vérifier une abonnement actif (StudentSubscription avec endDate >= today) pour certaines actions.

### Statistiques étudiant (backend)
- **totalSavings** : somme des `discountAmount` des transactions de l’étudiant (GET /api/student/me et /api/student/savings).
- **loyaltyPoints** : dérivé des économies (ex. totalSavings / 100).
- **offersUsedCount** / **merchantsVisitedCount** : dérivés des transactions (GET /api/student/savings).

---

## 3. Admin – Plans d’abonnement

- **GET /api/admin/plans** : liste tous les plans.
- **POST /api/admin/plans** : body `SubscriptionPlanRequest` (name, type, price, promoPrice, startPromoDate, endPromoDate, active).
- **PUT /api/admin/plans/{id}** : mise à jour.
- **DELETE /api/admin/plans/{id}** : suppression.

Exemple lancement : plan “Abonnement annuel” 5000 FCFA, promo 3000 FCFA avec `startPromoDate` et `endPromoDate` définis par l’admin. L’app étudiant affiche le prix barré (5000) et le prix promo (3000) si la date du jour est dans la période promo.

---

## 4. Résumé technique

- **Auth** : register (avec university) → StudentProfile créé ; login → JWT.
- **Plans** : GET /api/plans (public) ; admin CRUD sous /api/admin/plans.
- **Abonnement** : subscribe → confirm-otp (mock 1234) → StudentSubscription créé.
- **Économies** : GET /api/student/savings (historique transactions = économies).
- **Flutter** : thème (#6C4EFF, #FF7A00, #00C853, #F5F6FA), bottom nav 5 onglets, go_router, Dio + token, écrans listés ci‑dessus.
