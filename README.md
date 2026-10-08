# Carga Justa

Sistema de distribuição automatizada de cargas para motoristas terceiros, com regras justas e registradas.

## Estrutura

```
app/              Projeto Flutter: APK do motorista e painel web do programador
firestore.rules   Regras de segurança do banco
docs/             Guias e decisões do projeto
```

Um único app atende os dois lados: o login decide se a pessoa vê a tela do motorista ou o painel do programador.

## Tecnologia

- Flutter (Android e web)
- Firebase: Authentication, Firestore, Cloud Functions, Hosting
- Google Maps API para cálculo de distância

## Primeiros passos

Veja [docs/configurar-firebase.md](docs/configurar-firebase.md).

## O que já funciona

- Login por e-mail e senha, com recuperação de senha
- Cadastro do motorista com CPF, celular e CNH validados
- Cadastro fica pendente até o programador aprovar
- Painel do programador para aprovar ou recusar cadastros
- CNH vencida bloqueia a solicitação de cargas
