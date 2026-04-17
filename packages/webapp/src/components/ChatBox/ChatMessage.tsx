import styles from './ChatMessage.module.css'
import type { ChatMessage as ChatMessageType } from '../../stores/chatStore'

interface ChatMessageProps {
  message: ChatMessageType
}

export function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.role === 'user'

  return (
    <div className={`${styles.message} ${isUser ? styles.user : styles.assistant}`}>
      {!isUser && (
        <div className={styles.avatar}>
          <span>🤖</span>
        </div>
      )}
      <div className={styles.bubble}>{message.content}</div>
      {isUser && (
        <div className={styles.avatar}>
          <span>👤</span>
        </div>
      )}
    </div>
  )
}

export function TypingIndicator() {
  return (
    <div className={`${styles.message} ${styles.assistant}`}>
      <div className={styles.avatar}>
        <span>🤖</span>
      </div>
      <div className={`${styles.bubble} ${styles.typing}`}>
        <div className={styles.typingDot} />
        <div className={styles.typingDot} />
        <div className={styles.typingDot} />
      </div>
    </div>
  )
}