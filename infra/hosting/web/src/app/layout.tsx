import './globals.css';

export const metadata = {
  title: 'Wen Admin Portal',
  description: 'Moderation & onboarding console for Wen staff.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
