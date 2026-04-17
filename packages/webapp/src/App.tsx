import { useState, useCallback } from 'react'
import { TopBar } from './components/TopBar/TopBar'
import { ChatBox } from './components/ChatBox/ChatBox'
import { ConfigPanel } from './components/ConfigPanel/ConfigPanel'
import { AlarmPanel } from './components/AlarmPanel/AlarmPanel'
import { useChatStore } from './stores/chatStore'
import { useConfigStore } from './stores/configStore'
import { useSpeechRecognition } from './hooks/useSpeechRecognition'
import { useSpeechSynthesis } from './hooks/useSpeechSynthesis'
import { useAlarm } from './hooks/useAlarm'
import { sendToLLM } from './services/llm'
import './styles/tokens.css'
import './styles/global.css'

export default function App() {
  const [showConfig, setShowConfig] = useState(false)
  const [showAlarm, setShowAlarm] = useState(false)

  const { messages, addMessage, setLoading } = useChatStore()
  const { voiceSpeed, voicePitch, llmProvider, ollamaUrl, ollamaModel } = useConfigStore()

  const {
    transcript,
    interimTranscript,
    isListening,
    start: startListening,
    stop: stopListening,
  } = useSpeechRecognition()

  const { speak, cancel: cancelSpeech } = useSpeechSynthesis({ rate: voiceSpeed, pitch: voicePitch })
  const { remaining, setAlarm, cancelAlarm, hasPermission, requestPermission } = useAlarm()

  const handleVoiceStart = useCallback(() => {
    cancelSpeech()
    startListening()
  }, [startListening, cancelSpeech])

  const handleVoiceStop = useCallback(() => {
    stopListening()
  }, [stopListening])

  const handleSend = useCallback(
    async (text: string) => {
      if (!text.trim()) return

      // Stop any ongoing speech
      cancelSpeech()

      // Add user message
      addMessage({ role: 'user', content: text })

      // Show loading
      setLoading(true)

      try {
        // Build message history for LLM
        const history = messages.map((m) => ({
          role: m.role as 'user' | 'assistant',
          content: m.content,
        }))
        history.push({ role: 'user', content: text })

        const response = await sendToLLM(history, {
          provider: llmProvider,
          ollamaUrl,
          model: ollamaModel,
        })

        // Add assistant response
        addMessage({ role: 'assistant', content: response })

        // Auto-speak the response
        speak(response, { rate: voiceSpeed, pitch: voicePitch })
      } catch (err) {
        console.error('LLM error:', err)
        addMessage({
          role: 'assistant',
          content: '抱歉，发生了错误，请稍后重试。',
        })
      } finally {
        setLoading(false)
      }
    },
    [
      messages,
      llmProvider,
      ollamaUrl,
      ollamaModel,
      voiceSpeed,
      voicePitch,
      addMessage,
      setLoading,
      speak,
      cancelSpeech,
    ]
  )

  const handleTranscriptChange = useCallback((_text: string) => {
    // Transcript is synced directly in ChatBox
  }, [])

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      maxWidth: '680px',
      margin: '0 auto',
      background: 'var(--color-bg)',
    }}>
      <TopBar
        alarmRemaining={remaining}
        onConfigClick={() => setShowConfig(true)}
        onAlarmClick={() => setShowAlarm(true)}
      />

      <ChatBox
        onSend={handleSend}
        onTranscriptChange={handleTranscriptChange}
        transcript={transcript + interimTranscript}
        isListening={isListening}
        onVoiceStart={handleVoiceStart}
        onVoiceStop={handleVoiceStop}
      />

      {showConfig && <ConfigPanel onClose={() => setShowConfig(false)} />}
      {showAlarm && (
        <AlarmPanel
          remaining={remaining}
          onSetAlarm={setAlarm}
          onCancelAlarm={cancelAlarm}
          hasPermission={hasPermission}
          onRequestPermission={requestPermission}
          onClose={() => setShowAlarm(false)}
        />
      )}
    </div>
  )
}