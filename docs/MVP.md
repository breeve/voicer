# Voicer MVP — macOS 原型

> 日期：2026-04-16
> 目标：在 3–4 天内完成可运行的 macOS 桌面应用原型

---

## 1. 核心约束

**无服务端** — 所有功能在 App 内实现，不依赖任何远程服务器。

| 数据/功能 | 存储方式 |
|-----------|----------|
| 对话历史 | localStorage（浏览器持久化） |
| 形象配置 | localStorage |
| LLM 对话 | Ollama 本地 API（可选）/ 内置 mock |
| 闹钟通知 | Browser Notification API |
| 头像图片 | File System Access API（本地读取） |

---

## 2. MVP 功能清单

### 2.1 必须实现（MVP scope）

| 功能 | 描述 | 技术实现 |
|------|------|----------|
| 对话界面 | 显示用户/AI 消息气泡 | React + CSS Modules |
| 文本输入 | 输入框 + 发送按钮 | React state |
| 语音输入 | 点击按钮说话，自动转文字 | Web Speech API |
| 语音播报 | AI 回复自动朗读 | Web Speech Synthesis API |
| 形象配置 | 头像上传、音色调节 | localStorage + File API |
| 闹钟设置 | 设置倒计时提醒 | setTimeout + Notification |
| 主题切换 | 深色/浅色模式 | CSS Variables |
| macOS 打包 | 生成 .app 文件 | Capacitor Desktop |

### 2.2 明确不做

- 用户登录/注册
- 云端同步
- 多设备协同
- 电话功能（iWatch 阶段）
- App Store 发布

---

## 3. 技术方案

### 3.1 栈

| 层级 | 技术 |
|------|------|
| 前端框架 | React 18 + TypeScript |
| 构建工具 | Vite |
| 样式 | CSS Modules + CSS Variables |
| 状态管理 | Zustand + persist middleware |
| 桌面打包 | Capacitor Desktop |
| 语音 | Web Speech API（浏览器原生） |
| LLM | Ollama 本地 API（可选）/ Mock 响应 |

### 3.2 LLM 双轨模式

```
设置面板提供切换：

┌──────────────────────────────┐
│  LLM 设置                     │
│                              │
│  ○ Mock 响应（默认）          │
│    用于演示，无需配置          │
│                              │
│  ○ 使用本地 Ollama            │
│    URL: http://localhost:11434│
│    模型: llama3.2            │
└──────────────────────────────┘
```

- **默认**：Mock 响应，开箱即用
- **进阶**：用户自行安装 [Ollama](https://ollama.com/)，配置 URL 和模型

---

## 4. 界面结构

```
┌────────────────────────────────────────────┐
│  [头像]  Voicer              [⚙️] [🕐]     │  ← 顶栏
├────────────────────────────────────────────┤
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ 🤖 你好！我是 Voicer，有什么可以   │   │  ← AI 消息
│  │    帮助你的吗？                      │   │
│  └────────────────────────────────────┘   │
│                                            │
│              ┌──────────────────────────┐ │
│              │ 你好，我想设置一个闹钟     │ │  ← 用户消息
│              └──────────────────────────┘ │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ 🎙️ 正在聆听...                      │   │  ← 录音中状态
│  └────────────────────────────────────┘   │
│                                            │
├────────────────────────────────────────────┤
│  [🎤]  输入消息...                    [➤] │  ← 输入区
└────────────────────────────────────────────┘
```

### 4.1 配置面板（点击右上角 ⚙️）

```
┌────────────────────────────────────────────┐
│  配置                                    ✕  │
├────────────────────────────────────────────┤
│  形象                                     │
│  ┌────┐                                   │
│  │头像│  [更换头像]                       │
│  └────┘                                   │
│                                            │
│  音色                                     │
│  语速: ○────────●────────○  正常          │
│  音调: ○────────●────────○  适中          │
│                                            │
│  LLM                                      │
│  ○ Mock 响应（默认）                       │
│  ○ 使用本地 Ollama                         │
│     URL: [http://localhost:11434    ]     │
│     模型: [llama3.2                  ]    │
│                                            │
│  主题                                     │
│  [浅色] [深色]                            │
└────────────────────────────────────────────┘
```

### 4.2 闹钟面板（点击右上角 🕐）

```
┌────────────────────────────────────────────┐
│  闹钟                                    ✕  │
├────────────────────────────────────────────┤
│  当前设置                                  │
│  ┌──────────────────────────────────────┐ │
│  │  🕐 30 分钟后提醒                     │ │
│  │  [取消]                               │ │
│  └──────────────────────────────────────┘ │
│                                            │
│  快速设置                                  │
│  [5分钟] [15分钟] [30分钟] [1小时]        │
│                                            │
│  自定义: [____] 分钟                        │
│  [设置闹钟]                                │
└────────────────────────────────────────────┘
```

---

## 5. 项目结构

```
packages/web/
├── src/
│   ├── components/
│   │   ├── ChatBox/
│   │   │   ├── ChatBox.tsx
│   │   │   ├── ChatBox.module.css
│   │   │   ├── ChatMessage.tsx
│   │   │   └── ChatMessage.module.css
│   │   ├── VoiceButton/
│   │   │   ├── VoiceButton.tsx
│   │   │   └── VoiceButton.module.css
│   │   ├── ConfigPanel/
│   │   │   └── ConfigPanel.tsx
│   │   ├── AlarmPanel/
│   │   │   └── AlarmPanel.tsx
│   │   ├── Avatar/
│   │   │   └── Avatar.tsx
│   │   └── TopBar/
│   │       └── TopBar.tsx
│   ├── hooks/
│   │   ├── useSpeechRecognition.ts
│   │   ├── useSpeechSynthesis.ts
│   │   └── useAlarm.ts
│   ├── services/
│   │   ├── llm.ts           # Mock + Ollama 切换
│   │   └── alarm.ts         # 闹钟逻辑
│   ├── stores/
│   │   └── chatStore.ts     # Zustand
│   ├── styles/
│   │   └── tokens.css
│   ├── App.tsx
│   └── main.tsx
├── capacitor.config.ts
└── package.json
```

---

## 6. 关键实现

### 6.1 Mock LLM（默认，无需配置）

```ts
// src/services/llm.ts
interface LLMConfig {
  provider: 'mock' | 'ollama'
  ollamaUrl?: string
  model?: string
}

const MOCK_RESPONSES = [
  '好的，我已经记下了。',
  '有意思，请继续说。',
  '我明白你的意思了。',
  '这个问题很有趣，让我思考一下。',
  '你可以试着这样做。',
]

export async function sendToLLM(
  _messages: { role: string; content: string }[],
  config: LLMConfig
): Promise<string> {
  if (config.provider === 'mock') {
    // 模拟延迟，假装在思考
    await new Promise(r => setTimeout(r, 800 + Math.random() * 700))
    return MOCK_RESPONSES[Math.floor(Math.random() * MOCK_RESPONSES.length)]
  }

  // Ollama 路径
  const response = await fetch(`${config.ollamaUrl}/api/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: config.model || 'llama3.2',
      messages,
    }),
  })
  const data = await response.json()
  return data.message?.content ?? ''
}
```

### 6.2 闹钟 Hook

```ts
// src/hooks/useAlarm.ts
import { useState, useCallback, useRef } from 'react'

export function useAlarm() {
  const [remaining, setRemaining] = useState<number | null>(null)
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const setAlarm = useCallback((minutes: number) => {
    if (timerRef.current) clearTimeout(timerRef.current)

    const ms = minutes * 60 * 1000
    setRemaining(minutes * 60) // 倒计时（秒）

    // 每秒更新显示
    const interval = setInterval(() => {
      setRemaining(prev => {
        if (prev === null || prev <= 1) {
          clearInterval(interval)
          return null
        }
        return prev - 1
      })
    }, 1000)

    timerRef.current = setTimeout(async () => {
      clearInterval(interval)
      setRemaining(null)

      // 浏览器通知
      if (Notification.permission === 'granted') {
        new Notification('Voicer 闹钟', {
          body: `已过 ${minutes} 分钟`,
        })
      }
    }, ms)
  }, [])

  const cancelAlarm = useCallback(() => {
    if (timerRef.current) {
      clearTimeout(timerRef.current)
      timerRef.current = null
    }
    setRemaining(null)
  }, [])

  return { remaining, setAlarm, cancelAlarm }
}
```

### 6.3 语音播报 Hook

```ts
// src/hooks/useSpeechSynthesis.ts
import { useCallback } from 'react'

export function useSpeechSynthesis() {
  const speak = useCallback((text: string, options?: { rate?: number; pitch?: number }) => {
    if (!('speechSynthesis' in window)) return

    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = 'zh-CN'
    utterance.rate = options?.rate ?? 1
    utterance.pitch = options?.pitch ?? 1

    // 等待语音合成准备好
    window.speechSynthesis.cancel()
    window.speechSynthesis.speak(utterance)
  }, [])

  return { speak }
}
```

---

## 7. 验证检查清单

完成 MVP 后，逐项验证：

### 7.1 功能验证

- [ ] 打开 App，对话框显示默认欢迎语
- [ ] 输入 "你好"，点击发送，3 秒内看到 AI 回复
- [ ] 点击语音按钮，说一句话，文字自动填入输入框
- [ ] AI 回复后，听到语音自动播报
- [ ] 关闭 App，重新打开，历史消息仍然存在
- [ ] 设置 1 分钟闹钟，倒计时正确，到时弹出通知
- [ ] 上传一张图片作为头像，显示在顶栏
- [ ] 切换深色模式，整个界面变暗

### 7.2 macOS 打包验证

- [ ] `npm run build` 无报错
- [ ] `npx cap sync` 成功
- [ ] 生成的 `.app` 文件在 macOS 上可双击打开
- [ ] App 内语音识别正常工作

---

## 8. 里程碑（日）

| 阶段 | 内容 | 预计时间 |
|------|------|----------|
| Day 1 上午 | 项目初始化 + Capacitor Desktop 搭建 | 3h |
| Day 1 下午 | ChatBox UI + 消息发送/接收 | 3h |
| Day 2 上午 | 语音输入 + 语音播报 | 3h |
| Day 2 下午 | 形象配置 + 主题切换 | 2h |
| Day 3 上午 | 闹钟功能 | 2h |
| Day 3 下午 | Ollama 集成（可选）+ Mock 完善 | 2h |
| Day 4 | macOS 打包 + 验证 + 文档整理 | 4h |

**总工时：约 18–20 小时（3–4 天）**

---

## 9. 后续扩展

MVP 完成后，可按以下路径扩展：

| 方向 | 内容 |
|------|------|
| **iOS/Android** | 用 Capacitor 打包移动端 |
| **iWatch** | Swift 单独实现（对话 + 电话） |
| **后端服务** | 添加 Fastify 后端，支持云端同步 |
| **真实 LLM** | 接入 OpenAI / Anthropic API |
| **多语言** | 扩展支持英文等其他语言 |
