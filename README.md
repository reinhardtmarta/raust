# RAUST - Radar User Safe Travel 🚗🌧️

O RAUST é um MVP de aplicativo Flutter focado em alertas comunitários anônimos para o Rio Grande do Sul (foco em Charqueadas/POA).

## 🚀 Funcionalidades MVP
- **Mapa em Tempo Real**: Visualização de alertas via OpenStreetMap.
- **Reports Anônimos**: Envie alertas de trânsito, enchente e perigos sem login.
- **Validação Comunitária**: Sistema de confirmação/negação de alertas com timer automático.
- **Feed de Tags**: Veja o que está acontecendo na região via tags dinâmicas.
- **Clima**: Integração com Open-Meteo para previsão de chuva local.

## 🛠️ Tecnologias
- **Flutter** (Frontend)
- **Firebase Firestore** (Banco de dados realtime)
- **OpenStreetMap** (Mapas)
- **Open-Meteo API** (Clima)

## 📋 Instruções de Setup Firebase

Para que o app funcione com o banco de dados, você precisa:

1.  Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
2.  Adicione um app **Android**:
    - Nome do pacote: `com.raust.app`
3.  Baixe o arquivo `google-services.json` e coloque em: `android/app/google-services.json`.
4.  No console do Firebase, ative o **Cloud Firestore** em modo de teste.
5.  Adicione as seguintes regras ao Firestore:
    ```
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /reports/{report} {
          allow read, write: if true; // Para MVP anônimo
        }
      }
    }
    ```

## 🏗️ Como Rodar

1.  Clone o projeto ou copie os arquivos.
2.  Instale as dependências:
    ```bash
    flutter pub get
    ```
3.  Execute o app:
    ```bash
    flutter run
    ```

## 📦 Build APK (Release)

Para gerar o instalador para Android:

```bash
flutter build apk --release
```
O arquivo será gerado em `build/app/outputs/flutter-apk/app-release.apk`.

---
*Desenvolvido como uma ferramenta de segurança comunitária para o RS.*
