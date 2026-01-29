# RAUST - Guia Completo de Setup e Build APK

## 📋 Pré-requisitos

Você precisa ter instalado:
- **Flutter SDK** (versão 3.0+): https://flutter.dev/docs/get-started/install
- **Android SDK** com API 21+ (via Android Studio)
- **Java Development Kit (JDK)** 11+
- **Git**

### Verificar instalação:
```bash
flutter --version
dart --version
java -version
```

---

## 🔧 Setup Inicial

### 1. Clonar o Projeto
```bash
cd ~/projects
git clone https://github.com/reinhardtmarta/raust.git
cd raust
```

### 2. Instalar Dependências Flutter
```bash
flutter pub get
```

### 3. Verificar Ambiente
```bash
flutter doctor
```

Se houver erros, siga as instruções do `flutter doctor` para resolvê-los.

---

## 🔐 Configurar Firebase

### 1. Criar Projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Criar projeto"
3. Nome: `raust-app`
4. Desabilite Google Analytics (opcional)

### 2. Adicionar App Android
1. No console Firebase, clique em "Adicionar app"
2. Selecione "Android"
3. Nome do pacote: `com.raust.app`
4. Deixe SHA-1 em branco por enquanto
5. Clique em "Registrar app"

### 3. Baixar google-services.json
1. Clique em "Baixar google-services.json"
2. Coloque o arquivo em: `android/app/google-services.json`

### 4. Ativar Firestore
1. No console Firebase, vá para "Firestore Database"
2. Clique em "Criar banco de dados"
3. Selecione "Modo de teste" (para desenvolvimento)
4. Selecione região: `southamerica-east1` (São Paulo)

### 5. Configurar Regras de Segurança
No Firestore, vá para "Regras" e substitua pelo código abaixo:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reports/{document=**} {
      allow read, write: if true;
    }
    match /tags/{document=**} {
      allow read, write: if true;
    }
    match /validations/{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🚀 Build e Deploy

### Opção 1: Build APK (Instalável)

#### Debug APK (para testes):
```bash
flutter build apk --debug
```
Arquivo gerado: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK (para produção):
```bash
flutter build apk --release
```
Arquivo gerado: `build/app/outputs/flutter-apk/app-release.apk`

### Opção 2: Build App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`

---

## 📱 Instalar no Dispositivo

### Via ADB (Android Debug Bridge):
```bash
# Conectar dispositivo via USB e ativar "Modo de Desenvolvedor"
flutter devices  # Verificar dispositivos conectados

# Instalar APK debug
flutter install

# Ou instalar APK release manualmente
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via Arquivo APK:
1. Transfira o arquivo `app-release.apk` para o dispositivo
2. Abra o gerenciador de arquivos
3. Toque no APK e selecione "Instalar"

---

## 🔑 Gerar SHA-1 para Firebase

Se precisar adicionar SHA-1 ao Firebase:

```bash
# Debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release (após criar keystore)
keytool -list -v -keystore ~/raust-keystore.jks
```

---

## 📦 Estrutura do Projeto

```
raust/
├── lib/
│   ├── main.dart              # Entrada da aplicação
│   ├── models/
│   │   └── report.dart        # Model de alertas
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── location_service.dart
│   │   └── weather_service.dart
│   └── screens/
│       ├── map_screen.dart
│       ├── report_screen.dart
│       └── tags_screen.dart
├── android/
│   ├── app/
│   │   ├── google-services.json  # ⚠️ ADICIONAR AQUI
│   │   └── build.gradle
│   └── build.gradle
├── pubspec.yaml               # Dependências
└── README.md
```

---

## 🐛 Troubleshooting

### Erro: "google-services.json não encontrado"
- Verifique se o arquivo está em `android/app/google-services.json`
- Execute: `flutter clean && flutter pub get`

### Erro: "Firestore não conecta"
- Verifique as regras de segurança do Firestore
- Confirme que o projeto Firebase está ativo

### Erro: "Permissões de localização"
- No Android 6+, as permissões são solicitadas em tempo de execução
- O app pede permissão ao abrir

### Erro: "Versão do SDK"
```bash
# Atualizar Flutter
flutter upgrade

# Atualizar dependências
flutter pub upgrade
```

---

## 📊 Funcionalidades MVP

✅ Mapa com OpenStreetMap
✅ Reports anônimos com GPS
✅ Validação comunitária
✅ Feed de tags
✅ Clima em tempo real
✅ Anonimato com UUID
✅ Firestore integrado

---

## 🎯 Próximas Etapas

1. **Publicar no Google Play Store**: Criar conta de desenvolvedor ($25 uma vez)
2. **Notificações Push**: Integrar Firebase Cloud Messaging (FCM)
3. **Modo Dirigindo**: Aumentar tamanho dos ícones e adicionar TTS
4. **Geocodificação**: Usar Google Maps API para endereços legíveis

---

## 📞 Suporte

Para dúvidas sobre Flutter: https://flutter.dev/docs
Para dúvidas sobre Firebase: https://firebase.google.com/docs

---

**Desenvolvido com ❤️ para a segurança comunitária no RS**
