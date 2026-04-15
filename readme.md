# voicer

一个跨平台语音交互 App，支持 iPhone、iWatch、Web（macOS/Windows）。

## 平台与技术

| 平台 | 技术栈 | 说明 |
|------|--------|------|
| **iPhone** | Swift + SwiftUI | 原生 App，可直接 `swift build` 运行 |
| **iWatch** | Swift + SwiftUI | iPhone 补充，提供最小对话和电话能力 |
| **Web** | React + TypeScript + Capacitor | 跨平台 macOS / Windows / Linux 浏览器 |

## 核心功能

1. **语音交互**
   - 语音输入（STT）
   - 语音播报（TTS）
   - 对话式交互

2. **搜索与 LLM**
   - 本地资源搜索（音频、文本）
   - 接入 LLM，支持自定义配置（OpenAI / Claude）

3. **闹钟设置**

4. **多端同步**
   - iPhone 为主设备
   - iWatch 为辅助交互
   - Web 端随时访问

## 对话形象

可自定义：
- 头像
- 音色
- 性格
- 兴趣偏好

## 配置入口

- 形象展示框右上角按钮
- 语音输入后跳转

## 快速开始

### Web

```bash
cd packages/web
pnpm install
pnpm dev
```

### iPhone (Swift)

```bash
cd packages/ios
swift build
swift run Voicer
```

### iWatch (Swift)

```bash
cd packages/watch
swift build
swift run VoicerWatch
```

## 项目结构

```
voicer/
├── readme.md
├── docs/
│   └── DESIGN.md
└── packages/
    ├── web/          # React + Capacitor
    ├── ios/          # Swift + SwiftUI (iPhone)
    └── watch/        # Swift + SwiftUI (iWatch)
```
