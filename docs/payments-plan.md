# Wen Payments Integration Plan (Milestone H)

## Goals
- Enable business owners to upgrade from the free plan to paid tiers.
- Support card payments in the MENA region via **Stripe** initially, with a fallback path for **Paymob**.
- Persist subscription state in Firestore and surface it in the mobile profile/dashboard.
- Keep the mobile client free of secret keys; use Cloud Functions + webhooks for secure processing.

## Recommended Architecture (Stripe-first)

### 1. Checkout creation
1. Mobile app calls a callable Cloud Function `createCheckoutSession`.
2. Function validates the authenticated user and desired plan, then creates a Stripe Checkout Session with:
   - `mode: 'subscription'` (for recurring plans) or `mode: 'payment'` (one-off upgrades).
   - `success_url` and `cancel_url` pointing to Hosting pages (e.g., `https://wen.dev/payments/success`).
   - Metadata containing the Wen `userId` and selected `plan`.
3. Function returns the session URL to the mobile app.
4. Mobile opens the URL in a Custom Tab/SFSafariViewController. (Later we can embed a web view or use Stripe’s native SDKs.)

### 2. Webhooks & Firestore updates
1. Deploy an HTTPS Cloud Function `stripeWebhook` listening to events `checkout.session.completed`, `invoice.payment_succeeded`, `customer.subscription.deleted`.
2. On `checkout.session.completed`:
   - Verify signature (`stripe.webhooks.constructEvent`).
   - Read metadata to map back to the user.
   - Update Firestore `users/{id}` doc: `{ plan: 'standard' | 'premium', status: 'active', subscriptionId: <stripe_sub_id>, updatedAt: serverTimestamp }`.
   - Optionally write to `transactions/{id}` with amount, plan, status, timestamps.
3. On subscription renewal or cancellation events, sync Firestore accordingly (`status: 'past_due', 'canceled'`, etc.).
4. Publish notifications (FCM or email) when plan state changes.

### 3. Security & rules
- Only Cloud Functions should update plan/status fields; Firestore rules currently prevent clients from changing plan without admin/owner context.
- Ensure callable function checks the user’s Firebase Auth UID and only allows self-upgrades.
- Store Stripe secret keys/config in Functions environment variables (`firebase functions:config:set stripe.secret=...`).

### 4. Client considerations
- Add `Upgrade plan` CTA (done in Milestone F) that launches a bottom sheet listing tiers.
- When Stripe session is returned, open the Checkout URL. After redirect success, show confirmation view.
- Poll user doc or listen for change to show new plan status.

## Paymob fallback notes
- Paymob supports regional wallets/cards. Flow is similar: mobile requests payment key via Cloud Function → open hosted payment page → handle callback via webhook and update Firestore.
- Keep abstraction at Cloud Function layer so client code reuses the same `createPaymentSession` call regardless of provider.

## Data model updates
- Extend `transactions/{id}` with fields: `provider` (`stripe|paymob`), `plan`, `status`, `sessionId|paymentId`, `amount`, `currency`, `createdAt`, `updatedAt`.
- Add `users/{id}.subscription`: `{ plan, status, provider, subscriptionId, currentPeriodEnd }`.
- Consider caching `plan` inside `businesses/{id}` for quick lookups (already present).

## Deployment checklist
1. Set Stripe keys in Functions config.
2. Deploy callable/webhook functions (`firebase deploy --only functions`).
3. Configure webhook endpoint in Stripe Dashboard pointing to `https://<cloud-function-url>/stripeWebhook`.
4. Ensure Hosting serves success/cancel pages (Next.js stub can host at `/payments/*`).
5. Update README with testing steps and fallback instructions.

## Future enhancements
- Support plan downgrades & refunds.
- Integrate with Paymob once requirements are concrete.
- Offer in-app portal to manage billing (Stripe Customer Portal link).
- Add analytics tracking for plan conversion.
