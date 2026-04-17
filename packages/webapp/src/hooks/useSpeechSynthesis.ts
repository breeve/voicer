import { useCallback } from 'react'

interface UseSpeechSynthesisOptions {
  rate?: number
  pitch?: number
  lang?: string
}

interface UseSpeechSynthesisReturn {
  speak: (text: string, options?: Omit<UseSpeechSynthesisOptions, 'lang'>) => void
  cancel: () => void
  isSupported: boolean
  isSpeaking: boolean
}

export function useSpeechSynthesis(
  defaultOptions: UseSpeechSynthesisOptions = {}
): UseSpeechSynthesisReturn {
  const isSupported = typeof window !== 'undefined' && 'speechSynthesis' in window

  const speak = useCallback(
    (text: string, options?: Omit<UseSpeechSynthesisOptions, 'lang'>) => {
      if (!isSupported || !text.trim()) return

      // Cancel any ongoing speech first
      window.speechSynthesis.cancel()

      const utterance = new SpeechSynthesisUtterance(text)
      utterance.lang = defaultOptions.lang ?? 'zh-CN'
      utterance.rate = options?.rate ?? defaultOptions.rate ?? 1
      utterance.pitch = options?.pitch ?? defaultOptions.pitch ?? 1
      utterance.volume = 1

      // Try to find a Chinese voice
      const voices = window.speechSynthesis.getVoices()
      const zhVoice = voices.find(
        (v) => v.lang.startsWith('zh') || v.lang.startsWith('ZH')
      )
      if (zhVoice) {
        utterance.voice = zhVoice
      }

      window.speechSynthesis.speak(utterance)
    },
    [isSupported, defaultOptions]
  )

  const cancel = useCallback(() => {
    if (isSupported) {
      window.speechSynthesis.cancel()
    }
  }, [isSupported])

  const isSpeaking = isSupported
    ? window.speechSynthesis.speaking
    : false

  return { speak, cancel, isSupported, isSpeaking }
}