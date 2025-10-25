'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

import { SignInCard } from '../components/SignInCard';
import { useAuth } from '../hooks/useAuth';

export default function HomePage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && user) {
      router.replace('/dashboard');
    }
  }, [loading, user, router]);

  if (user) {
    return null;
  }

  return <SignInCard />;
}
