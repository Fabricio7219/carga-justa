# Ligar o app ao Firebase

Passo a passo feito uma vez só, no computador do Fabrício.
Todos os comandos rodam no terminal do VS Code.

## 1. Instalar os pacotes do Flutter

```
cd app
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add flutter_localizations --sdk=flutter
```

## 2. Instalar as ferramentas do Firebase

Precisa do Node.js instalado (nodejs.org, versão LTS).

```
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

O `firebase login` abre o navegador: entre com a mesma conta Google do console.

Se o terminal disser que o `flutterfire` não foi encontrado, feche e abra o
VS Code. Se continuar, adicione ao PATH do Windows a pasta
`%LOCALAPPDATA%\Pub\Cache\bin`.

## 3. Conectar o app ao projeto

Ainda dentro da pasta `app`:

```
flutterfire configure --project=carga-justa --platforms=android,web
```

Isso cria o arquivo `lib/firebase_options.dart` e o `android/app/google-services.json`.

## 4. Publicar as regras de segurança

1. Abra o arquivo `firestore.rules` (na raiz do repositório) e copie tudo.
2. No console do Firebase: **Firestore Database → Regras**.
3. Apague o que estiver lá, cole e clique em **Publicar**.

## 5. Rodar e testar

```
flutter test
flutter run -d chrome
```

## 6. Criar o primeiro programador

Ninguém consegue se cadastrar como programador pelo app (é proposital).
Para criar o primeiro:

1. No app, crie um cadastro de motorista com o seu e-mail.
2. No console: **Firestore Database → Dados → usuarios →** o seu documento.
3. Mude o campo `perfil` para `programador` e o `status` para `aprovado`.
4. Volte ao app: a tela muda sozinha para o painel do programador.

## 7. Enviar para o GitHub

```
cd ..
git add .
git commit -m "Liga o app ao Firebase"
git push
```
