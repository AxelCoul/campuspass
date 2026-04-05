# Build Android — Commerce App

## 1. Mode développeur (symlinks)

Si vous voyez :
```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

**À faire :**
1. Ouvrir les paramètres Windows : `Win + I` → **Mise à jour et sécurité** → **Pour les développeurs**
2. Activer **Mode développeur**
3. Redémarrer si demandé, puis relancer `flutter run`

---

## 2. Erreur SDK Platform 34 (ZLIB / corrompu)

Si l’installation de **Android SDK Platform 34** échoue avec une erreur du type « Unexpected end of ZLIB input stream », le téléchargement est souvent corrompu.

**Solution A — Le projet utilise maintenant le SDK 33**

Les fichiers `android/app/build.gradle.kts` et `android/build.gradle.kts` ont été modifiés pour utiliser **compileSdk 33** au lieu de 34. Relancez :

```bash
flutter clean
flutter pub get
flutter run
```

**Solution B — Réinstaller le SDK 34 (optionnel)**

Si vous voulez revenir au SDK 34 plus tard :
1. Ouvrir **Android Studio** → **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
2. Onglet **SDK Platforms** : décocher **Android 14.0 (API 34)**, appliquer
3. Recocher **Android 14.0 (API 34)**, appliquer pour retélécharger
4. Si ça échoue encore : supprimer le dossier `C:\Users\<Vous>\AppData\Local\Android\Sdk\platforms\android-34` s’il existe, puis réinstaller depuis le SDK Manager

---

## 3. Vérifier l’environnement

```bash
flutter doctor -v
```

Vérifier que **Android toolchain** et **Android Studio** sont OK.
