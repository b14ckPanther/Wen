import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { enqueueDocument } from "./ai/embeddingQueue";
import { syncEmbeddingsBatch } from "./ai/syncEmbeddings";
import { approveBusinessCallable } from "./admin/approveBusiness";
import { deleteUserCallable } from "./admin/deleteUser";

admin.initializeApp();

// Backend Events
export const onBusinessChange = functions.firestore
  .document("businesses/{businessId}")
  .onWrite(enqueueDocument);

export const scheduledSyncEmbeddings = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async () => {
    await syncEmbeddingsBatch();
  });

export const approveBusiness = approveBusinessCallable;
export const deleteUser = deleteUserCallable;

// ✅ Next.js SSR Hosting
import * as path from "path";
import next from "next";
import express from "express";

const server = express();
const nextApp = next({
  dev: false,
  conf: {
    distDir: path.join(process.cwd(), "../../hosting/web/.next"),
  },
});
const handle = nextApp.getRequestHandler();

nextApp.prepare().then(() => {
  server.all("*", (req, res) => handle(req, res));
});

export const nextjsServer = functions
  .region("us-central1")
  .https.onRequest(server);
