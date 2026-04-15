import { useChatStore } from '../../stores/chatStore'
import styles from './TopBar.module.css'

interface TopBarProps {
  onOpenConfig: () => void
  onOpenAlarm: () => void
}

export function TopBar({ onOpenConfig, onOpenAlarm }: TopBarProps) {
  const { config } = useChatStore()

  return (
    <header className={styles.bar}>
      <div className={styles.left}>
        <div className={styles.avatar}>
          {config.avatar ? (
            <img src={config.avatar} alt="avatar" />
          ) : (
            <span>🤖</span>
          )}
        </div>
        <span className={styles.title}>Voicer</span>
      </div>
      <div className={styles.actions}>
        <button className={styles.iconBtn} onClick={onOpenAlarm} title="闹钟">
          🕐
        </button>
        <button className={styles.iconBtn} onClick={onOpenConfig} title="设置">
          ⚙️
        </button>
      </div>
    </header>
  )
}
