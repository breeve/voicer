import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type Theme = 'light' | 'dark'
export type LLMProvider = 'mock' | 'ollama'

interface ConfigStore {
  avatar: string
  voiceSpeed: number
  voicePitch: number
  llmProvider: LLMProvider
  ollamaUrl: string
  ollamaModel: string
  theme: Theme
  setAvatar: (avatar: string) => void
  setVoiceSpeed: (speed: number) => void
  setVoicePitch: (pitch: number) => void
  setLLMProvider: (provider: LLMProvider) => void
  setOllamaUrl: (url: string) => void
  setOllamaModel: (model: string) => void
  setTheme: (theme: Theme) => void
  toggleTheme: () => void
}

export const useConfigStore = create<ConfigStore>()(
  persist(
    (set, get) => ({
      avatar: '',
      voiceSpeed: 1,
      voicePitch: 1,
      llmProvider: 'mock',
      ollamaUrl: 'http://localhost:11434',
      ollamaModel: 'llama3.2',
      theme: 'light',
      setAvatar: (avatar) => set({ avatar }),
      setVoiceSpeed: (voiceSpeed) => set({ voiceSpeed }),
      setVoicePitch: (voicePitch) => set({ voicePitch }),
      setLLMProvider: (llmProvider) => set({ llmProvider }),
      setOllamaUrl: (ollamaUrl) => set({ ollamaUrl }),
      setOllamaModel: (ollamaModel) => set({ ollamaModel }),
      setTheme: (theme) => {
        document.documentElement.setAttribute('data-theme', theme)
        set({ theme })
      },
      toggleTheme: () => {
        const next = get().theme === 'light' ? 'dark' : 'light'
        document.documentElement.setAttribute('data-theme', next)
        set({ theme: next })
      },
    }),
    {
      name: 'voicer-config',
      onRehydrateStorage: () => (state) => {
        if (state) {
          document.documentElement.setAttribute('data-theme', state.theme)
        }
      },
    }
  )
)