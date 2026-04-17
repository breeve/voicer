import { useRef } from 'react'
import styles from './ConfigPanel.module.css'
import { useConfigStore, type LLMProvider } from '../../stores/configStore'

interface ConfigPanelProps {
  onClose: () => void
}

export function ConfigPanel({ onClose }: ConfigPanelProps) {
  const {
    avatar,
    voiceSpeed,
    voicePitch,
    llmProvider,
    ollamaUrl,
    ollamaModel,
    theme,
    setAvatar,
    setVoiceSpeed,
    setVoicePitch,
    setLLMProvider,
    setOllamaUrl,
    setOllamaModel,
    setTheme,
  } = useConfigStore()

  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleOverlayClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) onClose()
  }

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = () => {
      setAvatar(reader.result as string)
    }
    reader.readAsDataURL(file)
  }

  const providers: { value: LLMProvider; label: string; desc: string }[] = [
    { value: 'mock', label: 'Mock 响应', desc: '无需配置，立即可用' },
    { value: 'ollama', label: '本地 Ollama', desc: '需自行安装 Ollama' },
  ]

  return (
    <div className={styles.overlay} onClick={handleOverlayClick}>
      <div className={styles.panel}>
        <div className={styles.header}>
          <span className={styles.title}>设置</span>
          <button className={styles.closeBtn} onClick={onClose} aria-label="关闭">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        <div className={styles.body}>
          <div className={styles.section}>
            <span className={styles.sectionLabel}>形象</span>
            <div className={styles.avatarRow}>
              <div className={styles.avatarPreview}>
                {avatar ? <img src={avatar} alt="头像" /> : <span>🤖</span>}
              </div>
              <button className={styles.avatarBtn} onClick={() => fileInputRef.current?.click()}>
                更换头像
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={handleAvatarChange}
              />
              {avatar && (
                <button className={styles.avatarBtn} onClick={() => setAvatar('')}>
                  移除
                </button>
              )}
            </div>
          </div>

          <div className={styles.section}>
            <span className={styles.sectionLabel}>音色</span>
            <div className={styles.sliderRow}>
              <span className={styles.sliderLabel}>语速</span>
              <input
                type="range"
                className={styles.slider}
                min="0.5"
                max="2"
                step="0.1"
                value={voiceSpeed}
                onChange={(e) => setVoiceSpeed(parseFloat(e.target.value))}
              />
              <span className={styles.sliderValue}>{voiceSpeed.toFixed(1)}x</span>
            </div>
            <div className={styles.sliderRow}>
              <span className={styles.sliderLabel}>音调</span>
              <input
                type="range"
                className={styles.slider}
                min="0.5"
                max="2"
                step="0.1"
                value={voicePitch}
                onChange={(e) => setVoicePitch(parseFloat(e.target.value))}
              />
              <span className={styles.sliderValue}>{voicePitch.toFixed(1)}</span>
            </div>
          </div>

          <div className={styles.section}>
            <span className={styles.sectionLabel}>LLM</span>
            <div className={styles.radioGroup}>
              {providers.map((p) => (
                <label
                  key={p.value}
                  className={`${styles.radioOption} ${llmProvider === p.value ? styles.selected : ''}`}
                >
                  <input
                    type="radio"
                    name="llmProvider"
                    value={p.value}
                    checked={llmProvider === p.value}
                    onChange={() => setLLMProvider(p.value)}
                    style={{ display: 'none' }}
                  />
                  <div className={styles.radioDot} />
                  <div>
                    <div className={styles.radioLabel}>{p.label}</div>
                    <div className={styles.radioDesc}>{p.desc}</div>
                  </div>
                </label>
              ))}
            </div>
            {llmProvider === 'ollama' && (
              <div className={styles.inputRow}>
                <label className={styles.inputLabel}>URL</label>
                <input
                  type="text"
                  className={styles.textInput}
                  value={ollamaUrl}
                  onChange={(e) => setOllamaUrl(e.target.value)}
                  placeholder="http://localhost:11434"
                />
                <label className={styles.inputLabel}>模型</label>
                <input
                  type="text"
                  className={styles.textInput}
                  value={ollamaModel}
                  onChange={(e) => setOllamaModel(e.target.value)}
                  placeholder="llama3.2"
                />
              </div>
            )}
          </div>

          <div className={styles.section}>
            <span className={styles.sectionLabel}>主题</span>
            <div className={styles.themeRow}>
              <button
                className={`${styles.themeBtn} ${theme === 'light' ? styles.active : ''}`}
                onClick={() => setTheme('light')}
              >
                ☀️ 浅色
              </button>
              <button
                className={`${styles.themeBtn} ${theme === 'dark' ? styles.active : ''}`}
                onClick={() => setTheme('dark')}
              >
                🌙 深色
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}