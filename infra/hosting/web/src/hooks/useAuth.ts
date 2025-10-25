'use client';

import { onAuthStateChanged, signInWithPopup, signOut, User } from 'firebase/auth';
import { useEffect, useState } from 'react';

import { auth, googleProvider } from '../lib/firebase';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return {
    user,
    loading,
    signIn: () => signInWithPopup(auth, googleProvider),
    signOut: () => signOut(auth),
  };
}
