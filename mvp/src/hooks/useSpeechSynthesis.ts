import { useCallback } from 'react'
import { useChatStore } from '../stores/chatStore'

export function useSpeechSynthesis() {
  const { config } = useChatStore()

  const speak = useCallback(
    (text: string) => {
      if (!('speechSynthesis' in window)) return

      window.speechSynthesis.cancel()

      const utterance = new SpeechSynthesisUtterance(text)
      utterance.lang = 'zh-CN'
      utterance.rate = config.voiceRate
      utterance.pitch = config.voicePitch

      window.speechSynthesis.speak(utterance)
    },
    [config.voiceRate, config.voicePitch]
  )

  return { speak }
}
