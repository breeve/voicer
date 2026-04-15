import { useRef, useCallback, useState } from 'react'
import { showAlarmNotification } from '../services/alarm'

export function useAlarm() {
  const [isAlarmSet, setIsAlarmSet] = useState(false)
  const [alarmRemaining, setAlarmRemaining] = useState<number | null>(null)
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  const setAlarm = useCallback((minutes: number) => {
    if (timerRef.current) clearTimeout(timerRef.current)
    if (intervalRef.current) clearInterval(intervalRef.current)

    const ms = minutes * 60 * 1000
    setIsAlarmSet(true)
    let remaining = minutes * 60
    setAlarmRemaining(remaining)

    intervalRef.current = setInterval(() => {
      remaining -= 1
      setAlarmRemaining(remaining)
    }, 1000)

    timerRef.current = setTimeout(() => {
      clearInterval(intervalRef.current!)
      setAlarmRemaining(null)
      setIsAlarmSet(false)
      showAlarmNotification(`已过 ${minutes} 分钟`)
    }, ms)
  }, [])

  const cancelAlarm = useCallback(() => {
    if (timerRef.current) clearTimeout(timerRef.current)
    if (intervalRef.current) clearInterval(intervalRef.current)
    setAlarmRemaining(null)
    setIsAlarmSet(false)
  }, [])

  return { isAlarmSet, alarmRemaining, setAlarm, cancelAlarm }
}
