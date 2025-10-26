'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

import { SignInCard } from '../components/SignInCard';
import { useAuth } from '../hooks/useAuth';

const FEATURED_CATEGORIES = [
  { name: 'مطاعم', description: 'أفضل المطاعم والمقاهي القريبة منك' },
  { name: 'متاجر أزياء', description: 'ملابس للرجال والنساء والأطفال' },
  { name: 'مهنيون وخدمات', description: 'سباك، كهربائي، صيانة منزلية والمزيد' },
  { name: 'تعليم وتدريب', description: 'مدارس، حضانات، مراكز تدريب متخصصة' },
  { name: 'فعاليات وترفيه', description: 'نشاطات عائلية وتجارب لا تُنسى' },
  { name: 'مراكز صحية وجمال', description: 'صالونات، عيادات، عناية شاملة' },
];

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

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <header className="border-b border-white/10 bg-slate-950">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-6">
          <div>
            <p className="text-sm text-emerald-300">Wen Platform</p>
            <h1 className="text-2xl font-semibold tracking-tight">
              اكتشف أفضل الأعمال حولك
            </h1>
          </div>
          <div className="hidden items-center gap-3 text-sm text-white/80 md:flex">
            <span className="inline-flex items-center gap-2 rounded-full bg-emerald-500/10 px-3 py-1">
              <span className="h-2 w-2 rounded-full bg-emerald-400" />
              متصل بالخدمات السحابية
            </span>
            <span>محدّث حتى {new Date().toLocaleDateString('ar-EG')}</span>
          </div>
        </div>
      </header>
      <main className="mx-auto flex max-w-6xl flex-col gap-12 px-6 py-12 lg:flex-row">
        <section className="flex-1 space-y-8">
          <div className="rounded-3xl border border-white/10 bg-gradient-to-br from-slate-900 via-slate-900 to-slate-950 p-8 shadow-lg shadow-black/40">
            <div className="flex flex-col gap-6 lg:flex-row lg:items-center">
              <div className="flex-1 space-y-3">
                <p className="text-sm text-emerald-300">دليل وين</p>
                <h2 className="text-3xl font-bold leading-tight md:text-4xl">
                  كل ما تحتاجه في مكان واحد — من المطاعم إلى الخدمات المهنية
                </h2>
                <p className="text-base text-white/70">
                  تصفح الفئات، شاهد الصور والأسعار، تواصل مع أصحاب الأعمال عبر
                  الهاتف أو واتساب، واحصل على الاتجاهات مباشرةً عبر خرائط جوجل
                  أو Waze.
                </p>
              </div>
              <div className="grid w-full max-w-sm gap-3 rounded-2xl border border-white/10 bg-white/5 p-6 text-sm">
                <span className="text-white/70">اختر المنطقة</span>
                <div className="flex items-center justify-between gap-4 rounded-xl bg-white/5 px-4 py-3">
                  <span>الشمال</span>
                  <span className="text-xs text-emerald-300">
                    مراكز الأعمال النشطة
                  </span>
                </div>
                <div className="flex items-center justify-between gap-4 rounded-xl bg-white/5 px-4 py-3">
                  <span>الوسط</span>
                  <span className="text-xs text-white/60">أكثر من 1200 نشاط</span>
                </div>
                <div className="flex items-center justify-between gap-4 rounded-xl bg-white/5 px-4 py-3">
                  <span>الجنوب</span>
                  <span className="text-xs text-white/60">
                    عروض موسمية على الوقود
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-xl font-semibold tracking-tight">
                فئات مميزة
              </h3>
              <button
                type="button"
                className="rounded-full border border-white/15 px-4 py-2 text-sm text-white/70 transition hover:border-emerald-400 hover:text-emerald-300"
              >
                استعرض الخريطة
              </button>
            </div>
            <div className="grid gap-4 md:grid-cols-2">
              {FEATURED_CATEGORIES.map((category) => (
                <div
                  key={category.name}
                  className="rounded-2xl border border-white/10 bg-white/5 p-5 transition hover:border-emerald-400/40 hover:bg-emerald-400/5"
                >
                  <div className="flex items-center justify-between gap-3">
                    <h4 className="text-lg font-semibold">
                      {category.name}
                    </h4>
                    <span className="rounded-full bg-emerald-400/10 px-3 py-1 text-xs text-emerald-300">
                      محدث يوميًا
                    </span>
                  </div>
                  <p className="mt-3 text-sm text-white/70">
                    {category.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <aside className="w-full max-w-sm shrink-0 rounded-3xl border border-white/10 bg-white/5 p-1">
          <SignInCard className="w-full bg-slate-950/60" />
        </aside>
      </main>
    </div>
  );
}
