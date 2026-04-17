# Voicer 设计文档

> 日期：2026-04-16
> 状态：初稿

---

## 1. 项目概述

**Voicer** 是一款跨平台语音交互 App，以对话框为核心交互形式，支持文本/语音输入，可接入自定义 LLM，具备本地资源搜索和闹钟功能。

**多端架构**：
- **iPhone** — 主设备，原生 Swift 实现
- **iWatch** — iPhone 的补充，提供最小对话和电话能力
- **Web** — 跨平台（macOS / Windows / Linux 浏览器），Capacitor 实现

**愿景**：个人语音助手，多端协同，iPhone 为核心管理设备。

---

## 2. 技术选型

### 2.1 平台技术决策

| 平台 | 技术栈 | 运行时 |
|------|--------|--------|
| **iPhone** | Swift + SwiftUI | 原生 iOS |
| **iWatch** | Swift + SwiftUI | 原生 watchOS（依赖 iPhone） |
| **Web** | React + TypeScript + Capacitor | 浏览器（macOS / Windows / Linux） |

### 2.2 iPhone / iWatch 实现原则

**目标**：可直接 `swift build` 运行，无需 Xcode 图形界面配置。

| 实践 | 说明 |
|------|------|
| Swift Package Manager (SPM) | 所有依赖通过 `Package.swift` 声明 |
| 命令行可运行 | `swift run Voicer` 即可启动 |
| 避免 xcodeproj | 不生成 `.xcodeproj`，减少 Git 冲突和配置负担 |
| watchOS 应用 | 作为独立 App 存在，但功能限定为语音对话和电话 |

### 2.3 Web 跨平台实现

| 组件 | 选型 |
|------|------|
| 前端框架 | React 18 + TypeScript |
| 构建工具 | Vite |
| 样式 | CSS Modules + CSS Variables |
| 客户端状态 | Zustand |
| 语音识别 | Web Speech API |
| 语音合成 | Web Speech Synthesis API |
| 跨平台容器 | Capacitor（打包为 PWA / Electron 备选） |

### 2.4 LLM 调用（无服务端）

**MVP 阶段不依赖任何服务器**，LLM 采用双轨模式：

| 环境 | 方案 |
|------|------|
| **默认** | Mock 响应，无需配置，开箱即用 |
| **可选** | Ollama 本地 LLM（用户自行安装，macOS: `brew install ollama`） |
| **进阶** | 直接调用 OpenAI / Anthropic API（API Key 存储在本地） |

iPhone / iWatch 同样支持 Mock 或 Ollama，不强制联网。

### 2.5 为什么不选其他方案

| 备选 | 放弃原因 |
|------|----------|
| Flutter | iWatch 支持弱 |
| UniApp | 语音 API 支持不完善 |
| SwiftUI + Xcode 图形化 | 需要 IDE 配置，不够轻量 |
| Electron（Web 端） | Capacitor 更轻量，天然支持移动端打包 |

### 2.6 架构图（无服务端）

```
┌─────────────────────────────────────────┐
│                  iPhone                  │
│  ┌─────────────────────────────────┐    │
│  │  SwiftUI App (Swift Package)    │    │
│  │  - 对话界面                      │    │
│  │  - 语音输入/输出                  │    │
│  │  - LLM (Mock / Ollama)          │    │
│  │  - 闹钟管理                       │    │
│  └─────────────────────────────────┘    │
│                    ↕ 协同                 │
│  ┌─────────────────────────────────┐    │
│  │  iWatch App (Swift Package)     │    │
│  │  - 最小对话界面                  │    │
│  │  - 电话能力（辅助）               │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
          ↕ 本地存储（UserDefaults / 文件）
┌─────────────────────────────────────────┐
│         macOS / Windows Desktop          │
│  ┌─────────────────────────────────┐    │
│  │  Capacitor Desktop App          │    │
│  │  React + TypeScript             │    │
│  │  - 对话界面（响应式）            │    │
│  │  - 语音输入/输出                 │    │
│  │  - LLM (Mock / Ollama)          │    │
│  │  - localStorage 持久化           │    │
│  └─────────────────────────────────┘    │
│  支持：macOS / Windows / Linux          │
│  无需任何服务器                          │
└─────────────────────────────────────────┘
```

---

## 3. 里程碑规划

### M0 — 基础骨架 [第 1 周]
- [ ] 项目目录初始化（`ios/`, `packages/watch`, `packages/web`）
- [ ] Swift Package.swift 定义（iPhone / iWatch）
- [ ] Web: Vite + React + TypeScript 初始化
- [ ] CSS 变量系统定义
- [ ] Git 规范提交

### M1 — iPhone Swift 原型 [第 2–3 周]
- [ ] SwiftUI 对话界面基础实现
- [ ] 语音识别（Speech 框架）
- [ ] 语音合成
- [ ] LLM 接入（OpenAI GPT-4o Mini）
- [ ] `swift run` 可启动验证

### M2 — Web 跨平台原型 [第 3–4 周]
- [ ] React 对话 UI
- [ ] 语音输入（Web Speech API）
- [ ] 语音播报（Web Speech Synthesis）
- [ ] LLM 对话（通过 API Routes 代理）
- [ ] Capacitor 打包验证

### M3 — iWatch 最小实现 [第 5–6 周]
- [ ] iWatch App 创建（依赖 iPhone 配对）
- [ ] 简化对话界面（仅语音）
- [ ] 电话拨打入口（WatchKit 能力）
- [ ] iPhone 协同消息同步

### M4 — 核心功能完善 [第 7–9 周]
- [ ] 本地资源搜索（文本、音频文件索引）
- [ ] 闹钟设置功能（iPhone 为主，Watch 同步）
- [ ] 形象配置（头像、音色、性格）
- [ ] 消息历史持久化
- [ ] 深色/浅色主题

### M5 — 多端同步与打包 [第 10–12 周]
- [ ] iPhone App Store 打包
- [ ] iWatch App Store 打包
- [ ] Web 部署（Vercel / Cloudflare Pages）
- [ ] 数据同步方案（iCloud / 自建 API）

---

## 4. iPhone Swift 实现（可运行代码）

### 4.1 Package.swift

```swift
// swift build 即可，无需 xcodeproj
// 运行: swift run Voicer

import PackageDescription

let package = Package(
    name: "Voicer",
    platforms: [
        .iOS("17.0"),
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/siftprotocol/sift-swift", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "Voicer",
            dependencies: ["Sift"],
            path: "Sources"
        )
    ]
)
```

### 4.2 入口文件

```swift
// Sources/main.swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

### 4.3 对话界面（SwiftUI）

```swift
// Sources/Views/ChatView.swift
import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
}

enum MessageRole { case user, assistant }

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(role: msg.role, content: msg.content)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation { proxy.scrollTo(messages.last?.id) }
                }
            }

            Divider()

            HStack(spacing: 12) {
                Button {
                    toggleRecording()
                } label: {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundStyle(isRecording ? .red : .accent)
                }

                TextField("输入消息...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { sendMessage() }

                Button { sendMessage() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
    }

    private func toggleRecording() {
        isRecording.toggle()
        // TODO: 调用 Speech 框架进行语音识别
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        let userMsg = Message(role: .user, content: inputText)
        messages.append(userMsg)
        inputText = ""
        // TODO: 调用 LLM
    }
}
```

### 4.4 语音识别（Speech 框架）

```swift
// Sources/Services/SpeechRecognizer.swift
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var isRecognizing = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuth() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecognizing() throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                self?.transcript = result.bestTranscription.formattedString
            }
        }

        let audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.start()
    }

    func stopRecognizing() {
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecognizing = false
    }
}
```

---

## 5. Web 原型实现（可运行代码）

### 5.1 项目结构

```
packages/webapp/
├── src/
│   ├── components/
│   │   ├── ChatBox/
│   │   │   ├── ChatMessage.tsx
│   │   │   └── ChatMessage.css
│   │   ├── VoiceButton/
│   │   │   ├── VoiceButton.tsx
│   │   │   └── VoiceButton.css
│   │   ├── Avatar/
│   │   │   └── Avatar.tsx
│   │   └── ConfigPanel/
│   │       └── ConfigPanel.tsx
│   ├── hooks/
│   │   ├── useSpeechRecognition.ts
│   │   └── useSpeechSynthesis.ts
│   ├── services/
│   │   └── llm.ts
│   ├── stores/
│   │   └── chatStore.ts
│   ├── styles/
│   │   └── tokens.css
│   ├── App.tsx
│   └── main.tsx
├── index.html
├── vite.config.ts
└── package.json
```

### 5.2 入口

```tsx
// src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './styles/tokens.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
```

### 5.3 对话状态 (Zustand)

```ts
// src/stores/chatStore.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
}

export const useChatStore = create<{
  messages: ChatMessage[]
  addMessage: (msg: Omit<ChatMessage, 'id'>) => void
  clearMessages: () => void
}>()(
  persist(
    (set) => ({
      messages: [],
      addMessage: (msg) =>
        set((s) => ({
          messages: [...s.messages, { ...msg, id: crypto.randomUUID() }],
        })),
      clearMessages: () => set({ messages: [] }),
    }),
    { name: 'voicer-chat' }
  )
)
```

### 5.4 语音识别 Hook

```ts
// src/hooks/useSpeechRecognition.ts
import { useState, useCallback } from 'react'

export function useSpeechRecognition() {
  const [transcript, setTranscript] = useState('')
  const [isListening, setIsListening] = useState(false)

  const start = useCallback(() => {
    const SR =
      window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SR) return

    const recognition = new SR()
    recognition.lang = 'zh-CN'
    recognition.continuous = false
    recognition.interimResults = true

    recognition.onresult = (event: SpeechRecognitionEvent) => {
      setTranscript(event.results[0][0].transcript)
    }

    recognition.onend = () => setIsListening(false)
    recognition.onerror = () => setIsListening(false)

    recognition.start()
    setIsListening(true)
  }, [])

  return { transcript, isListening, start }
}
```

### 5.5 LLM 服务（无服务端）

```ts
// src/services/llm.ts
// MVP 采用 Mock + Ollama 双轨模式，无需任何服务器

interface LLMConfig {
  provider: 'mock' | 'ollama'
  ollamaUrl?: string
  model?: string
}

const MOCK_RESPONSES = [
  '好的，我已经记下了。',
  '有意思，请继续说。',
  '我明白你的意思了。',
]

export async function sendToLLM(
  _messages: { role: string; content: string }[],
  config: LLMConfig
): Promise<string> {
  // Mock 模式：无需配置，立即可用
  if (config.provider === 'mock') {
    await new Promise(r => setTimeout(r, 800 + Math.random() * 700))
    return MOCK_RESPONSES[Math.floor(Math.random() * MOCK_RESPONSES.length)]
  }

  // Ollama 模式：调用本地 LLM
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

### 5.6 CSS Token 系统

```css
/* src/styles/tokens.css */
:root {
  --color-bg: oklch(98% 0 0);
  --color-surface: oklch(100% 0 0);
  --color-text: oklch(18% 0 0);
  --color-text-secondary: oklch(55% 0 0);
  --color-accent: oklch(68% 0.21 250);
  --color-user-msg: oklch(92% 0 0);
  --color-assistant-msg: oklch(95% 0 0);
  --color-border: oklch(88% 0 0);

  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-sm: 0.875rem;

  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;

  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 20px;
  --radius-full: 9999px;

  --shadow-sm: 0 1px 3px oklch(0% 0 0 / 0.1);
  --shadow-md: 0 4px 12px oklch(0% 0 0 / 0.1);

  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
}
```

---

## 6. iWatch 实现（最小化）

### 6.1 Package.swift

```swift
// packages/watch/Package.swift
import PackageDescription

let package = Package(
    name: "VoicerWatch",
    platforms: [
        .watchOS("10.0")
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "VoicerWatch",
            dependencies: [],
            path: "Sources"
        )
    ]
)
```

### 6.2 iWatch 主界面

```swift
// packages/watch/Sources/WatchApp.swift
import SwiftUI

@main
struct VoicerWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}

struct WatchContentView: View {
    @State private var transcript = ""
    @State private var isListening = false

    var body: some View {
        VStack(spacing: 16) {
            if isListening {
                Image(systemName: "waveform")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                    .padding()
            } else {
                Image(systemName: "mic.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.accentColor)
                    .padding()
            }

            Text(transcript.isEmpty ? "按住说话" : transcript)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 24) {
                Button("电话") {
                    // TODO: 发起电话
                }
                .buttonStyle(.bordered)

                Button {
                    toggleListening()
                } label: {
                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(isListening ? .red : .accentColor)
            }
        }
    }

    private func toggleListening() {
        isListening.toggle()
        // TODO: 调用 WatchKit 语音识别
    }
}
```

---

## 7. 验证标准

### M1 完成后（iPhone 原型）
- [ ] `swift build` 无报错
- [ ] `swift run Voicer` 启动 App 窗口
- [ ] 可输入文本，收到 LLM 回复
- [ ] 语音识别输出文本

### M2 完成后（Web 原型）
- [ ] `pnpm dev` 启动无报错
- [ ] 浏览器可对话（文本）
- [ ] 语音按钮可触发识别
- [ ] AI 回复自动播报
- [ ] 移动端响应式正常

### M3 完成后（iWatch 原型）
- [ ] `swift run VoicerWatch` 可运行（watchOS Simulator）
- [ ] 语音输入正常
- [ ] 电话按钮存在

---

## 8. 风险与缓解

| 风险 | 影响 | 缓解 |
|------|------|------|
| watchOS 开发需 macOS | 环境限制 | 开发阶段用 iPhone + Simulator 替代 |
| Swift Web Speech API | iOS 16+ 支持 | 降级到手动输入 |
| 跨平台代码共享 | 三套代码 | 长期考虑 WASM 模块化 |
| API Key 安全 | 数据安全 | iPhone 用 Keychain，Web 用后端代理 |
| Capacitor 打包 iOS | 性能 | M1/M2 后评估是否改用 RN |

---

## 9. 待确认事项

1. **LLM 默认提供商**：OpenAI GPT-4o Mini / Claude 3.5 Haiku / 本地模型？
2. **数据同步方案**：iCloud（Apple 原生）/ 自建 API？
3. **Swift 共享模块**：iPhone 和 iWatch 是否有公共代码需要抽取为 Package？
4. **Web 部署目标**：Vercel / Cloudflare Pages / 自建？
5. **电话功能实现**：Twilio / WebRTC / iOS CallKit（仅 iPhone 原生）？
