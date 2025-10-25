'use client';

import Link from 'next/link';
import { ReactNode } from 'react';

import { useAuth } from '../hooks/useAuth';

interface AdminShellProps {
  children: ReactNode;
}

export function AdminShell({ children }: AdminShellProps) {
  const { user, signOut } = useAuth();

  return (
    <div className="min-h-screen bg-admin-gradient font-sans text-slate-100">
      <header className="sticky top-0 z-20 backdrop-blur bg-slate-900/80 border-b border-slate-700">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <Link href="/dashboard" className="text-xl font-semibold tracking-wide">
            Wen Admin Portal
          </Link>
          <div className="flex items-center gap-4 text-sm">
            <span className="opacity-80">{user?.email}</span>
            <button
              onClick={signOut}
              className="rounded-full border border-slate-500 px-4 py-1 transition hover:bg-slate-800"
            >
              Sign out
            </button>
          </div>
        </div>
      </header>
      <main className="mx-auto flex max-w-6xl flex-col gap-8 px-6 py-10">
        {children}
      </main>
    </div>
  );
}
