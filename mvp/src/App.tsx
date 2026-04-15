import { useState, useEffect } from 'react'
import { useChatStore } from './stores/chatStore'
import { sendToLLM } from './services/llm'
import { useSpeechSynthesis } from './hooks/useSpeechSynthesis'
import { TopBar } from './components/TopBar'
import { ChatBox } from './components/ChatBox'
import { InputArea } from './components/InputArea'
import { ConfigPanel } from './components/ConfigPanel'
import { AlarmPanel } from './components/AlarmPanel'
import styles from './App.module.css'

type Panel = 'config' | 'alarm' | null

export default function App() {
  const [panel, setPanel] = useState<Panel>(null)
  const { messages, addMessage, config } = useChatStore()
  const { speak } = useSpeechSynthesis()

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', config.theme)
  }, [config.theme])

  const handleSend = async (text: string) => {
    addMessage({ role: 'user', content: text })

    try {
      const aiContent = await sendToLLM(
        messages.map((m) => ({ role: m.role, content: m.content })),
        config
      )
      addMessage({ role: 'assistant', content: aiContent })
      speak(aiContent)
    } catch {
      addMessage({ role: 'assistant', content: '抱歉，发生了一些问题。' })
    }
  }

  return (
    <div className={styles.app}>
      <TopBar
        onOpenConfig={() => setPanel('config')}
        onOpenAlarm={() => setPanel('alarm')}
      />
      <main className={styles.main}>
        <ChatBox />
        <InputArea onSend={handleSend} />
      </main>

      {panel === 'config' && <ConfigPanel onClose={() => setPanel(null)} />}
      {panel === 'alarm' && <AlarmPanel onClose={() => setPanel(null)} />}
    </div>
  )
}
