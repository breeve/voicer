# voicer

一个跨平台语音交互 App，支持 iPhone、iWatch、Web（macOS/Windows）。

**核心特点**：无服务端，所有功能在 App 内实现，开箱即用。

## 平台与技术

| 平台 | 技术栈 | 说明 |
|------|--------|------|
| **iPhone** | Swift + SwiftUI | 原生 App，可直接 `swift build` 运行 |
| **iWatch** | Swift + SwiftUI | iPhone 补充，提供最小对话和电话能力 |
| **Web** | React + TypeScript + Capacitor | 跨平台 macOS / Windows / Linux 桌面应用 |

## 核心功能

1. **语音交互**
   - 语音输入（STT）
   - 语音播报（TTS）
   - 对话式交互

2. **搜索与 LLM**
   - 本地资源搜索（音频、文本）
   - 接入 LLM，支持 Mock / Ollama（无需服务器）

3. **闹钟设置**

4. **多端协同**（无云端依赖）
   - iPhone 为主设备
   - iWatch 为辅助交互
   - Web 端随时使用

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

### Web（macOS / Windows / Linux）

```bash
cd packages/web
pnpm install
pnpm dev
```

打包为桌面应用：

```bash
npx cap sync
npx cap open
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

## LLM 配置

**默认**：Mock 响应模式，无需任何配置，立即可用。

**可选**：安装 [Ollama](https://ollama.com/) 后，在设置中填入 URL 和模型名称。

## 项目结构

```
voicer/
├── readme.md
├── docs/
│   ├── DESIGN.md      # 完整设计文档
│   └── MVP.md         # 最小原型实现计划
└── packages/
    ├── web/           # React + Capacitor（桌面 App）
    ├── ios/           # Swift + SwiftUI（iPhone）
    └── watch/         # Swift + SwiftUI（iWatch）
```
