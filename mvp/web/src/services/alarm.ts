export async function requestNotificationPermission(): Promise<boolean> {
  if (!('Notification' in window)) return false
  if (Notification.permission === 'granted') return true
  if (Notification.permission === 'denied') return false
  const result = await Notification.requestPermission()
  return result === 'granted'
}

export async function showAlarmNotification(message: string): Promise<void> {
  const granted = await requestNotificationPermission()
  if (!granted) return
  new Notification('Voicer 闹钟', { body: message })
}
