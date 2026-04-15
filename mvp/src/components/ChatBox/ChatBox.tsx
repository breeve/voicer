import { useChatStore } from '../../stores/chatStore'
import { ChatMessage } from './ChatMessage'
import styles from './ChatBox.module.css'

export function ChatBox() {
  const { messages } = useChatStore()

  return (
    <div className={styles.container}>
      {messages.length === 0 && (
        <div className={styles.empty}>
          <span className={styles.emoji}>🤖</span>
          <p>说点什么吧</p>
        </div>
      )}
      {messages.map((msg) => (
        <ChatMessage key={msg.id} message={msg} />
      ))}
    </div>
  )
}
