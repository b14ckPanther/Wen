# Wen Cloud Functions

This package will host the AI ingestion pipeline and other backend automation. For Milestone I.1 we scaffolded the queue and scheduler that will drive embeddings.

## Install & build

```bash
cd infra/functions
npm install
npm run build
```

## Firebase emulator

To run the functions emulator (after building):

```bash
npm run serve
```

To deploy only functions:

```bash
npm run deploy
```
