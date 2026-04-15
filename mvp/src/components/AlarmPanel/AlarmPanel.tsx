import { useState } from 'react'
import { useAlarm } from '../../hooks/useAlarm'
import styles from './AlarmPanel.module.css'

interface Props {
  onClose: () => void
}

export function AlarmPanel({ onClose }: Props) {
  const { isAlarmSet, alarmRemaining, setAlarm, cancelAlarm } = useAlarm()
  const [minutes, setMinutes] = useState('')

  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60)
    const s = seconds % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.panel} onClick={(e) => e.stopPropagation()}>
        <div className={styles.header}>
          <span className={styles.title}>闹钟</span>
          <button className={styles.closeBtn} onClick={onClose}>
            ✕
          </button>
        </div>

        {isAlarmSet && alarmRemaining !== null && (
          <div className={styles.currentAlarm}>
            <p>倒计时中</p>
            <div className={styles.countdown}>{formatTime(alarmRemaining)}</div>
            <button className={styles.cancelBtn} onClick={cancelAlarm}>
              取消闹钟
            </button>
          </div>
        )}

        <div className={styles.quickSet}>
          {[5, 15, 30, 60].map((m) => (
            <button key={m} className={styles.quickBtn} onClick={() => setAlarm(m)}>
              {m}分钟
            </button>
          ))}
        </div>

        <div className={styles.customRow}>
          <input
            className={styles.customInput}
            type="number"
            placeholder="自定义分钟"
            min="1"
            value={minutes}
            onChange={(e) => setMinutes(e.target.value)}
          />
          <button
            className={styles.setBtn}
            onClick={() => {
              const m = parseInt(minutes, 10)
              if (m > 0) {
                setAlarm(m)
                setMinutes('')
              }
            }}
          >
            设置
          </button>
        </div>
      </div>
    </div>
  )
}
