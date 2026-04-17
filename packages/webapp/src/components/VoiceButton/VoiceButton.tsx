import styles from './VoiceButton.module.css'

interface VoiceButtonProps {
  isListening: boolean
  onStart: () => void
  onStop: () => void
}

export function VoiceButton({ isListening, onStart, onStop }: VoiceButtonProps) {
  const handleClick = () => {
    if (isListening) {
      onStop()
    } else {
      onStart()
    }
  }

  return (
    <button
      className={`${styles.button} ${isListening ? styles.listening : ''}`}
      onClick={handleClick}
      aria-label={isListening ? '停止录音' : '开始语音输入'}
      title={isListening ? '停止录音' : '语音输入'}
    >
      {isListening ? (
        <div className={styles.waveform}>
          <div className={styles.waveformBar} />
          <div className={styles.waveformBar} />
          <div className={styles.waveformBar} />
          <div className={styles.waveformBar} />
          <div className={styles.waveformBar} />
        </div>
      ) : (
        <svg className={styles.icon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z" />
          <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
          <line x1="12" y1="19" x2="12" y2="23" />
          <line x1="8" y1="23" x2="16" y2="23" />
        </svg>
      )}
    </button>
  )
}