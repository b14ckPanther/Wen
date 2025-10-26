'use client';

export const dynamic = 'force-dynamic';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';

import { collection, doc, getDocs, limit, orderBy, query, updateDoc, serverTimestamp } from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';

import { AdminShell } from '../../components/AdminShell';
import { useAuth } from '../../hooks/useAuth';
import { db, functions } from '../../lib/firebase';

interface BusinessRow {
  id: string;
  name: string;
  description: string;
  plan: string;
  approved: boolean;
}

interface UserRow {
  id: string;
  name: string;
  email: string;
  role: string;
}

function StatCard({
  label,
  value,
  trend,
  accent,
}: {
  label: string;
  value: string;
  trend: string;
  accent: string;
}) {
  return (
    <div className="flex flex-col gap-4 rounded-3xl border border-white/10 bg-white/5 px-6 py-5 transition hover:border-white/20 hover:bg-white/10">
      <span className="inline-flex h-11 w-11 items-center justify-center rounded-full bg-slate-900/40 text-lg">
        {accent}
      </span>
      <div className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">{label}</div>
      <div className="text-3xl font-semibold text-white">{value}</div>
      <p className="text-xs text-slate-300">{trend}</p>
    </div>
  );
}

function EmptyState({ col, message }: { col: number; message: string }) {
  return (
    <tr>
      <td colSpan={col} className="px-4 py-8 text-center text-sm text-slate-400">
        {message}
      </td>
    </tr>
  );
}

function StatusBadge({ approved }: { approved: boolean }) {
  return approved ? (
    <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-200">
      <span className="h-2 w-2 rounded-full bg-emerald-400" />Approved
    </span>
  ) : (
    <span className="inline-flex items-center gap-1 rounded-full bg-amber-400/10 px-3 py-1 text-xs font-medium text-amber-200">
      <span className="h-2 w-2 rounded-full bg-amber-400" />Pending review
    </span>
  );
}

export default function DashboardPage() {
  const { user, loading } = useAuth();
  const [businesses, setBusinesses] = useState<BusinessRow[]>([]);
  const [users, setUsers] = useState<UserRow[]>([]);
  const [fetching, setFetching] = useState(true);
  const [activeBusinessAction, setActiveBusinessAction] = useState<string | null>(null);
  const [activeRoleAction, setActiveRoleAction] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<string | null>(null);
  const [feedbackTone, setFeedbackTone] = useState<'success' | 'error'>('success');

  useEffect(() => {
    async function loadData() {
      try {
        const businessSnap = await getDocs(
          query(collection(db, 'businesses'), orderBy('updatedAt', 'desc'), limit(10))
        );
        const businessRows = businessSnap.docs.map((doc) => {
          const data = doc.data() as Record<string, unknown>;
          return {
            id: doc.id,
            name: (data.name as string) ?? 'Untitled listing',
            description: (data.description as string) ?? 'Description not provided.',
            plan: (data.plan as string) ?? 'free',
            approved: Boolean(data.approved),
          };
        });

        const userSnap = await getDocs(
          query(collection(db, 'users'), orderBy('updatedAt', 'desc'), limit(10))
        );
        const userRows = userSnap.docs
          .map((doc) => {
            const data = doc.data() as Record<string, unknown>;
            return {
              id: doc.id,
              name: (data.name as string) ?? '—',
              email: (data.email as string) ?? 'unknown@wen.app',
              role: (data.role as string) ?? 'user',
            };
          })
          .filter((user) => user.role !== 'admin');

        setBusinesses(businessRows);
        setUsers(userRows);
      } catch (error) {
        console.error('Failed to load admin dashboard data', error);
      } finally {
        setFetching(false);
      }
    }

    if (user) {
      loadData();
    }
  }, [user]);

  useEffect(() => {
    if (!feedback) return;
    const timeout = setTimeout(() => setFeedback(null), 4000);
    return () => clearTimeout(timeout);
  }, [feedback]);

  const pendingBusinesses = useMemo(() => businesses.filter((b) => !b.approved), [businesses]);
  const activeOwners = useMemo(() => users.filter((u) => u.role === 'owner').length, [users]);

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-900 text-slate-100">
        <span className="animate-pulse text-lg">Preparing admin dashboard…</span>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-900 text-slate-100">
        <span>Please sign in to view the dashboard.</span>
      </div>
    );
  }

  const approveBusiness = async (businessId: string) => {
    try {
      setActiveBusinessAction(businessId);
      const callable = httpsCallable(functions, 'approveBusiness');
      await callable({ businessId });
      setBusinesses((prev) =>
        prev.map((item) => (item.id === businessId ? { ...item, approved: true } : item))
      );
      setFeedback('Business approved successfully.');
      setFeedbackTone('success');
    } catch (error: any) {
      console.error('Failed to approve business', error);
      setFeedback(error?.message ?? 'Failed to approve business.');
      setFeedbackTone('error');
    } finally {
      setActiveBusinessAction(null);
    }
  };

  const updateUserRole = async (userId: string, role: string) => {
    try {
      setActiveRoleAction(userId);
      const userRef = doc(db, 'users', userId);
      await updateDoc(userRef, {
        role,
        updatedAt: serverTimestamp(),
      });
      setUsers((prev) => prev.map((item) => (item.id === userId ? { ...item, role } : item)));
      setFeedback('Role updated successfully.');
      setFeedbackTone('success');
    } catch (error: any) {
      console.error('Failed to update role', error);
      setFeedback(error?.message ?? 'Unable to update role.');
      setFeedbackTone('error');
    } finally {
      setActiveRoleAction(null);
    }
  };

  return (
    <AdminShell>
      {feedback ? (
        <div
          className={`rounded-2xl border px-4 py-3 text-sm shadow-lg md:max-w-lg ${
            feedbackTone === 'success'
              ? 'border-emerald-400/40 bg-emerald-500/10 text-emerald-100'
              : 'border-rose-400/40 bg-rose-500/10 text-rose-100'
          }`}
        >
          {feedback}
        </div>
      ) : null}
      <section className="relative overflow-hidden rounded-3xl border border-white/10 bg-gradient-to-br from-indigo-900 via-slate-900 to-slate-950 px-8 py-10 shadow-2xl">
        <div className="absolute -right-40 -top-40 h-72 w-72 rounded-full bg-indigo-500/30 blur-3xl" />
        <div className="absolute -bottom-24 -left-24 h-72 w-72 rounded-full bg-sky-500/25 blur-3xl" />

        <div className="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.28em] text-slate-300/70">
              Admin overview
            </p>
            <h1 className="mt-3 text-3xl font-semibold text-white lg:text-4xl">
              Welcome back, {user.displayName ?? 'Wen Team'}
            </h1>
            <p className="mt-3 max-w-2xl text-sm text-slate-300">
              Monitor new submissions, track owners, and keep premium listings curated.
            </p>
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3 lg:gap-6">
            <StatCard
              label="Businesses reviewed"
              value={businesses.length.toString()}
              trend="Latest 10 submissions"
              accent="📋"
            />
            <StatCard
              label="Pending approvals"
              value={pendingBusinesses.length.toString()}
              trend={pendingBusinesses.length ? 'Review queued listings' : 'All caught up!'}
              accent="🛡️"
            />
            <StatCard
              label="Active owners"
              value={activeOwners.toString()}
              trend="Owners with a live business"
              accent="🏪"
            />
          </div>
        </div>
      </section>

      <div className="grid gap-8 lg:grid-cols-[2fr,1fr]">
        <section className="rounded-3xl border border-white/10 bg-white/5 p-8 shadow-xl">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h2 className="text-xl font-semibold text-white">Latest submissions</h2>
              <p className="text-sm text-slate-300">Businesses ordered by most recent activity.</p>
            </div>
            <Link
              href="#"
              className="inline-flex items-center gap-2 rounded-full border border-slate-600/60 px-4 py-2 text-sm text-slate-200 transition hover:border-slate-300/80 hover:text-white"
            >
              View directory
            </Link>
          </div>

          <div className="mt-6 overflow-hidden rounded-2xl border border-white/10">
            <table className="min-w-full divide-y divide-white/10 text-left text-sm">
              <thead className="bg-white/5 text-slate-300">
                <tr>
                  <th className="px-4 py-3 font-medium">Business</th>
                  <th className="px-4 py-3 font-medium">Plan</th>
                  <th className="px-4 py-3 font-medium">Status</th>
                  <th className="px-4 py-3 text-right font-medium">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 bg-slate-900/10 text-slate-100">
                {fetching && businesses.length === 0 ? (
                  <EmptyState col={4} message="Syncing latest submissions…" />
                ) : businesses.length === 0 ? (
                  <EmptyState col={4} message="No businesses found yet." />
                ) : (
                  businesses.map((business) => (
                    <tr key={business.id} className="transition hover:bg-white/5">
                      <td className="px-4 py-4">
                        <div className="font-semibold text-white">{business.name}</div>
                        <div className="mt-1 line-clamp-2 max-w-xl text-xs text-slate-300">
                          {business.description}
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <span className="inline-flex rounded-full bg-sky-400/10 px-3 py-1 text-xs font-medium text-sky-200">
                          {business.plan}
                        </span>
                      </td>
                      <td className="px-4 py-4">
                        <StatusBadge approved={business.approved} />
                      </td>
                      <td className="px-4 py-4 text-right">
                        {business.approved ? (
                          <button className="inline-flex items-center gap-2 rounded-full border border-white/20 px-3 py-1 text-xs text-slate-400" disabled>
                            Approved
                          </button>
                        ) : (
                          <button
                            onClick={() => approveBusiness(business.id)}
                            disabled={activeBusinessAction === business.id}
                            className="inline-flex items-center gap-2 rounded-full border border-sky-500/40 px-3 py-1 text-xs text-sky-200 transition hover:border-sky-300 hover:text-sky-100 disabled:cursor-not-allowed disabled:border-slate-600/40 disabled:text-slate-400"
                          >
                            {activeBusinessAction === business.id ? 'Approving…' : 'Approve'}
                          </button>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>

        <section className="flex flex-col gap-6 rounded-3xl border border-white/10 bg-white/5 p-8 shadow-xl">
          <div>
            <h2 className="text-xl font-semibold text-white">Owner spotlight</h2>
            <p className="mt-1 text-sm text-slate-300">
              Latest team members. Promote verified owners to premium tiers.
            </p>
          </div>

          <div className="overflow-hidden rounded-2xl border border-white/10">
            <table className="min-w-full divide-y divide-white/10 text-left text-sm">
              <thead className="bg-white/5 text-slate-300">
                <tr>
                  <th className="px-4 py-3 font-medium">Name</th>
                  <th className="px-4 py-3 font-medium">Email</th>
                  <th className="px-4 py-3 font-medium">Role</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 bg-slate-900/10 text-slate-100">
                {fetching && users.length === 0 ? (
                  <EmptyState col={3} message="Fetching team members…" />
                ) : users.length === 0 ? (
                  <EmptyState col={3} message="No users yet." />
                ) : (
                  users.map((row) => (
                    <tr key={row.id} className="transition hover:bg-white/5">
                      <td className="px-4 py-4 font-semibold text-white">{row.name}</td>
                      <td className="px-4 py-4 text-xs text-slate-300">{row.email}</td>
                    <td className="px-4 py-4">
                      <select
                        className="rounded-full border border-white/20 bg-slate-900/40 px-3 py-1 text-xs text-slate-100 focus:border-sky-400 focus:outline-none"
                        value={row.role}
                        onChange={(event) => updateUserRole(row.id, event.target.value)}
                        disabled={activeRoleAction === row.id}
                      >
                        <option value="user">user</option>
                        <option value="owner">owner</option>
                        <option value="admin">admin</option>
                      </select>
                    </td>
                  </tr>
                ))
              )}
              </tbody>
            </table>
          </div>

          <Link
            href="#"
            className="inline-flex items-center justify-center rounded-full border border-slate-600/50 px-4 py-2 text-xs font-medium text-slate-200 transition hover:border-slate-300/80 hover:text-white"
          >
            Manage roles
          </Link>
        </section>
      </div>
    </AdminShell>
  );
}
