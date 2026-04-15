import { useCallback, useRef } from 'react'
import { useChatStore } from '../stores/chatStore'

type SpeechRecognitionType = typeof window.SpeechRecognition

export function useSpeechRecognition() {
  const { isListening, setIsListening, setTranscript, transcript } = useChatStore()
  const recognitionRef = useRef<InstanceType<SpeechRecognitionType> | null>(null)

  const start = useCallback(() => {
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SR) {
      alert('当前浏览器不支持语音识别')
      return
    }

    const recognition = new SR()
    recognitionRef.current = recognition

    recognition.lang = 'zh-CN'
    recognition.continuous = false
    recognition.interimResults = true

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    recognition.onresult = (event: any) => {
      const text = event.results[0][0].transcript
      setTranscript(text)
    }

    recognition.onend = () => {
      setIsListening(false)
      setTranscript('')
      recognitionRef.current = null
    }

    recognition.onerror = () => {
      setIsListening(false)
      recognitionRef.current = null
    }

    recognition.start()
    setIsListening(true)
  }, [setIsListening, setTranscript])

  const stop = useCallback(() => {
    if (recognitionRef.current) {
      recognitionRef.current.stop()
      recognitionRef.current = null
    }
    setIsListening(false)
  }, [setIsListening])

  return { transcript, isListening, start, stop }
}
