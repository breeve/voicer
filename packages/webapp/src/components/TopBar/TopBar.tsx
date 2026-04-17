import styles from './TopBar.module.css'
import { useConfigStore } from '../../stores/configStore'

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

interface TopBarProps {
  alarmRemaining: number | null
  onConfigClick: () => void
  onAlarmClick: () => void
}

export function TopBar({ alarmRemaining, onConfigClick, onAlarmClick }: TopBarProps) {
  const { avatar } = useConfigStore()

  return (
    <div className={styles.topBar}>
      <div className={styles.avatar}>
        {avatar ? (
          <img src={avatar} alt="头像" />
        ) : (
          <span>🤖</span>
        )}
      </div>
      <span className={styles.title}>Voicer</span>
      <div className={styles.actions}>
        <button
          className={styles.iconBtn}
          onClick={onAlarmClick}
          aria-label="闹钟"
          title="闹钟"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="13" r="8" />
            <path d="M12 9v4l2 2" />
            <path d="M5 3L2 6" />
            <path d="M22 6l-3-3" />
            <path d="M12 5V3" />
          </svg>
          {alarmRemaining !== null && (
            <span className={`${styles.alarmBadge} ${alarmRemaining < 60 ? styles.soon : ''}`}>
              {formatTime(alarmRemaining)}
            </span>
          )}
        </button>
        <button
          className={styles.iconBtn}
          onClick={onConfigClick}
          aria-label="设置"
          title="设置"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="3" />
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
          </svg>
        </button>
      </div>
    </div>
  )
}