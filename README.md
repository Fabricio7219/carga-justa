# Carga Justa

Sistema de distribuição automatizada de cargas para motoristas terceiros, com regras justas e registradas.

## Estrutura

```
app_motorista/   App Flutter do motorista (APK)
painel/          Painel web Flutter do programador
functions/       Cloud Functions com o distribuidor de cargas
docs/            Regras de negócio e decisões do projeto
```

## Tecnologia

- Flutter (app e painel web)
- Firebase: Authentication, Firestore, Cloud Functions, Hosting
- Google Maps API para cálculo de distância
