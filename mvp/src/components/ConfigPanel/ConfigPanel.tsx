import { useRef, ChangeEvent } from 'react'
import { useChatStore } from '../../stores/chatStore'
import styles from './ConfigPanel.module.css'

interface Props {
  onClose: () => void
}

export function ConfigPanel({ onClose }: Props) {
  const { config, updateConfig } = useChatStore()
  const fileRef = useRef<HTMLInputElement>(null)

  const handleAvatarChange = (e: ChangeEvent<HTMLInputElement>) => {
    const file = (e.target as HTMLInputElement).files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (ev) => {
      const data = ev.target?.result as string
      updateConfig({ avatar: data })
    }
    reader.readAsDataURL(file)
  }

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.panel} onClick={(e) => e.stopPropagation()}>
        <div className={styles.header}>
          <span className={styles.title}>设置</span>
          <button className={styles.closeBtn} onClick={onClose}>
            ✕
          </button>
        </div>

        <div className={styles.body}>
          {/* 形象 */}
          <div className={styles.section}>
            <span className={styles.sectionTitle}>形象</span>
            <div className={styles.avatarRow}>
              <div className={styles.avatarPreview}>
                {config.avatar ? (
                  <img src={config.avatar} alt="avatar" />
                ) : (
                  <span>🤖</span>
                )}
              </div>
              <input
                ref={fileRef}
                type="file"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={handleAvatarChange}
              />
              <button className={styles.avatarBtn} onClick={() => fileRef.current?.click()}>
                更换头像
              </button>
            </div>
          </div>

          {/* 音色 */}
          <div className={styles.section}>
            <span className={styles.sectionTitle}>音色</span>
            <div className={styles.sliderRow}>
              <span className={styles.sliderLabel}>语速</span>
              <input
                className={styles.slider}
                type="range"
                min="0.5"
                max="2"
                step="0.1"
                value={config.voiceRate}
                onChange={(e) => updateConfig({ voiceRate: Number(e.target.value) })}
              />
            </div>
            <div className={styles.sliderRow}>
              <span className={styles.sliderLabel}>音调</span>
              <input
                className={styles.slider}
                type="range"
                min="0.5"
                max="2"
                step="0.1"
                value={config.voicePitch}
                onChange={(e) => updateConfig({ voicePitch: Number(e.target.value) })}
              />
            </div>
          </div>

          {/* LLM */}
          <div className={styles.section}>
            <span className={styles.sectionTitle}>LLM</span>
            <div className={styles.radioGroup}>
              <label className={styles.radio}>
                <input
                  type="radio"
                  name="llm"
                  checked={config.provider === 'mock'}
                  onChange={() => updateConfig({ provider: 'mock' })}
                />
                Mock 响应（默认，无需配置）
              </label>
              <label className={styles.radio}>
                <input
                  type="radio"
                  name="llm"
                  checked={config.provider === 'ollama'}
                  onChange={() => updateConfig({ provider: 'ollama' })}
                />
                使用本地 Ollama
              </label>
              {config.provider === 'ollama' && (
                <div className={styles.inputField}>
                  <input
                    type="text"
                    placeholder="http://localhost:11434"
                    value={config.ollamaUrl}
                    onChange={(e) => updateConfig({ ollamaUrl: e.target.value })}
                  />
                  <input
                    type="text"
                    placeholder="llama3.2"
                    value={config.model}
                    onChange={(e) => updateConfig({ model: e.target.value })}
                  />
                </div>
              )}
            </div>
          </div>

          {/* 主题 */}
          <div className={styles.section}>
            <span className={styles.sectionTitle}>主题</span>
            <div className={styles.themeRow}>
              <button
                className={`${styles.themeBtn} ${config.theme === 'light' ? styles.active : ''}`}
                onClick={() => updateConfig({ theme: 'light' })}
              >
                ☀️ 浅色
              </button>
              <button
                className={`${styles.themeBtn} ${config.theme === 'dark' ? styles.active : ''}`}
                onClick={() => updateConfig({ theme: 'dark' })}
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
