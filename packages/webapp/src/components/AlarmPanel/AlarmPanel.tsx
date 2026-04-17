import { useState } from 'react'
import styles from './AlarmPanel.module.css'

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

interface AlarmPanelProps {
  remaining: number | null
  onSetAlarm: (minutes: number) => void
  onCancelAlarm: () => void
  hasPermission: boolean
  onRequestPermission: () => void
  onClose: () => void
}

export function AlarmPanel({
  remaining,
  onSetAlarm,
  onCancelAlarm,
  hasPermission,
  onRequestPermission,
  onClose,
}: AlarmPanelProps) {
  const [customMinutes, setCustomMinutes] = useState('')

  const handleOverlayClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) onClose()
  }

  const handleSetCustom = () => {
    const mins = parseInt(customMinutes, 10)
    if (mins > 0 && mins <= 1440) {
      onSetAlarm(mins)
      setCustomMinutes('')
    }
  }

  const quickButtons = [
    { label: '5分钟', minutes: 5 },
    { label: '15分钟', minutes: 15 },
    { label: '30分钟', minutes: 30 },
    { label: '1小时', minutes: 60 },
  ]

  return (
    <div className={styles.overlay} onClick={handleOverlayClick}>
      <div className={styles.panel}>
        <div className={styles.header}>
          <span className={styles.title}>
            <span>⏰</span> 闹钟
          </span>
          <button className={styles.closeBtn} onClick={onClose} aria-label="关闭">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div className={styles.body}>
          {!hasPermission && (
            <div style={{ textAlign: 'center', marginBottom: '8px' }}>
              <p style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)', marginBottom: '8px' }}>
                需要通知权限才能收到闹钟提醒
              </p>
              <button
                onClick={onRequestPermission}
                style={{
                  padding: '6px 16px',
                  background: 'var(--color-accent)',
                  color: 'white',
                  borderRadius: 'var(--radius-md)',
                  fontSize: 'var(--text-sm)',
                }}
              >
                授权通知
              </button>
            </div>
          )}

          {remaining !== null ? (
            <div className={styles.currentAlarm}>
              <div className={styles.currentAlarmInfo}>
                <span className={styles.alarmIcon}>⏰</span>
                <div>
                  <div style={{ fontWeight: 600, fontSize: 'var(--text-sm)' }}>
                    闹钟进行中
                  </div>
                  <div className={styles.alarmTime}>倒计时</div>
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <span className={styles.alarmCountdown}>{formatTime(remaining)}</span>
                <button className={styles.cancelBtn} onClick={onCancelAlarm}>
                  取消
                </button>
              </div>
            </div>
          ) : (
            <div className={styles.noAlarm}>当前没有设置闹钟</div>
          )}

          <div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)', marginBottom: '8px' }}>
              快速设置
            </div>
            <div className={styles.quickSet}>
              {quickButtons.map((btn) => (
                <button
                  key={btn.minutes}
                  className={styles.quickBtn}
                  onClick={() => onSetAlarm(btn.minutes)}
                >
                  {btn.label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--color-text-secondary)', marginBottom: '8px' }}>
              自定义
            </div>
            <div className={styles.customSet}>
              <input
                type="number"
                className={styles.customInput}
                placeholder="分钟"
                min="1"
                max="1440"
                value={customMinutes}
                onChange={(e) => setCustomMinutes(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSetCustom()}
              />
              <span className={styles.customLabel}>分钟</span>
              <button
                className={styles.setBtn}
                onClick={handleSetCustom}
                disabled={!customMinutes || parseInt(customMinutes) <= 0}
              >
                设置
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}