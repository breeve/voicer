import { useState, useCallback, useRef, useEffect } from 'react'

interface UseAlarmReturn {
  remaining: number | null
  setAlarm: (minutes: number) => void
  cancelAlarm: () => void
  hasPermission: boolean
  requestPermission: () => Promise<boolean>
}

export function useAlarm(): UseAlarmReturn {
  const [remaining, setRemaining] = useState<number | null>(null)
  const [hasPermission, setHasPermission] = useState(false)
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  useEffect(() => {
    setHasPermission(Notification.permission === 'granted')
  }, [])

  const requestPermission = useCallback(async () => {
    if (!('Notification' in window)) return false
    const result = await Notification.requestPermission()
    setHasPermission(result === 'granted')
    return result === 'granted'
  }, [])

  const cancelAlarm = useCallback(() => {
    if (timerRef.current) {
      clearTimeout(timerRef.current)
      timerRef.current = null
    }
    if (intervalRef.current) {
      clearInterval(intervalRef.current)
      intervalRef.current = null
    }
    setRemaining(null)
  }, [])

  const setAlarm = useCallback(
    (minutes: number) => {
      cancelAlarm()

      if (Notification.permission !== 'granted') {
        Notification.requestPermission()
      }

      const totalSeconds = minutes * 60
      setRemaining(totalSeconds)

      // Countdown interval
      intervalRef.current = setInterval(() => {
        setRemaining((prev) => {
          if (prev === null || prev <= 1) {
            if (intervalRef.current) clearInterval(intervalRef.current)
            return null
          }
          return prev - 1
        })
      }, 1000)

      // Fire alarm
      timerRef.current = setTimeout(() => {
        if (intervalRef.current) clearInterval(intervalRef.current)

        if (Notification.permission === 'granted') {
          new Notification('Voicer 闹钟', {
            body: `已过 ${minutes} 分钟`,
            icon: '/favicon.svg',
          })
        }

        // Fallback: play a beep if notification not available
        try {
          const ctx = new AudioContext()
          const oscillator = ctx.createOscillator()
          const gain = ctx.createGain()
          oscillator.connect(gain)
          gain.connect(ctx.destination)
          oscillator.frequency.value = 800
          gain.gain.value = 0.3
          oscillator.start()
          oscillator.stop(ctx.currentTime + 0.5)
        } catch {
          // Audio context not available
        }

        setRemaining(null)
      }, minutes * 60 * 1000)
    },
    [cancelAlarm]
  )

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current)
      if (intervalRef.current) clearInterval(intervalRef.current)
    }
  }, [])

  return { remaining, setAlarm, cancelAlarm, hasPermission, requestPermission }
}