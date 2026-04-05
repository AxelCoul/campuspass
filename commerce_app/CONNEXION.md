# Connexion à l'app PASS CAMPUS Merchant

## 1. Backend allumé

L’app appelle l’API à l’adresse **`http://10.0.2.2:8081/api`** (émulateur) ou l’IP de ta machine si tu testes sur un téléphone. **Tout le projet utilise le port 8081** (backend + admin + app commerce).

- Démarre le backend Spring Boot : **port 8081**.
- Sans backend, la connexion et l’inscription échoueront.

---

## 2. Créer un compte commerçant (recommandé)

1. Sur l’écran de **connexion**, appuie sur **« Créer un compte »**.
2. Renseigne :
   - Prénom, Nom  
   - Email  
   - Mot de passe (6 caractères minimum)  
   - **Nom du commerce** (obligatoire)
3. Appuie sur **« Créer mon compte »**.
4. Tu es ensuite connecté automatiquement et redirigé vers le dashboard.

---

## 3. Se connecter avec un compte existant

Si tu as déjà un compte **commerçant** (rôle MERCHANT avec un commerce associé) :

1. Ouvre l’app → écran **Connexion**.
2. Saisis l’**email** et le **mot de passe** du compte.
3. Appuie sur **Connexion**.

Seuls les comptes avec le rôle **MERCHANT** et un commerce lié peuvent se connecter. Un compte étudiant ou admin ne fonctionnera pas ici.

---

## 4. Créer un compte via l’API (sans l’app)

Avec **curl** (backend sur localhost:8081) :

```bash
curl -X POST http://localhost:8081/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"firstName\":\"Jean\",\"lastName\":\"Dupont\",\"email\":\"commerçant@test.com\",\"password\":\"secret123\",\"role\":\"MERCHANT\",\"merchantName\":\"Ma boutique\"}"
```

Ensuite connecte-toi dans l’app avec **commerçant@test.com** / **secret123**.

---

## 5. En cas d’erreur

- **« Accès réservé aux comptes commerçants »** → le compte n’a pas le rôle MERCHANT (ou n’a pas de commerce). Crée un nouveau compte via « Créer un compte » avec un nom de commerce.
- **« Backend injoignable »** ou timeout → le serveur ne tourne pas ou n’est pas joignable (vérifier l’URL, **le port 8081**, le pare-feu).
- **« Email ou mot de passe incorrect »** → identifiants erronés ou compte inexistant.
