# Architecture complète – Campus Pass

> Backend Spring Boot + Admin Angular + App Étudiant Flutter + App Commerce Flutter

---

## 1. Backend – Spring Boot

### 1.1. Stack et principes

- **Techno** : Spring Boot 3, Spring Security (JWT), Spring Data JPA (PostgreSQL), Validation, Web.
- **Base URL API** : `http://10.0.2.2:8081/api` (utilisée par les apps Flutter et l’admin Angular).
- Toutes les apps clientes parlent au **même backend**.

### 1.2. Utilisateurs et rôles

**Entité `User`** (vue d’ensemble) :
- Champs principaux : `id`, `firstName`, `lastName`, `email`, `phoneNumber`, `passwordHash`, `role`, `status`, dates de création/mise à jour.
- **Rôles** :
  - `STUDENT` : étudiant (app étudiant).
  - `MERCHANT` : commerçant (app commerce).
  - `ADMIN` : administrateur (panneau admin).

**Authentification / JWT** :
- `AuthController` (`/api/auth`) :
  - `POST /api/auth/register`  
    - crée un `User` avec `role=STUDENT` (pour l’app étudiant).
    - crée **automatiquement** un `StudentProfile` (champ `university`, etc.).
  - `POST /api/auth/login` : login pour tous les rôles (STUDENT, MERCHANT, ADMIN).
  - `POST /api/auth/admin/login` : login réservé aux admins, utilisé par `admin_app`.
- `JwtService` : génère/valide les tokens avec `userId`, `email`, `role`.
- `JwtAuthFilter` : lit le header `Authorization: Bearer <token>`, valide et peuple le `SecurityContext` avec un `SecurityUser`.
- `SecurityConfig` :
  - `/api/auth/**` : accès public.
  - APIs métier protégées par rôles (`hasRole("ADMIN")`, `hasAnyRole("MERCHANT","ADMIN")`, etc.).

### 1.3. Étudiants, abonnements et économies

**Entités** :
- `StudentProfile` : infos supplémentaires pour l’étudiant (université, etc.).
- `SubscriptionPlan` : plan d’abonnement (nom, type `MONTHLY/YEARLY`, `price`, `promoPrice`, dates promo, `active`).
- `StudentSubscription` : lien étudiant ↔ plan, avec `startDate`, `endDate`, `status` (`ACTIVE`, `EXPIRED`, `CANCELLED`).
- `SubscriptionPayment` : paiement d’un abonnement (montant, méthode, statut, téléphone, OTP mock).
- `Transaction` : transaction générée lorsqu’un étudiant utilise une offre (montant initial, réduction, montant final, offre, commerce, date, statut).
- `Coupon` : coupon associé à une offre/transaction (`CouponStatus`: `GENERATED`, `USED`, `EXPIRED`).

**Endpoints principaux** :

Abonnements & plans :
- `GET /api/plans` : liste des plans d’abonnement actifs (public).
- `GET /api/plans/{id}` : détail d’un plan.
- `POST /api/subscription/subscribe` (JWT STUDENT) :  
  body: `{ planId, paymentMethod, phoneNumber }`  
  → crée un `SubscriptionPayment` avec `otpMock = "1234"` et renvoie `paymentId`, `amount`, `otpMock`.
- `POST /api/subscription/confirm-otp` (JWT STUDENT) :  
  body: `{ paymentId, otp }` (ici `1234`)  
  → valide le paiement, crée/active `StudentSubscription`.
- `GET /api/subscription/payments` (JWT STUDENT) : historique des paiements.
- **Admin** : `GET/POST/PUT/DELETE /api/admin/plans` pour gérer les plans.

Profil et économies étudiant :
- `GET /api/student/me` (JWT STUDENT) → `StudentMeResponse` :
  - identités de base,
  - `hasActiveSubscription`, `subscriptionEndDate`, `subscriptionPlanName`,
  - `totalSavings`, `loyaltyPoints`.
- `GET /api/student/savings` (JWT STUDENT) → `StudentSavingsResponse` :
  - `totalSaved`,
  - `offersUsedCount`,
  - `merchantsVisitedCount`,
  - historique détaillé des économies (transactions).

### 1.4. Commerces (Merchant) et offres (Offer)

#### 1.4.1. Commerces

**Entité `Merchant`** :
- `id`, `ownerId` (User MERCHANT), `name`, `description`, `email`, `phone`, `website`,
  `logoUrl`, `coverImage`, `categoryId`,
  `address`, `city`, `country`, `latitude`, `longitude`,
  `verified`, `status` (`PENDING`, `APPROVED`, `REJECTED`, `SUSPENDED`),
  dates de création/mise à jour.

**Repository** : `MerchantRepository` :
- `findByOwnerId(Long ownerId)`,
- `findByStatus(MerchantStatus status)`.

**Service `MerchantService`** :
- `findAll()`,
- `findByOwnerId(ownerId)`,
- `getById(id)`,
- `create(ownerId, MerchantRequest)`,
- `update(id, MerchantRequest)`,
- `getTransactionsByMerchantId(merchantId)`,
- `getStatsByMerchantId(merchantId)` → stats détaillées (coupons du jour, revenu, offres actives, ventes totales, réductions, clients uniques, top offre, etc.).

**Controller `MerchantController`** (`/api/merchants`) :
- `GET /api/merchants` (+ `ownerId` optionnel),
- `GET /api/merchants/{id}`,
- `GET /api/merchants/{id}/transactions`,
- `GET /api/merchants/{id}/stats`,
- `POST /api/merchants` (création pour propriétaire connecté),
- `PUT /api/merchants/{id}` (mise à jour).

#### 1.4.2. Offres

**Entité `Offer`** :
- `id`, `merchantId`, `categoryId`,
- `title`, `description`, `termsConditions`,
- `originalPrice`, `discountPercentage`, `discountAmount`, `finalPrice`,
- `imageUrl`,
- `maxCoupons`, `usedCoupons`,
- `startDate`, `endDate`,
- `status` (`OfferStatus` : `PENDING`, `ACTIVE`, `INACTIVE`, `EXPIRED`, `DELETED`),
- dates de création/mise à jour.

**Repository `OfferRepository`** :
- `findByMerchantIdOrderByCreatedAtDesc(merchantId)`,
- `findByStatus(OfferStatus status)`,
- `findByCategoryIdAndStatus(categoryId, status)`.

**Service `OfferService`** :
- `findByMerchantId(merchantId)`,
- `findByMerchantIdAndFilter(merchantId, filter)` (`active`, `scheduled`, `expired`, `history`),
- `findActive()` : toutes les offres `ACTIVE` (pour app étudiant),
- `getById(id)`,
- `create(OfferRequest req)` :  
  - `usedCoupons = 0`,  
  - si ADMIN → `status = ACTIVE`,  
  - si MERCHANT → `status = PENDING`.
- `update(id, OfferRequest)`,
- `delete(id)`.

**Controller `OfferController`** (`/api/offers`) :
- `GET /api/offers` :  
  - sans param → `findActive()` (app étudiant),  
  - avec `merchantId` (+ `filter`) → listes côté commerce.
- `GET /api/offers/{id}`,
- `POST /api/offers`,
- `PUT /api/offers/{id}`,
- `DELETE /api/offers/{id}`.

### 1.5. Publicités (Advertisement) et bannières (Banner)

#### 1.5.1. Publicités – modèle économique

**Entité `Advertisement`** :
- `id`, `merchantId`,
- `title`, `description`, `imageUrl`,
- `targetUrl` (lien interne type `/subscription`, `/explore`),
- `position` (`AdPosition`) :
  - `HOME_BANNER` : grande bannière en haut de l’accueil étudiant,
  - `HOME_TOP` (disponible côté admin),
  - `SPONSORED_OFFER` : pub sponsorisée au milieu de la home,
  - `OFFERS_PAGE` : pub insérée dans la liste Explorer,
  - `SEARCH_PAGE`,
  - `NOTIFICATION` : notifications sponsorisées côté étudiant.
- `startDate`, `endDate`,
- `budget` (FCFA),
- `offerId` (facultatif : offre liée),
- `status` (`AdStatus` : `ACTIVE`, …),
- `createdAt`.

**Enum `AdPosition`** :
```java
HOME_BANNER,
HOME_TOP,
SPONSORED_OFFER,
OFFERS_PAGE,
SEARCH_PAGE,
NOTIFICATION
```

**Repository `AdvertisementRepository`** :
- `findByMerchantId(Long merchantId)`,
- `findByPositionAndStatus(AdPosition position, AdStatus status)`.

**Service `AdvertisementService`** :
- `findAll()`,
- `findByMerchantId(merchantId)`,
- `findByPosition(position)` → uniquement `ACTIVE`,
- `getById(id)`,
- `create(AdvertisementRequest req)`,
- `update(id, AdvertisementRequest req)`,
- `delete(id)`.

**DTOs** :
- `AdvertisementRequest` : champs optionnels pour créer/mettre à jour.
- `AdvertisementResponse` : renvoyé au front (admin + mobile).

**Controller `AdvertisementController`** (`/api/advertisements`) :
- `GET /api/advertisements` :  
  - `?position=HOME_BANNER` ou autre **→ utilisé par l’app étudiant**,
  - `?merchantId=...`,
  - sans paramètres → toutes les pubs (admin).
- `GET /api/advertisements/{id}`,
- `POST /api/advertisements`,
- `PUT /api/advertisements/{id}`,
- `DELETE /api/advertisements/{id}`.

#### 1.5.2. Bannières éditoriales (Banner)

**Entité `Banner`** (non payante, plutôt “contenu éditorial”) :
- `id`,
- `title`,
- `description`,
- `imageUrl`,
- `type` (chaîne : `SUBSCRIPTION`, `SPONSORED`, `EVENT`, `GENERIC`...),
- `linkUrl` (lien interne `/subscription`, `/explore`, etc.),
- `startDate`, `endDate`,
- `position` (ordre d’affichage),
- `active` (booléen),
- `createdAt`.

**Repository `BannerRepository`** :
- `findByActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByPositionAscIdAsc(...)`,
- `findByActiveTrueOrderByPositionAscIdAsc()` (fallback si pas de dates).

**DTOs** :
- `BannerRequest` : création/màj (titre, description, imageUrl, type, linkUrl, start/endDate, position, active).
- `BannerResponse` : renvoyé au front (admin + mobile).

**Service `BannerService`** :
- `findAll()`,
- `findActiveForToday()` : sélectionne les bannières `active` dont la date actuelle est dans `[startDate, endDate]`, triées par `position`,
- `getById(id)`,
- `create(BannerRequest)` : set `createdAt`,
- `update(id, BannerRequest)`,
- `delete(id)`.

**Controller `BannerController`** (`/api/banners`) :
- `GET /api/banners/active` : **utilisé par l’app étudiant** pour le carousel de bannières.
- `GET /api/banners` : liste complète (admin).
- `GET /api/banners/{id}`,
- `POST /api/banners`,
- `PUT /api/banners/{id}`,
- `DELETE /api/banners/{id}`.

#### 1.5.3. Types de contenus (pubs / bannières) et règles de clic

Aucune pub ni bannière ne doit être « dans le vide » : chaque contenu est lié soit à un commerce réel et ses offres, soit à une fonctionnalité interne (abonnement, Explorer, événements, profil).

**Quatre types de contenus (tous cliquables) :**

1. **Bannières éditoriales internes**  
   - **But** : pousser les messages Campus Pass (abonnement, fonctionnalités, événements).  
   - **Emplacements** : haut de l’accueil, haut d’Explorer.  
   - **Clic** → toujours vers une partie interne : écran Abonnement, Explorer avec filtre, écran Événement/Partenariat, Profil/Économies.

2. **Pubs « commerce sponsorisé » (hero)**  
   - **But** : visibilité payante pour un commerce.  
   - **Emplacements** : milieu de l’accueil (« offre du moment »), carte spéciale dans Explorer.  
   - **Clic** → page détail du commerce (logo, photos, horaires, offres) ou détail d’une offre précise.  
   - **Pré-requis** : commerce existant en base avec au moins une offre active.

3. **Pubs d’offres spécifiques**  
   - **But** : pousser une offre précise (ex. « Menu étudiant -40 % chez KFC »).  
   - **Emplacements** : liste d’offres (carte sponsorisée), notifications sponsorisées.  
   - **Clic** → page détail de cette offre (conditions, QR code, commerce).  
   - **Pré-requis** : offre existante en base, liée à un commerce.

4. **Notifications sponsorisées / messages ciblés**  
   - **But** : ramener l’utilisateur vers une offre, un commerce ou une section interne.  
   - **Emplacements** : onglet Notifications, éventuellement push.  
   - **Clic** → offre, commerce, ou page interne (abonnement, nouvelle fonctionnalité).

**Règles de base pour les clics :**  
- Bannière éditoriale → page interne (Abonnement, Explorer filtré, Événement, Profil/Économies).  
- Pub commerce → détail commerce existant.  
- Pub offre → détail offre existante.  
- Notification sponsorisée → même logique : jamais vers un écran vide.

**Pré-requis pour publier une campagne** : commerce validé, au moins une offre ACTIVE, destination claire dans l’app.

### 1.6. Panneau admin côté backend (`AdminController`)

En plus des endpoints exposés ci-dessus, `AdminController` centralise :
- Stats globales (`/api/admin/dashboard` + `/charts`),
- Gestion utilisateurs (liste, détail, statut),
- Liste étudiants enrichie,
- Gestion admins (CRUD + niveaux d’admin),
- Gestion reviews,
- Validation offres/commerces,
- Logs système.

---

## 2. Admin Angular – `admin_app`

### 2.1. Techno et thème

- **Angular standalone components** (>= v17),
- **Routing** moderne (`app.routes.ts`),
- Auth JWT (interceptor + guard),
- Styles :
  - `--primary` bleu, `--secondary` vert,
  - `--background` gris clair,
  - `--card` blanc,
  - `--danger`, `--warning`, etc.
- Layout :
  - Sidebar à gauche, header en haut, contenu central.

### 2.2. Auth admin et rôles

`core/auth.service.ts` :
- `login(email, password)` → `POST /auth/admin/login`, stocke `admin_token` + `admin_user` (JSON) dans `localStorage`.
- `logout()` → clear token + user, redirige `/admin/login`.
- `getCurrentUser()`, `isAuthenticated()`, `hasRole()`, `getAdminLevel()`, `hasAdminLevel()`.

Guards :
- `authGuard` : protège toutes les routes `/admin/**` (sauf `/admin/login`).
- `adminLevelGuard(['SUPER_ADMIN'])` : limite l’accès à certaines pages (ex : Admins, Logs).

Niveaux d’admin (dérivés du backend) :
- `SUPER_ADMIN` : peut gérer les autres admins, voir les logs, etc.
- Autres niveaux : OPERATIONS, SUPPORT (déjà prévus dans la spec, partiellement utilisés).

### 2.3. Routes et menu

`app.routes.ts` :
- `/admin/login` → `LoginPageComponent`.
- `/admin` → `AdminLayoutComponent` (protégé par `authGuard`), avec enfants :
  - `/dashboard` → `DashboardPageComponent`,
  - `/users` → `UsersPageComponent`,
  - `/users/:id` → `UserProfilePageComponent`,
  - `/students` → `StudentsPageComponent`,
  - `/merchants` → `MerchantsPageComponent`,
  - `/merchants/create` → `MerchantCreatePageComponent`,
  - `/merchants/:id` → `MerchantDetailPageComponent`,
  - `/offers` + `/offers/create` + `/offers/edit/:id`,
  - `/coupons`, `/transactions`, `/payments`,
  - `/advertisements` → gestion **publicités**,
  - `/banners` → gestion **bannières** (ajouté),
  - `/categories`, `/reviews`, `/notifications`, `/analytics`,
  - `/admins` (protégé par `adminLevelGuard(['SUPER_ADMIN'])`),
  - `/settings`,
  - `/logs` (protégé SUPER_ADMIN).

Sidebar (`admin-layout.component.html`) :
- Dashboard, Utilisateurs, Étudiants, Commerces, Offres, Coupons, Transactions, Paiements,
  **Publicités**, **Bannières**, Catégories, Avis, Notifications, Statistiques, Admins (si SUPER_ADMIN), Paramètres, Logs (si SUPER_ADMIN).

### 2.4. Gestion des publicités (`AdvertisementsPage`)

Service `AdvertisementsService` :
- Types :
  - `AdPosition = 'HOME_BANNER' | 'HOME_TOP' | 'SPONSORED_OFFER' | 'OFFERS_PAGE' | 'SEARCH_PAGE' | 'NOTIFICATION'`,
  - `Advertisement`, `AdvertisementRequest` alignés sur le backend (title, description, imageUrl, targetUrl, position, startDate, endDate, budget, offerId, status, createdAt).
- Méthodes :
  - `getAll({ position?, merchantId? })` → `GET /advertisements`,
  - `getById(id)`,
  - `create(req)`,
  - `update(id, req)`,
  - `delete(id)`.

Page `AdvertisementsPageComponent` :
- Liste des campagnes (table) + bouton **Créer publicité**.
- Formulaire : commerce, titre, description, imageUrl, `position`, `targetUrl`, dates, budget, offre liée.
- Appelle le backend qui alimente directement l’app étudiant.

### 2.5. Gestion des bannières (`BannersPage` – ajouté)

Service `BannersService` :
- Types :
  - `Banner` (id, title, description, imageUrl, type, linkUrl, startDate, endDate, position, active, createdAt),
  - `BannerRequest` (mêmes champs sans id).
- Méthodes :
  - `getAll()` → `GET /banners`,
  - `create(req)` → `POST /banners`,
  - `update(id, req)` → `PUT /banners/{id}`,
  - `delete(id)` → `DELETE /banners/{id}`.

Page `BannersPageComponent` (`/admin/banners`) :
- Liste des bannières :
  - colonnes : `#`, Titre, Type, Position, Dates, Active.
- Formulaire (modal) :
  - Titre (obligatoire),
  - Description,
  - URL image,
  - Type (`SUBSCRIPTION`, `SPONSORED`, `EVENT`, `GENERIC`),
  - Lien interne (`/subscription`, `/explore`, etc.),
  - Dates début/fin,
  - Position (ordre),
  - Active (checkbox).
- Actions :
  - Créer, Modifier, Supprimer.

Ainsi, **l’admin contrôle entièrement les bannières éditoriales** que voit l’étudiant.

### 2.6. Autres pages admin (vue d’ensemble)

- **Dashboard** : stats globales + graphiques (via `DashboardService`).
- **Users / Students / Merchants** : gestion utilisateurs/étudiants/commerces (listes + détails).
- **Offers** : liste + création/édition d’offres (aligné backend).
- **Coupons / Transactions / Payments** : vue back-office sur tous les flux.
- **Reviews** : modération des avis.
- **Notifications** : préparation des notifications (potentiellement push / in-app).
- **Analytics** : graphiques avancés (croissance, utilisation, revenus).
- **Admins / Settings / Logs** : gestion fine de la plateforme (sécurité, paramètres, journalisation).

---

## 3. Application Étudiant Flutter – `campuspass_app`

### 3.1. Thème et couleurs

`core/theme/app_colors.dart` :
- **Primaire** : bleu (identité Campus Pass),
- **Secondaire** : vert (réductions, succès),
- **Background** : gris très clair,
- **Card** : blanc,
- **Text / TextMuted**,
- **Success / Warning / Danger**.

`main.dart` :
- `MaterialApp.router` avec :
  - `ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, secondary: AppColors.secondary)`,
  - `useMaterial3: true`.

### 3.2. Navigation globale

`app_router.dart` :
- `'/splash'` → SplashScreen,
- `'/onboarding'` → OnboardingScreen,
- `'/login'` → LoginScreen,
- `'/register'` → RegisterScreen,
- `'/subscription'` → SubscriptionScreen,
- `'/payment-otp'` → PaymentOtpScreen,
- `'/offer-detail'` → OfferDetailScreen (avec `Offer` passé en `extra`),
- `'/offer-qr'` → OfferQrScreen,
- `'/merchant-detail'` → MerchantDetailScreen,
- `'/'` → MainShell.

Redirect :
- Si non connecté et route protégée → `/login`,
- Si connecté et route type `/login`, `/register`, `/onboarding` → `/`.

### 3.3. Auth & API client

`services/auth_service.dart` :
- Gère la session étudiant (`token`, `userId`, `firstName`, `lastName`, `email`, `role`) via `SharedPreferences`.
- `init()` → recharge la session et applique le token à `ApiClient`.
- `register(...)` → `POST /auth/register` avec `role: STUDENT` + `university`, `phoneNumber`.
- `login(...)` → `POST /auth/login`, vérifie `role == 'STUDENT'`.
- `logout()` → clear session et token.

`services/api_client.dart` :
- Singleton `ApiClient` autour de `Dio` :
  - `baseUrl = kApiBaseUrl`,
  - timeouts,
  - Interceptor qui ajoute `Authorization: Bearer <token>` si dispo.

### 3.4. Shell principal et onglets

`screens/main_shell.dart` :
- `NavigationBar` (Material 3) avec **5 onglets** :
  1. **Accueil** (`HomeScreen`),
  2. **Explorer** (`ExploreScreen`),
  3. **Mes économies** (`SavingsScreen`),
  4. **Notifications** (`NotificationsScreen`),
  5. **Profil** (`ProfileScreen`).
- `IndexedStack` pour conserver l’état de chaque onglet.

### 3.5. Pages et fonctionnalités

#### 3.5.1. Splash & Onboarding

- Splash :
  - Logo simple, loader,
  - Appelle `ApiClient.init()` + `AuthService.init()` puis route selon l’état de connexion.
- Onboarding :
  - Plusieurs écrans marketing (à simple page pour l’instant),
  - Boutons vers Login / Register.

#### 3.5.2. Auth (Login / Register)

- Login :
  - Email, mot de passe,
  - Validation basique,
  - Appel `AuthService.login` → en cas de succès, `/`.
- Register :
  - Prénom, Nom, Email, Mot de passe,
  - Téléphone (optionnel), Université (optionnel),
  - Appel `AuthService.register`.

#### 3.5.3. Accueil – `HomeScreen`

Sections principales :
- Header : ville + bouton notifications + avatar initiale de l’étudiant.
- Titre : `Bonjour, {Prénom}`.
- **Carousel de publicités sponsorisées** (`_HomeAdsCarousel`) :
  - Consomme `AdsService.getActiveAds(position: 'HOME_BANNER')`,
  - Affiche chaque `Advertisement` dans `_SponsoredAdCard`,
  - Badge “Sponsorisé”, titre, description, joli gradient,
  - Tap → `_onAdTap(ad)` :
    - lit `ad.targetUrl` : `/subscription`, `/explore`, etc.
- Section “Offres près de vous” :
  - Charge les offres proches via `OffersService.getNearbyOffers` (avec `LocationService`),
  - Cartes horizontales `_SmallOfferCard` (image, titre, prix promo, date de fin),
  - Tap → `'/offer-detail'` avec l’offre en `extra`.
- **Publicité sponsorisée milieu de page** :
  - `_middleAds` ← `AdsService.getActiveAds(position: 'SPONSORED_OFFER')`,
  - affichée juste après la section “Offres près de vous”.
- Section “Commerces populaires” :
  - `_popularMerchants` via `MerchantsService.getAll()`,
  - `_MerchantChip` : logo, nom, ville, statut (Ouvert/Fermé).

#### 3.5.4. Explorer – `ExploreScreen`

- AppBar “Explorer”.
- Données :
  - Offres : via `OffersService` (proches ou actives selon GPS),
  - Bannières éditoriales : via `BannersService.getActiveBanners()` (`GET /banners/active`),
  - Publicités : via `AdsService.getActiveAds(position: 'OFFERS_PAGE')`.
- UI :
  - Champ de recherche + chips de distance (`_DistanceChip` : <1km, <3km, <5km) qui relancent le chargement des offres avec nouveau `radiusKm`.
  - **Carousel de bannières** (`_BannerCarousel`) :
    - prend la liste de `BannerModel`,
    - défile toutes les 4s,
    - design 16:9, gradient, icône selon `type` (`SUBSCRIPTION`, `SPONSORED`, `EVENT`).
  - Liste des offres filtrées (`visibleOffers`) :
    - Carte `_OfferCard` : grande image + overlay dégradé + badge de réduction + prix + date de validité.
  - **Publicité sponsorisée dans la liste** :
    - `_ads` (position `OFFERS_PAGE`) insérée après 3 offres via `_ExploreSponsoredAdCard`,
    - Carte avec badge Sponsorisé et texte,
    - Tap → utilise `ad.targetUrl` pour éventuellement renvoyer vers `/subscription`.

#### 3.5.5. Mes économies – `SavingsScreen`

- Consomme `GET /student/savings`,
- Affiche :
  - total économisé,
  - nombre d’offres utilisées,
  - nombre de commerces visités,
  - texte d’explication pour l’historique (prêt à accueillir la liste détaillée).

#### 3.5.6. Notifications – `NotificationsScreen`

- Charge `AdsService.getActiveAds(position: 'NOTIFICATION')`,
- Affiche chaque `Advertisement` sous forme de carte :
  - Icône campagne,
  - Titre,
  - Badge “Sponsorisé”,
  - Description éventuelle.
- Tap :
  - lit `ad.targetUrl`,
  - redirige vers `/subscription` ou `/explore` selon la valeur.

#### 3.5.7. Profil – `ProfileScreen`

- Affiche les infos de l’étudiant à partir d’`AuthService`,
- Accès vers abonnement, paiements, économies, support (selon spec),
- Bouton “Déconnexion” → `AuthService.logout()` + redirection login.

#### 3.5.8. Détails offres & QR

- `OfferDetailScreen` :
  - Affiche détails complets d’une `Offer` (image, titre, description, prix, dates, conditions),
  - Bouton pour générer ou afficher un QR (en fonction de l’abonnement et de la logique backend).
- `OfferQrScreen` :
  - Affiche un QR code que le commerçant scanne côté app commerce.

### 3.6. Workflows côté étudiant

1. **Inscription** → `POST /auth/register` (role STUDENT + university) → login auto ou manuel.
2. **Connexion** → token stocké → accès aux onglets.
3. **Exploration offres** :
   - Home / Explore consomment `GET /offers` / `/offers/nearby`,
   - Détail offre → possibilité d’utiliser plus tard.
4. **Abonnement** :
   - Depuis Home ou Profil → `/subscription`,
   - Choix du plan (avec promo éventuelle),
   - Paiement (mobile money mock) → OTP `"1234"` → abonnement actif.
5. **Utilisation d’une offre** :
   - Détail offre → affichage QR → scan par l’app commerce → backend enregistre `Transaction` + `Coupon`,
   - Statistiques mises à jour (économies, points, etc.).

---

## 4. Application Commerce Flutter – `commerce_app`

### 4.1. Thème et structure

- Thème similaire à l’app étudiant (`AppColors`),
- `main.dart` :
  - appelle `ApiClient.instance.init()`,
  - `runApp(App())` avec `MaterialApp` (router ou routes classiques, selon implémentation actuelle).

### 4.2. Auth commerçant

`services/auth_service.dart` (commerce_app) :
- Login via `/auth/login`,
- Vérifie le rôle `MERCHANT`,
- Conserve :
  - token JWT,
  - `merchantId`,
  - autres infos nécessaires au dashboard.

### 4.3. Navigation (shell marchand)

Shell principal (`MainShell` – structure décrite dans PROJECT_OVERVIEW) :
- Onglets (NavigationBar) :
  1. **Dashboard** (`DashboardScreen`) : stats et raccourcis.
  2. **Scanner** (`ScannerScreen`) : scan QR pour valider coupons.
  3. **Offres** (`OffersScreen`) : gestion des offres.
  4. **Transactions** (`TransactionsScreen`) : historique des transactions app.
  5. **Profil** (`ProfileScreen` / `MerchantProfileScreen`) : infos compte + logout.
- `IndexedStack` pour garder l’état.

Si aucun commerce associé (`AuthService.instance.merchantId == null`) :
- l’app affiche un message expliquant qu’aucun commerce n’est lié,
- propose généralement de se déconnecter ou de contacter le support.

### 4.4. Pages principales

#### 4.4.1. DashboardScreen

- Données :
  - `OfferService.getByMerchantId(merchantId)`,
  - `MerchantService.getStatsByMerchantId(merchantId)`.
- UI :
  - Cartes de stats : coupons du jour, revenu du jour, offres actives, total offres, ventes totales, réductions totales, clients uniques, top offre.
  - Section “Raccourcis” :
    - “Scanner un coupon”,
    - “Créer une offre”.
  - Pull-to-refresh pour recharger stats et offres.

#### 4.4.2. OffersScreen (gestion offres)

- Filtres : `active`, `scheduled`, `expired`, `history` (gérés via le backend).
- Liste d’offres :
  - Image, titre, réduction, dates, statut,
  - Bouton “Modifier” (ouvre formulaire existant),
  - Bouton “Supprimer” (avec confirmation puis `DELETE /offers/{id}`).
- Affichage lisible des statuts avec code couleur (succès / warning / danger).

#### 4.4.3. ScannerScreen

- Interface pour scanner les QR codes des étudiants,
- Appel backend pour valider le coupon et créer la `Transaction`,
- Affichage du résultat (succès / erreur).

#### 4.4.4. TransactionsScreen

- Liste des transactions du commerce :
  - montants, réductions, dates, statuts,
  - utile pour suivre l’activité générée par Campus Pass.

#### 4.4.5. MerchantProfileScreen

`screens/merchant_profile_screen.dart` :
- Charge les infos du commerce via `MerchantService.getById(merchantId)`,
- Formulaire pour :
  - Adresse, Ville, Pays,
  - Latitude, Longitude,
  - Horaires d’ouverture (`openingHours`),
- Bouton “Enregistrer” :
  - construit un body avec les champs remplis,
  - appelle `MerchantService.update(id, {...})`,
  - met à jour `_merchant` et affiche un message (“Enregistrement réussi” ou erreur).

### 4.5. Workflows côté commerce

1. **Connexion commerçant** → `/auth/login` (MERCHANT), token + merchantId stockés.
2. **Consultation Dashboard** : voit stats quotidiennes et cumulées.
3. **Création d’offre** :
   - via app commerce ou via admin,
   - offres créées par commerçant → `PENDING` jusqu’à validation admin (selon règles).
4. **Scan coupon** :
   - Étudiant montre son QR,
   - Commerçant scanne,
   - Backend marque coupon comme `USED`, crée transaction, met à jour stats.
5. **Suivi** :
   - Transactions et stats consultables à tout moment,
   - Profil commerce maintenu à jour (adresse, horaires, géolocalisation).

---

## 5. Synthèse générale

- **Backend** : Spring Boot unifié pour tous (`/api/...`), gère utilisateurs, offres, coupons, abonnements, stats, pubs, bannières.
- **Admin Angular** : console complète pour piloter :
  - utilisateurs, étudiants, commerces,
  - offres, coupons, transactions, paiements,
  - **publicités sponsorisées** (modèle économique),
  - **bannières éditoriales** (contenu marketing interne),
  - catégories, avis, notifications, analytics, admins, paramètres, logs.
- **App Étudiant Flutter** :
  - onboarding, auth, abonnement,
  - navigation 5 onglets,
  - offres, économies, notifications, profil,
  - intégration fine des publicités/bannières administrées depuis l’admin.
- **App Commerce Flutter** :
  - auth commerçant,
  - dashboard temps réel,
  - gestion d’offres,
  - scan de coupons,
  - suivi des transactions,
  - profil commerce.

L’ensemble forme un écosystème cohérent où :
- les **bannières** et **publicités** sont créées/paramétrées côté admin, stockées dans le backend,
  puis affichées automatiquement dans l’app étudiant aux bons emplacements,
- les **commerces** créent des offres et voient leur performance,
- les **étudiants** s’abonnent, consomment les offres et voient leurs économies,
- l’**admin** contrôle la qualité, les flux financiers et le modèle économique (pubs + abonnements).

---

## 6. État actuel – ce qui est fait / reste à faire

### 6.1. Backend – État

✅ **Déjà implémenté et utilisé par au moins une app** :
- Authentification + rôles (`User`, JWT, `AuthController`, `SecurityConfig`).
- Étudiants : `StudentProfile`, `StudentSubscription`, `SubscriptionPlan`, `SubscriptionPayment`, `StudentController` (`/student/me`, `/student/savings`).  
  → consommé par l’app étudiant (profil, économies, abonnement).
- Commerces : `Merchant`, `MerchantController` (`/merchants`, `/stats`, `/transactions`).  
  → utilisé par l’app commerce (dashboard, profil commerce) et par l’admin (liste/commerces).
- Offres : `Offer`, `OfferController` (`/offers` …).  
  → utilisé par app étudiant (offres actives) et app commerce (gestion offres), admin (validation).
- Coupons, Transactions, Reviews, Notifications : modèles + services + controllers de base existants et branchés à l’admin / app commerce (scan, modération).  
  (Utilisation côté étudiant encore partielle pour certains flux avancés).
- Admin : `AdminController` (stats dashboard, gestion utilisateurs/étudiants, transactions, paiements, plans, admins, logs, reviews…).  
  → déjà consommé par `admin_app` (Dashboard, Users, Students, Merchants, Offers, Coupons, Transactions, Payments, Reviews, Analytics, Admins, Logs, Settings).
- Publicités : `Advertisement`, `AdPosition`, `AdvertisementRepository`, `AdvertisementService`, `AdvertisementController` (`/api/advertisements`).  
  → pleinement utilisé par **admin_app** (CRUD pubs) et **campuspass_app** (pubs sur Home, Explorer, Notifications).
- Bannières : **ajout complet** (`Banner`, `BannerRepository`, `BannerService`, `BannerController` avec `/api/banners` + `/api/banners/active`).  
  → utilisé par **campuspass_app** (carousel de bannières) et désormais gérable via **admin_app**.

🕗 **Implémenté côté backend mais peu ou pas exploité côté front (à enrichir plus tard)** :
- Historique détaillé des économies (transactions côté étudiant) : actuellement résumé dans `SavingsScreen`, mais pas encore affiché en liste détaillée.
- Certaines actions admin fines : changement de statut d’offres/commerces, validations avancées, logs système complets.

### 6.2. Admin Angular – État

✅ **Pages et services déjà présents et branchés au backend** :
- Auth admin (login, logout, garde de routes, niveaux SUPER_ADMIN).  
- Layout complet (sidebar + header + routing).
- Pages : Dashboard, Users, Students (à enrichir mais présente), Merchants (+ détail + création), Offers (+ create/edit), Coupons, Transactions, Payments.
- Publicités (`/admin/advertisements`) :  
  - Liste, création, modification, suppression,
  - Choix position (`AdPosition`) et `targetUrl`,
  - Appels à `AdvertisementController`.
- **Bannières (`/admin/banners`)** :  
  - Page ajoutée avec liste + formulaire,  
  - Service `BannersService` (CRUD complet sur `/api/banners`),  
  - Permet de créer/modifier/supprimer/activer les bannières éditoriales consommées par l’app étudiant.
- Catégories, Reviews, Notifications, Analytics, Admins, Settings, Logs : pages existantes avec UI de base et appels principaux déjà structurés (certains comportements avancés restent à raffiner).

🕗 **Reste à faire côté admin (améliorations possibles)** :
- Étudiants (`/admin/students`) : enrichir la table (filtres par université, ville, statut, actions de validation carte étudiant).
- Admins (`/admin/admins`) : vérifier/compléter toutes les actions (création d’admin, modification de rôle, désactivation/réactivation) selon les besoins restants.
- Notifications (`/admin/notifications`) : relier complètement le formulaire aux mécanismes de notification (push / in-app) si prévu côté backend.
- Analytics (`/admin/analytics`) : ajouter ou améliorer les graphiques avec les données fournies par `/admin/dashboard/charts`.

### 6.3. App Étudiant Flutter – État

✅ **Déjà en place et fonctionnel** :
- Thème moderne (Material 3) + couleurs cohérentes.
- Auth (register/login/logout) + persistence token + redirections automatiques via `GoRouter`.
- Navigation à 5 onglets via `MainShell` :
  - Accueil,
  - Explorer,
  - Mes économies,
  - Notifications,
  - Profil.
- Accueil :
  - Chargement des offres proches + commerces populaires,
  - Carousel de pubs sponsorisées (`HOME_BANNER`) + bloc sponsorisé milieu de page (`SPONSORED_OFFER`) → données admin.
- Explorer :
  - Recherche + filtres distance,
  - Chargement des offres (proches/actives),
  - Carousel de bannières éditoriales (via `/banners/active`) → données admin,
  - Pub sponsorisée dans la liste (position `OFFERS_PAGE`) → données admin.
- Mes économies :
  - Intégré à `/student/savings` (total, nombre d’offres/commerces), présentation déjà UX friendly.
- Notifications :
  - Affiche les publicités `NOTIFICATION` en mode “notifications sponsorisées” cliquables (vers `/subscription`, `/explore`, etc.).
- Profil :
  - Affiche les infos utilisateur via `AuthService` (et potentiellement `/student/me`),
  - Gère la déconnexion.
- Abonnement :
  - Écrans subscription + OTP alignés sur les endpoints backend (`/plans`, `/subscription/subscribe`, `/subscription/confirm-otp`).

🕗 **Reste à faire / améliorations possibles côté étudiant** :
- Historique détaillé d’économies (afficher la liste des transactions avec montants économisés, date, commerce, etc., en se branchant plus finement sur `/student/savings`).
- Écran `OfferDetailScreen` et `OfferQrScreen` : déjà présents, mais le workflow complet (génération coupon + affichage QR + statuts) peut encore être enrichi selon les règles d’abonnement (ex : interdire la génération si pas abonné).
- Notifications “non sponsorisées” (messages système) : à décider selon backend.

### 6.4. App Commerce Flutter – État

✅ **Fonctionnel aujourd’hui** :
- Auth commerçant (login MERCHANT + stockage token/merchantId).
- Shell à onglets : Dashboard, Scanner, Offres, Transactions, Profil.
- Dashboard :
  - Appels aux stats backend (`/merchants/{id}/stats`) + affichage des KPIs principaux.
- Offres :
  - Listes filtrées (actives, programmées, expirées, historique),
  - Création / modification / suppression d’offres,
  - Statuts et couleurs cohérents avec backend.
- Scanner :
  - Logique de scan QR reliée au backend pour valider des coupons (structure en place).
- Transactions :
  - Affichage des transactions issues de l’app (montants, réductions, dates, statuts).
- Profil commerce :
  - `MerchantProfileScreen` complet (adresse, ville, pays, latitude, longitude, horaires) + persistance via `MerchantService.update`.

🕗 **Reste à faire / améliorations côté commerce** :
- UI/UX avancée du scanner (feedback plus détaillé, historique des derniers scans).
- Affichage plus riche des transactions (filtres par date, export CSV si souhaité).
- Eventuels écrans de support / aide intégrés dans l’app commerçant.

### 6.5. Récap rapide “Fait / À faire”

- **Backend** :
  - Fait : quasi toute la logique métier (auth, rôles, offres, abonnements, stats, pubs, bannières).  
  - À faire : seulement des ajustements éventuels selon tes besoins futurs (nouveaux filtres, nouvelles métriques, règles métier spécifiques).

- **Admin (Angular)** :
  - Fait : structure + majorité des pages + gestion complète des pubs + bannières.  
  - À faire : enrichir certaines pages (Étudiants, Admins, Notifications, Analytics) en fonction des besoins projet/mémoire.

- **App Étudiant (Flutter)** :
  - Fait : navigation, auth, offres, bannières, pubs, économies, notifications sponsorisées, profil, logique d’abonnement.  
  - À faire : historique détaillé, UX avancée autour de l’usage des coupons/QR, refinements visuels.

- **App Commerce (Flutter)** :
  - Fait : navigation, auth, dashboard, gestion offres, profil, transactions, base du scanner.  
  - À faire : polish UX du scanner/transactions et éventuels écrans additionnels (support, stats avancées).

---

## 7. Workflows fonctionnels détaillés

Cette section décrit, côté **expérience utilisateur**, comment fonctionnent les bannières, les publicités et les abonnements étudiants. Elle doit rester cohérente avec l’implémentation technique décrite plus haut.

### 7.1. Workflow d’une bannière (promotion interne)

**Objectif** : mettre en avant une information importante **interne** à l’app (ex : promo abonnement étudiant, événement spécial, rentrée universitaire…).

- **Création** :  
  - L’admin crée une bannière dans `admin_app` → page **Bannières** (`/admin/banners`).  
  - Il renseigne : `title`, `description`, `imageUrl`, `type` (`SUBSCRIPTION`, `SPONSORED`, `EVENT`, `GENERIC`…), `linkUrl`, `startDate`, `endDate`, `position`, `active`.
- **Backend** :  
  - La bannière est stockée en base (`Banner`) et accessible via :  
    - `GET /api/banners/active` (app étudiant)  
    - `GET /api/banners` (admin).
- **Affichage dans l’app étudiant** :
  - Sur l’onglet **Accueil** et/ou **Explorer**, via le **carousel de bannières** (`_BannerCarousel` dans `ExploreScreen`, équivalent possible sur Home).  
  - Ratio 16:9, pleine largeur, avec titre + description, couleurs dépendantes du `type`.
- **Interaction** :
  - **Oui, c’est cliquable**.  
  - Au clic, l’app utilise `linkUrl` (par ex. `/subscription`, `/explore`…) pour naviguer :  
    - Bannière abonnement → `/subscription` (page abonnement étudiant).  
    - Bannière générique → route appropriée à définir (ex. `/explore` ou page événement).
- **Disparition automatique** :
  - La bannière disparaît quand :
    - la **date de fin** (`endDate`) est dépassée, ou
    - `active = false` (désactivée par l’admin).
  - Côté logique produit, on peut également choisir :  
    - si l’étudiant **est déjà abonné**, ne plus afficher la bannière d’abonnement et, à la place, afficher une information type :  
      > “Vous êtes abonné jusqu’au JJ/MM/AAAA”  
    (ce comportement est géré dans la logique de rendu Flutter en fonction du statut issu de `/student/me`). 

### 7.2. Workflow d’une publicité commerce (sponsorisée)

**Objectif** : permettre à un commerce de **payer** pour gagner en visibilité (source principale de revenus avec les abonnements).

- **Création** :
  - Aujourd’hui : via **admin_app** sur la page **Publicités** (`/admin/advertisements`) :
    - l’admin choisit le commerce (merchant),
    - définit `title`, `description`, `imageUrl`, `position` (`AdPosition`), `targetUrl`, dates, budget, offre liée (`offerId` éventuel).
  - Variante future (optionnelle) : depuis l’app **commerce_app**, un onglet “Publicité” permettrait au commerçant de proposer une campagne que l’admin validerait.
- **Backend** :
  - La pub est enregistrée en base (`Advertisement`) avec : `merchantId`, `position`, `startDate`, `endDate`, `budget`, `status` (`ACTIVE` ou non).  
  - Les endpoints `/api/advertisements` (GET avec `position`) renvoient uniquement les **pubs actives** (via `AdvertisementService.findByPosition()`).
- **Affichage dans l’app étudiant** :
  - **Accueil** :  
    - Carousel de pubs `HOME_BANNER` en haut de l’écran (Sponsorisé).  
    - Bloc sponsorisé `SPONSORED_OFFER` plus bas dans la page.
  - **Explorer** :  
    - Une pub `OFFERS_PAGE` est insérée au milieu de la liste (après quelques offres) via `_ExploreSponsoredAdCard`.
  - **Notifications** :  
    - Les pubs `NOTIFICATION` sont affichées comme **notifications sponsorisées** dans l’onglet Notifications.
- **Contenu visuel recommandé** :
  - Image (optionnelle mais conseillée),
  - Titre clair,
  - Réduction / avantage,
  - Nom du commerce, localisation (ou implicite via la page cible),
  - CTA implicite : en pratique, le clic ouvre la page concernée.
- **Interaction (clic)** :
  - Oui, **toutes les publicités sont cliquables**.  
  - L’app lit `targetUrl` pour décider de la navigation :
    - `/merchant/{id}` → page détail commerce (photos, offres, localisation, horaires),
    - `/offer/{id}` → page détail d’une offre en particulier (si prévu),
    - `/subscription` → page abonnement, etc.
- **Fin de campagne / disparition** :
  - Conformément au modèle métier, une publicité cesse d’être visible lorsque :
    - la **date de fin** est atteinte (`endDate`),
    - le **budget** est épuisé (logique possible côté backend/cron),
    - l’admin **désactive** la campagne (changement de `status`).

### 7.3. Limites d’affichage (pour une app lisible)

Pour éviter une expérience surchargée :
- **Accueil** :
  - 1 **carousel** de bannières/pubs en haut (`HOME_BANNER` ou bannières éditoriales),
  - 1 bloc de pub sponsorisée au milieu (`SPONSORED_OFFER`).
- **Explorer** :
  - 1 pub `OFFERS_PAGE` insérée toutes les X offres (actuellement une seule, après quelques cartes d’offres).
- **Notifications** :
  - Mélange de notifications système + notifications sponsorisées, avec un style visuel clair pour le badge “Sponsorisé”.

Ces limites sont gérées côté Flutter en contrôlant le nombre d’injections de pubs dans les listes.

### 7.4. Workflow abonnement étudiant

**Localisation dans l’UI** :
- Onglet **Profil** → entrée **Mon abonnement**,
- Bouton / bannière d’appel à l’action sur **Accueil** (bannière interne) ou via pub.

**Page “Mon abonnement” (vue cible)** :
- Statut : Actif / Inactif,
- Dates : début / fin,
- Plan : ex. “Étudiant annuel”,
- Bouton : “Gérer mon abonnement”,
- Section : **Historique paiements** (via `/subscription/payments`).  

**Workflow complet** :
1. L’étudiant voit une **bannière abonnement** sur l’accueil ou un bouton dans Profil.
2. Il clique → page **Abonnement** (liste des `SubscriptionPlan` depuis `/api/plans`).
3. Il choisit un plan :
   - prix affiché + éventuelle promo (prix barré → promo),
4. L’app appelle `/api/subscription/subscribe` (méthode + téléphone) :
   - le backend renvoie un `paymentId`, `amount`, `otpMock: "1234"`,
5. L’app ouvre l’écran **OTP** :
   - l’étudiant saisit le code,
   - l’app appelle `/api/subscription/confirm-otp` (avec `paymentId` + `otp`),
6. En cas de succès :
   - `StudentSubscription` est créée/activée,
   - les écrans **Profil** / **Mon abonnement** affichent :  
     > “Statut : Actif – Date fin : JJ/MM/AAAA”  
   - les bannières abonnement peuvent être masquées ou adaptées.

**Expiration** :
- Une fois la date de fin croisée, le backend marque l’abonnement comme **expiré**, et  
`/student/me` renvoie `hasActiveSubscription = false` → l’UI peut alors :
  - réafficher les bannières d’abonnement,
  - adapter les CTA (renouveler l’abonnement).

### 7.5. Footer et navigation bas de l’app étudiant

- **Barre de navigation fixe en bas** (pas un footer texte type site web) :  
  Accueil, Explorer, Économies, Notifications, Profil.  
  - Fond blanc ou très clair.  
  - Icônes + libellés courts (un mot).  
  - Onglet actif : couleur primaire (bleu Campus Pass).  
  - Onglet inactif : gris.

- **En bas de la page Explorer** :  
  - Une ligne discrète (texte gris) : *« Certaines offres sont soumises à conditions. Vérifie les détails avant utilisation. »*  
  - Lien cliquable vers une page **Conditions & FAQ** (réductions, remboursement/litiges, vérification des cartes étudiantes).

- **Depuis Profil / Paramètres** :  
  - Accès à une page **À propos / Légal** : mentions légales (éditeur, contacts), conditions générales d’utilisation, politique de confidentialité.

---

## 8. Accueil étudiant – description produit (sans code)

Écran très visuel, orienté action (inspiration Uber + Netflix + app de réduction).

1. **Header contextuel** : ville courante (ex. Ouagadougou) à gauche avec icône localisation ; au centre message « Bonjour, [Prénom] » ; à droite icône notifications (badge si non lues) + avatar (initiale ou photo).
2. **Bloc statut étudiant + abonnement** :  
   - Non vérifié → carte « Vérifie ton statut étudiant », bouton « Vérifier maintenant ».  
   - Vérifié non abonné → carte abonnement avec CTA « Voir les abonnements ».  
   - Abonné → carte « Abonnement actif » avec date fin, barre de progression, lien « Voir mes paiements » / « Renouveler ».
3. **Hero visuel – bannières éditoriales** : carrousel 16:9 (2–4 bannières), promo abonnement, thématiques, événements. Clic → Abonnement, Explorer filtré, ou page dédiée.
4. **Section « Offres près de toi »** : sous-texte « Découvre ce qui est à quelques minutes de marche » ; carrousel horizontal d’offres (image, badge réduction, nom offre, commerce, distance). Clic → détail offre.
5. **Bloc « Commerce sponsorisé »** : grande carte « offre du moment », badge « Sponsorisé », CTA → détail commerce ou offre.
6. **Section « Catégories populaires »** : chips (Fast-food, Cafés, Sport & Fitness, Beauté, Courses). Clic → Explorer pré-filtré.
7. **« Commerces près de chez toi »** : cartes horizontales (photo commerce, nom, lieu ville/quartier, horaires, statut Ouvert/Fermé). Clic → détail commerce.
8. **Zone « Mes économies rapides »** : résumé « Tu as économisé X FCFA ce mois-ci » + bouton « Voir mes économies » → onglet Économies.

---

## 9. Explorer étudiant – description produit (sans code)

Objectif : découvrir et filtrer (inspiration Uber Eats Explore + bons plans).

1. **Barre de recherche + filtres rapides** : champ « Rechercher une offre ou un commerce », chips distance (< 1 km, < 3 km, < 5 km), éventuellement catégorie.
2. **Carrousel de bannières éditoriales** : sous la recherche, bannières internes (semaine thématique, événements, nouveautés). Auto-scroll 3–5 s.
3. **Section « Pour toi » / « Tendance près de toi »** : liste verticale d’offres (image, badge réduction, titre, commerce, quartier, labels Nouveau/Populaire).
4. **Insertion de pub sponsorisée** : après X offres (ex. 3 ou 4), carte « Sponsorisé » cliquable vers commerce ou offre.
5. **Bloc « Explorer par quartier »** (optionnel v1) : grille ou carrousel de quartiers (Cissin, Tampouy, etc.), clic → Explorer filtré sur ce quartier.
6. **Footer discret** : texte gris « Les offres sont mises à jour en continu. Certaines conditions peuvent s’appliquer. » + lien vers Conditions & FAQ.

