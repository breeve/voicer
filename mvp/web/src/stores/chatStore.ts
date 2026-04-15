import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
}

interface Config {
  provider: 'mock' | 'ollama'
  ollamaUrl: string
  model: string
  voiceRate: number
  voicePitch: number
  theme: 'light' | 'dark'
  avatar: string
}

interface ChatStore {
  messages: ChatMessage[]
  config: Config
  isAlarmSet: boolean
  alarmRemaining: number | null
  isListening: boolean
  transcript: string
  addMessage: (msg: Omit<ChatMessage, 'id'>) => void
  setMessages: (messages: ChatMessage[]) => void
  updateConfig: (config: Partial<Config>) => void
  setIsListening: (v: boolean) => void
  setTranscript: (v: string) => void
  setAlarmRemaining: (v: number | null) => void
  setIsAlarmSet: (v: boolean) => void
  clearMessages: () => void
}

export const useChatStore = create<ChatStore>()(
  persist(
    (set) => ({
      messages: [
        {
          id: 'welcome',
          role: 'assistant',
          content: '你好！我是 Voicer，有什么可以帮你的吗？',
        },
      ],
      config: {
        provider: 'mock',
        ollamaUrl: 'http://localhost:11434',
        model: 'llama3.2',
        voiceRate: 1,
        voicePitch: 1,
        theme: 'light',
        avatar: '',
      },
      isListening: false,
      transcript: '',
      isAlarmSet: false,
      alarmRemaining: null,
      addMessage: (msg) =>
        set((s) => ({
          messages: [...s.messages, { ...msg, id: crypto.randomUUID() }],
        })),
      setMessages: (messages) => set({ messages }),
      updateConfig: (cfg) =>
        set((s) => ({ config: { ...s.config, ...cfg } })),
      setIsListening: (v) => set({ isListening: v }),
      setTranscript: (v) => set({ transcript: v }),
      setAlarmRemaining: (v) => set({ alarmRemaining: v }),
      setIsAlarmSet: (v) => set({ isAlarmSet: v }),
      clearMessages: () => set({ messages: [] }),
    }),
    {
      name: 'voicer-chat',
      partialize: (state) => ({
        messages: state.messages,
        config: {
          provider: state.config.provider,
          ollamaUrl: state.config.ollamaUrl,
          model: state.config.model,
          voiceRate: state.config.voiceRate,
          voicePitch: state.config.voicePitch,
          theme: state.config.theme,
          avatar: state.config.avatar,
        },
      }),
    }
  )
)
