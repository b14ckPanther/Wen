import * as functions from 'firebase-functions';
import {enqueueDocument} from './ai/embeddingQueue';
import {syncEmbeddingsBatch} from './ai/syncEmbeddings';
import {approveBusinessCallable} from './admin/approveBusiness';

export const onBusinessChange = functions.firestore
    .document('businesses/{businessId}')
    .onWrite(enqueueDocument);

export const scheduledSyncEmbeddings = functions.pubsub
    .schedule('every 1 hours')
    .onRun(async () => {
      await syncEmbeddingsBatch();
    });

export const approveBusiness = approveBusinessCallable;
