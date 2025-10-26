'use client';

import Image from 'next/image';

import { useAuth } from '../hooks/useAuth';

type SignInCardProps = {
  className?: string;
};

export function SignInCard({ className = '' }: SignInCardProps) {
  const { signIn, loading } = useAuth();

  return (
    <div
      className={`rounded-3xl border border-white/10 bg-white/10 p-10 text-slate-100 backdrop-blur-xl shadow-2xl ${className}`}
    >
      <div className="flex flex-col items-center gap-4 text-center">
        <Image src="/wen-logo.svg" alt="Wen" width={64} height={64} />
        <h1 className="text-2xl font-semibold tracking-wide">
          Welcome to Wen Admin
        </h1>
        <p className="text-sm opacity-80">
          Sign in with your staff Google account to review new businesses,
          manage users, and oversee onboarding.
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
  );
}
