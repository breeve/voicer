import { useState, useEffect } from 'react'
import { useSpeechRecognition } from '../../hooks/useSpeechRecognition'
import { VoiceButton } from '../VoiceButton'
import styles from './InputArea.module.css'

interface Props {
  onSend: (text: string) => void
}

export function InputArea({ onSend }: Props) {
  const [text, setText] = useState('')
  const { isListening, transcript, start, stop } = useSpeechRecognition()

  useEffect(() => {
    if (transcript) {
      setText(transcript)
    }
  }, [transcript])

  const handleSend = () => {
    const t = text.trim()
    if (!t) return
    onSend(t)
    setText('')
  }

  return (
    <div className={styles.area}>
      <div className={styles.row}>
        <VoiceButton isListening={isListening} onStart={start} onStop={stop} />

        {isListening ? (
          <div className={styles.listening}>
            <span>🎙️</span>
            <span>聆听中...</span>
          </div>
        ) : (
          <input
            className={styles.input}
            type="text"
            placeholder="输入消息..."
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
          />
        )}

        <button
          className={styles.sendBtn}
          onClick={handleSend}
          disabled={!text.trim() || isListening}
          title="发送"
        >
          ➤
        </button>
      </div>
    </div>
  )
}
