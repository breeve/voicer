import { useRef, useEffect, useState } from 'react'
import styles from './ChatBox.module.css'
import { ChatMessage, TypingIndicator } from './ChatMessage'
import { useChatStore } from '../../stores/chatStore'
import { VoiceButton } from '../VoiceButton/VoiceButton'

interface ChatBoxProps {
  onSend: (text: string) => void
  onTranscriptChange: (text: string) => void
  transcript: string
  isListening: boolean
  onVoiceStart: () => void
  onVoiceStop: () => void
}

export function ChatBox({
  onSend,
  onTranscriptChange,
  transcript,
  isListening,
  onVoiceStart,
  onVoiceStop,
}: ChatBoxProps) {
  const { messages, isLoading } = useChatStore()
  const [input, setInput] = useState('')
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  // Sync transcript to input
  useEffect(() => {
    if (transcript) {
      setInput((prev) => {
        // If user hasn't typed anything, replace; otherwise append
        return prev === '' || prev === transcript.slice(0, prev.length)
          ? transcript
          : prev
      })
    }
  }, [transcript])

  // Auto-scroll to bottom
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, isLoading])

  // Focus input on mount
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const handleSend = () => {
    const text = input.trim()
    if (!text) return
    onSend(text)
    setInput('')
    onTranscriptChange('')
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value)
    onTranscriptChange(e.target.value)
  }

  const displayInput = transcript || input

  return (
    <div className={styles.box}>
      {messages.length === 0 ? (
        <div className={styles.empty}>
          <div className={styles.emptyIcon}>💬</div>
          <p className={styles.emptyText}>
            发送消息开始对话，或点击麦克风语音输入
          </p>
        </div>
      ) : (
        <div className={styles.messages}>
          {messages.map((msg) => (
            <ChatMessage key={msg.id} message={msg} />
          ))}
          {isLoading && <TypingIndicator />}
          <div ref={bottomRef} />
        </div>
      )}

      <div className={styles.inputBar}>
        <VoiceButton
          isListening={isListening}
          onStart={onVoiceStart}
          onStop={onVoiceStop}
        />
        <input
          ref={inputRef}
          type="text"
          className={styles.input}
          placeholder={isListening ? '正在聆听...' : '输入消息...'}
          value={displayInput}
          onChange={handleInputChange}
          onKeyDown={handleKeyDown}
          disabled={isLoading}
        />
        <button
          className={styles.sendBtn}
          onClick={handleSend}
          disabled={!input.trim() || isLoading}
          aria-label="发送消息"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="19" x2="12" y2="5" />
            <polyline points="5 12 12 5 19 12" />
          </svg>
        </button>
      </div>
    </div>
  )
}