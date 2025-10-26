'use client';

import { useEffect, useMemo, useState } from 'react';

import {
  GeoPoint,
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
} from 'firebase/firestore';

import { AdminShell } from '../../../components/AdminShell';
import { useAuth } from '../../../hooks/useAuth';
import { db } from '../../../lib/firebase';

interface CategoryRow {
  id: string;
  name: string;
  parentId: string | null;
}

interface BusinessFormState {
  name: string;
  description: string;
  subcategoryId: string;
  lat: string;
  lng: string;
  addressLine: string;
  phoneNumber: string;
  website: string;
  plan: string;
}

function encodeGeohash(latitude: number, longitude: number, precision = 9) {
  const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  let idx = 0;
  let bit = 0;
  let evenBit = true;
  let geohash = '';

  let latMin = -90.0;
  let latMax = 90.0;
  let lonMin = -180.0;
  let lonMax = 180.0;

  while (geohash.length < precision) {
    if (evenBit) {
      const lonMid = (lonMin + lonMax) / 2;
      if (longitude >= lonMid) {
        idx = idx * 2 + 1;
        lonMin = lonMid;
      } else {
        idx = idx * 2;
        lonMax = lonMid;
      }
    } else {
      const latMid = (latMin + latMax) / 2;
      if (latitude >= latMid) {
        idx = idx * 2 + 1;
        latMin = latMid;
      } else {
        idx = idx * 2;
        latMax = latMid;
      }
    }

    evenBit = !evenBit;
    if (++bit === 5) {
      geohash += base32[idx];
      bit = 0;
      idx = 0;
    }
  }

  return geohash;
}

function buildSearchKeywords(values: string[]) {
  const tokens = new Set<string>();
  values
    .map((value) => value.toLowerCase())
    .forEach((value) => {
      value
        .replace(/[^a-z0-9\s]/g, ' ')
        .split(/\s+/)
        .filter((token) => token.trim().length >= 2)
        .forEach((token) => tokens.add(token));
    });
  return Array.from(tokens);
}

export default function CatalogPage() {
  const { user, loading } = useAuth();
  const [categories, setCategories] = useState<CategoryRow[]>([]);
  const [topCategoryName, setTopCategoryName] = useState('');
  const [subCategoryName, setSubCategoryName] = useState('');
  const [selectedParentId, setSelectedParentId] = useState('');
  const [businessForm, setBusinessForm] = useState<BusinessFormState>({
    name: '',
    description: '',
    subcategoryId: '',
    lat: '25.2048',
    lng: '55.2708',
    addressLine: '',
    phoneNumber: '',
    website: '',
    plan: 'free',
  });
  const [feedback, setFeedback] = useState<string | null>(null);
  const [feedbackTone, setFeedbackTone] = useState<'success' | 'error'>('success');
  const [busy, setBusy] = useState(false);

  const refreshCategories = async () => {
    const snap = await getDocs(query(collection(db, 'categories'), orderBy('name')));
    const rows = snap.docs.map((document) => {
      const data = document.data() as Record<string, unknown>;
      return {
        id: document.id,
        name: (data.name as string) ?? 'Untitled',
        parentId: (data.parentId as string | null) ?? null,
      };
    });
    setCategories(rows);
  };

  useEffect(() => {
    async function loadCategories() {
      try {
        await refreshCategories();
      } catch (error) {
        console.error('Failed to load categories', error);
        setFeedbackTone('error');
        setFeedback('Failed to load categories.');
      }
    }

    if (user) {
      loadCategories();
    }
  }, [user]);

  useEffect(() => {
    if (!feedback) return;
    const timeout = setTimeout(() => setFeedback(null), 4000);
    return () => clearTimeout(timeout);
  }, [feedback]);

  const topLevelCategories = useMemo(
    () => categories.filter((category) => !category.parentId),
    [categories]
  );

  const subCategories = useMemo(
    () => categories.filter((category) => category.parentId),
    [categories]
  );

  useEffect(() => {
    if (!businessForm.subcategoryId && subCategories.length > 0) {
      setBusinessForm((current) => ({ ...current, subcategoryId: subCategories[0].id }));
    }
    if (!selectedParentId && topLevelCategories.length > 0) {
      setSelectedParentId(topLevelCategories[0].id);
    }
    if (
      selectedParentId &&
      selectedParentId.length > 0 &&
      !topLevelCategories.some((category) => category.id === selectedParentId)
    ) {
      setSelectedParentId(topLevelCategories[0]?.id ?? '');
    }
  }, [subCategories, topLevelCategories, businessForm.subcategoryId, selectedParentId]);

  const parentLookup = useMemo(() => {
    const map = new Map<string, string>();
    topLevelCategories.forEach((category) => map.set(category.id, category.name));
    return map;
  }, [topLevelCategories]);

  const filteredSubCategories = subCategories.filter(
    (category) => !selectedParentId || category.parentId === selectedParentId
  );

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-900 text-slate-100">
        <span className="animate-pulse text-lg">Loading catalog tools…</span>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-900 text-slate-100">
        <span>Please sign in to manage the catalog.</span>
      </div>
    );
  }

  const resetBusinessForm = () => {
    setBusinessForm({
      name: '',
      description: '',
      subcategoryId: subCategories[0]?.id ?? '',
      lat: '25.2048',
      lng: '55.2708',
      addressLine: '',
      phoneNumber: '',
      website: '',
      plan: 'free',
    });
  };

  const handleAddTopCategory = async () => {
    if (!topCategoryName.trim()) return;
    setBusy(true);
    try {
      await addDoc(collection(db, 'categories'), {
        name: topCategoryName.trim(),
        parentId: null,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      setTopCategoryName('');
      await refreshCategories();
      setFeedbackTone('success');
      setFeedback('Category created.');
    } catch (error) {
      console.error('Failed to create category', error);
      setFeedbackTone('error');
      setFeedback('Unable to create category.');
    } finally {
      setBusy(false);
    }
  };

  const handleAddSubCategory = async () => {
    if (!subCategoryName.trim() || !selectedParentId) return;
    setBusy(true);
    try {
      await addDoc(collection(db, 'categories'), {
        name: subCategoryName.trim(),
        parentId: selectedParentId,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      setSubCategoryName('');
      await refreshCategories();
      setFeedbackTone('success');
      setFeedback('Subcategory created.');
    } catch (error) {
      console.error('Failed to create subcategory', error);
      setFeedbackTone('error');
      setFeedback('Unable to create subcategory.');
    } finally {
      setBusy(false);
    }
  };

  const handleDeleteCategory = async (categoryId: string) => {
    const hasChildren = subCategories.some((subcategory) => subcategory.parentId === categoryId);
    if (hasChildren) {
      setFeedbackTone('error');
      setFeedback('Remove subcategories first.');
      return;
    }
    setBusy(true);
    try {
      await deleteDoc(doc(db, 'categories', categoryId));
      setCategories((prev) => prev.filter((category) => category.id !== categoryId));
      setFeedbackTone('success');
      setFeedback('Category removed.');
    } catch (error) {
      console.error('Failed to delete category', error);
      setFeedbackTone('error');
      setFeedback('Unable to delete category.');
    } finally {
      setBusy(false);
    }
  };

  const handleDeleteSubCategory = async (subcategoryId: string) => {
    setBusy(true);
    try {
      await deleteDoc(doc(db, 'categories', subcategoryId));
      setCategories((prev) => prev.filter((category) => category.id !== subcategoryId));
      setFeedbackTone('success');
      setFeedback('Subcategory removed.');
    } catch (error) {
      console.error('Failed to delete subcategory', error);
      setFeedbackTone('error');
      setFeedback('Unable to delete subcategory.');
    } finally {
      setBusy(false);
    }
  };

  const handleCreateBusiness = async () => {
    const { name, description, subcategoryId, lat, lng, addressLine, phoneNumber, website, plan } =
      businessForm;
    if (!name.trim() || !description.trim() || !subcategoryId) {
      setFeedbackTone('error');
      setFeedback('Fill all required fields.');
      return;
    }
    const latitude = Number(lat);
    const longitude = Number(lng);
    if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
      setFeedbackTone('error');
      setFeedback('Latitude and longitude must be numeric.');
      return;
    }
    setBusy(true);
    try {
      const geohash = encodeGeohash(latitude, longitude);
      const subcategoryName = categories.find((category) => category.id === subcategoryId)?.name ?? '';
      await addDoc(collection(db, 'businesses'), {
        name: name.trim(),
        description: description.trim(),
        categoryId: subcategoryId,
        ownerId: user.uid,
        plan,
        images: [],
        addressLine: addressLine.trim() || null,
        phoneNumber: phoneNumber.trim() || null,
        website: website.trim() || null,
        approved: true,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        location: new GeoPoint(latitude, longitude),
        locationLat: latitude,
        locationLng: longitude,
        geohash,
        searchKeywords: buildSearchKeywords([name, description, subcategoryName]),
      });
      resetBusinessForm();
      setFeedbackTone('success');
      setFeedback('Business created.');
    } catch (error) {
      console.error('Failed to create business', error);
      setFeedbackTone('error');
      setFeedback('Unable to create business.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <AdminShell>
      {feedback ? (
        <div
          className={`rounded-2xl border px-4 py-3 text-sm shadow-lg md:max-w-xl ${
            feedbackTone === 'success'
              ? 'border-emerald-400/40 bg-emerald-500/10 text-emerald-100'
              : 'border-rose-400/40 bg-rose-500/10 text-rose-100'
          }`}
        >
          {feedback}
        </div>
      ) : null}

      <section className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-xl">
        <h2 className="text-lg font-semibold">Top-level Categories</h2>
        <p className="mt-1 text-sm text-slate-300">
          Organise services into high-level groups. Subcategories can be added below.
        </p>
        <div className="mt-4 flex flex-col gap-3 md:flex-row">
          <input
            type="text"
            value={topCategoryName}
            onChange={(event) => setTopCategoryName(event.target.value)}
            placeholder="e.g. Food & Beverages"
            className="flex-1 rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 text-sm focus:border-emerald-400 focus:outline-none"
          />
          <button
            onClick={handleAddTopCategory}
            disabled={busy}
            className="rounded-xl bg-emerald-500 px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-emerald-400 disabled:opacity-50"
          >
            Add Category
          </button>
        </div>
        {topLevelCategories.length > 0 ? (
          <ul className="mt-4 space-y-2 text-sm">
            {topLevelCategories.map((category) => (
              <li
                key={category.id}
                className="flex items-center justify-between rounded-xl border border-white/10 bg-slate-900/40 px-4 py-2"
              >
                <span>{category.name}</span>
                <button
                  onClick={() => handleDeleteCategory(category.id)}
                  disabled={busy}
                  className="text-xs text-rose-300 transition hover:text-rose-200"
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <p className="mt-4 text-sm text-slate-300">No top-level categories yet.</p>
        )}
      </section>

      <section className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-xl">
        <h2 className="text-lg font-semibold">Subcategories</h2>
        <p className="mt-1 text-sm text-slate-300">
          Subcategories are selectable by business owners when they register.
        </p>
        <div className="mt-4 grid gap-3 md:grid-cols-[minmax(0,_1fr)_minmax(0,_1fr)_auto]">
          <select
            value={selectedParentId}
            onChange={(event) => setSelectedParentId(event.target.value)}
            className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 text-sm focus:border-emerald-400 focus:outline-none"
          >
            {topLevelCategories.map((category) => (
              <option key={category.id} value={category.id}>
                {category.name}
              </option>
            ))}
          </select>
          <input
            type="text"
            value={subCategoryName}
            onChange={(event) => setSubCategoryName(event.target.value)}
            placeholder="e.g. Fast Food"
            className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 text-sm focus:border-emerald-400 focus:outline-none"
          />
          <button
            onClick={handleAddSubCategory}
            disabled={busy || !selectedParentId}
            className="rounded-xl bg-emerald-500 px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-emerald-400 disabled:opacity-50"
          >
            Add Subcategory
          </button>
        </div>

        {filteredSubCategories.length > 0 ? (
          <ul className="mt-4 space-y-2 text-sm">
            {filteredSubCategories.map((category) => (
              <li
                key={category.id}
                className="flex items-center justify-between rounded-xl border border-white/10 bg-slate-900/40 px-4 py-2"
              >
                <span>{category.name}</span>
                <button
                  onClick={() => handleDeleteSubCategory(category.id)}
                  disabled={busy}
                  className="text-xs text-rose-300 transition hover:text-rose-200"
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <p className="mt-4 text-sm text-slate-300">No subcategories for this category yet.</p>
        )}
      </section>

      <section className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-xl">
        <h2 className="text-lg font-semibold">Create Business Card</h2>
        <p className="mt-1 text-sm text-slate-300">
          Publish a listing immediately. Owner information is optional and can be updated later.
        </p>
        <div className="mt-4 grid gap-4 md:grid-cols-2">
          <label className="flex flex-col gap-2 text-sm">
            <span>Name</span>
            <input
              type="text"
              value={businessForm.name}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, name: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Plan</span>
            <select
              value={businessForm.plan}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, plan: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            >
              <option value="free">Free</option>
              <option value="standard">Standard</option>
              <option value="premium">Premium</option>
            </select>
          </label>
          <label className="flex flex-col gap-2 text-sm md:col-span-2">
            <span>Description</span>
            <textarea
              value={businessForm.description}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, description: event.target.value }))
              }
              rows={4}
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Subcategory</span>
            <select
              value={businessForm.subcategoryId}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, subcategoryId: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            >
              {subCategories.map((category) => (
                <option key={category.id} value={category.id}>
                  {parentLookup.get(category.parentId ?? '') ?? 'General'} • {category.name}
                </option>
              ))}
            </select>
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Address (optional)</span>
            <input
              type="text"
              value={businessForm.addressLine}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, addressLine: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Latitude</span>
            <input
              type="text"
              value={businessForm.lat}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, lat: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Longitude</span>
            <input
              type="text"
              value={businessForm.lng}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, lng: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Phone (optional)</span>
            <input
              type="text"
              value={businessForm.phoneNumber}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, phoneNumber: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
          <label className="flex flex-col gap-2 text-sm">
            <span>Website (optional)</span>
            <input
              type="text"
              value={businessForm.website}
              onChange={(event) =>
                setBusinessForm((current) => ({ ...current, website: event.target.value }))
              }
              className="rounded-xl border border-white/10 bg-slate-900/60 px-4 py-2 focus:border-emerald-400 focus:outline-none"
            />
          </label>
        </div>
        <button
          onClick={handleCreateBusiness}
          disabled={busy}
          className="mt-4 rounded-xl bg-emerald-500 px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-emerald-400 disabled:opacity-50"
        >
          Create Business
        </button>
      </section>
    </AdminShell>
  );
}
