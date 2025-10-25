'use client';

import Image from 'next/image';

import { useAuth } from '../hooks/useAuth';

export function SignInCard() {
  const { signIn, loading } = useAuth();

  return (
    <div className="mx-auto flex min-h-screen w-full items-center justify-center bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-6 py-24 text-slate-100">
      <div className="w-full max-w-md rounded-3xl border border-white/10 bg-white/10 p-10 backdrop-blur-md shadow-2xl">
        <div className="flex flex-col items-center gap-4 text-center">
          <Image src="/wen-logo.svg" alt="Wen" width={72} height={72} />
          <h1 className="text-2xl font-semibold tracking-wide">Welcome to Wen Admin</h1>
          <p className="text-sm opacity-80">
            Sign in with your staff Google account to review new businesses, manage users, and oversee onboarding.
          </p>
          <button
            onClick={signIn}
            disabled={loading}
            className="mt-6 flex w-full items-center justify-center gap-3 rounded-full bg-white px-6 py-3 font-semibold text-slate-900 shadow-lg transition hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-60"
          >
            <Image src="/google.svg" alt="Google" width={18} height={18} />
            Continue with Google
          </button>
        </div>
      </div>
    </div>
  );
}
