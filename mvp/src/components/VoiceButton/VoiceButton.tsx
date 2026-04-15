import styles from './VoiceButton.module.css'

interface Props {
  isListening: boolean
  onStart: () => void
  onStop: () => void
}

export function VoiceButton({ isListening, onStart, onStop }: Props) {
  return (
    <button
      className={`${styles.btn} ${isListening ? styles.listening : styles.idle}`}
      onClick={isListening ? onStop : onStart}
      title={isListening ? '停止' : '语音输入'}
    >
      {isListening ? '🔴' : '🎤'}
    </button>
  )
}
