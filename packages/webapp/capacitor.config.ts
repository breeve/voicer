import type { CapacitorConfig } from '@capacitor/cli'

// Capacitor config for mobile builds (iOS/Android).
// The webapp itself is a pure SPA — this is only used when
// building the app as a native mobile package.
const config: CapacitorConfig = {
  appId: 'com.voicer.app',
  appName: 'Voicer',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
  },
  plugins: {
    CapacitorCookies: {
      enabled: true,
    },
  },
}

export default config