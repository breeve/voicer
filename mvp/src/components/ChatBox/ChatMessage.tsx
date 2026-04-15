import { ChatMessage as ChatMessageType } from '../../stores/chatStore'
import styles from './ChatMessage.module.css'

interface Props {
  message: ChatMessageType
}

export function ChatMessage({ message }: Props) {
  const isUser = message.role === 'user'

  return (
    <div className={`${styles.wrapper} ${isUser ? styles.user : styles.assistant}`}>
      <div className={styles.avatar}>{isUser ? '👤' : '🤖'}</div>
      <div className={styles.bubble}>{message.content}</div>
    </div>
  )
}
