'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';

import { AdminShell } from '../../components/AdminShell';
import { useAuth } from '../../hooks/useAuth';
import { db } from '../../lib/firebase';
import { collection, getDocs, orderBy, query, limit } from 'firebase/firestore';

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

export default function DashboardPage() {
  const { user, loading } = useAuth();
  const [businesses, setBusinesses] = useState<BusinessRow[]>([]);
  const [users, setUsers] = useState<UserRow[]>([]);
  const [fetching, setFetching] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const businessSnap = await getDocs(
          query(collection(db, 'businesses'), orderBy('updatedAt', 'desc'), limit(10))
        );
        setBusinesses(
          businessSnap.docs.map((doc) => {
            const data = doc.data() as Record<string, unknown>;
            const approvedFlag = data['approved'];
            return {
              id: doc.id,
              name: (data['name'] as string?) ?? 'Untitled',
              description: (data['description'] as string?) ?? '',
              plan: (data['plan'] as string?) ?? 'free',
              approved: typeof approvedFlag === 'boolean' ? approvedFlag : false,
            };
          })
        );

        const userSnap = await getDocs(
          query(collection(db, 'users'), orderBy('updatedAt', 'desc'), limit(10))
        );
        setUsers(
          userSnap.docs.map((doc) => {
            const data = doc.data() as Record<string, unknown>;
            return {
              id: doc.id,
              name: (data['name'] as string?) ?? '—',
              email: (data['email'] as string?) ?? 'unknown',
              role: (data['role'] as string?) ?? 'user',
            };
          })
        );
      } catch (error) {
        console.error('Failed to load admin data', error);
      } finally {
        setFetching(false);
      }
    }

    if (user) {
      loadData();
    }
  }, [user]);

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

  return (
    <AdminShell>
      <section className="rounded-3xl border border-white/10 bg-white/5 p-8 shadow-xl">
        <h2 className="text-2xl font-semibold tracking-wide text-white">Quick Stats</h2>
        <p className="mt-2 max-w-2xl text-sm text-slate-300">
          Review newly onboarded businesses, verify ownership data, and ensure the directory stays premium.
        </p>
        <div className="mt-6 grid gap-4 sm:grid-cols-3">
          <StatCard label="Businesses reviewed" value="32" trend="+5 this week" />
          <StatCard label="Pending approvals" value="8" trend="2 require docs" highlight />
          <StatCard label="Premium plan uptake" value="46%" trend="+3.2% vs last month" />
        </div>
      </section>

      <section className="rounded-3xl border border-white/10 bg-white/5 p-8 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-xl font-semibold text-white">Recent businesses</h3>
          <Link href="#" className="text-sm text-sky-300 hover:text-sky-200">
            View all
          </Link>
        </div>
        <p className="mt-2 text-sm text-slate-300">
          Approve, flag, or contact owners directly. Geo coverage shown in plan column.
        </p>
        <div className="mt-6 overflow-x-auto">
          <table className="min-w-full divide-y divide-white/10 text-left text-sm">
            <thead>
              <tr className="text-slate-300">
                <th className="px-4 py-3 font-medium">Business</th>
                <th className="px-4 py-3 font-medium">Plan</th>
                <th className="px-4 py-3 font-medium">Status</th>
                <th className="px-4 py-3" />
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5 text-slate-100">
              {fetching && businesses.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-4 py-6 text-center text-slate-400">
                    Loading businesses…
                  </td>
                </tr>
              ) : businesses.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-4 py-6 text-center text-slate-400">
                    No businesses found yet.
                  </td>
                </tr>
              ) : (
                businesses.map((business) => (
                  <tr key={business.id}>
                    <td className="px-4 py-4">
                      <div className="font-semibold">{business.name}</div>
                      <div className="mt-1 max-w-md text-xs text-slate-300 line-clamp-2">
                        {business.description || 'No description provided.'}
                      </div>
                    </td>
                    <td className="px-4 py-4">
                      <span className="rounded-full bg-sky-500/10 px-3 py-1 text-xs text-sky-200">
                        {business.plan}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      {business.approved ? (
                        <span className="rounded-full bg-emerald-500/10 px-3 py-1 text-xs text-emerald-200">
                          Approved
                        </span>
                      ) : (
                        <span className="rounded-full bg-amber-500/10 px-3 py-1 text-xs text-amber-200">
                          Pending review
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-4 text-right text-xs text-slate-300">
                      <button className="rounded-full border border-white/20 px-3 py-1 hover:border-sky-300 hover:text-sky-200">
                        Open details
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section className="rounded-3xl border border-white/10 bg-white/5 p-8 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-xl font-semibold text-white">Latest users</h3>
          <Link href="#" className="text-sm text-sky-300 hover:text-sky-200">
            Manage roles
          </Link>
        </div>
        <div className="mt-6 overflow-x-auto">
          <table className="min-w-full divide-y divide-white/10 text-left text-sm">
            <thead>
              <tr className="text-slate-300">
                <th className="px-4 py-3 font-medium">Name</th>
                <th className="px-4 py-3 font-medium">Email</th>
                <th className="px-4 py-3 font-medium">Role</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5 text-slate-100">
              {fetching && users.length === 0 ? (
                <tr>
                  <td colSpan={3} className="px-4 py-6 text-center text-slate-400">
                    Loading users…
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={3} className="px-4 py-6 text-center text-slate-400">
                    No users found.
                  </td>
                </tr>
              ) : (
                users.map((userRow) => (
                  <tr key={userRow.id}>
                    <td className="px-4 py-4 font-semibold">{userRow.name}</td>
                    <td className="px-4 py-4 text-slate-300">{userRow.email}</td>
                    <td className="px-4 py-4">
                      <span className="rounded-full bg-purple-500/10 px-3 py-1 text-xs text-purple-200">
                        {userRow.role}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </AdminShell>
  );
}

function StatCard({
  label,
  value,
  trend,
  highlight,
}: {
  label: string;
  value: string;
  trend: string;
  highlight?: boolean;
}) {
  return (
    <div
      className={`rounded-3xl border px-4 py-6 text-sm transition ${
        highlight
          ? 'border-amber-400/40 bg-amber-500/10 text-amber-100 shadow-lg shadow-amber-500/30'
          : 'border-white/10 bg-white/5 text-slate-200'
      }`}
    >
      <div className="text-xs uppercase tracking-wide opacity-70">{label}</div>
      <div className="mt-2 text-3xl font-semibold">{value}</div>
      <div className="mt-1 text-xs opacity-70">{trend}</div>
    </div>
  );
}
