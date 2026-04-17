export interface LLMMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export type LLMProvider = 'mock' | 'ollama'

export interface LLMConfig {
  provider: LLMProvider
  ollamaUrl?: string
  model?: string
}

const MOCK_RESPONSES = [
  '好的，我已经记下了。有什么需要帮忙的吗？',
  '有意思，请继续说。',
  '我明白你的意思了。让我想想怎么帮你。',
  '这个问题很有趣，让我思考一下。',
  '你可以试着这样做。',
  '没问题，我来帮你处理。',
  '让我查一下相关信息。',
  '明白了，这是个不错的想法。',
  '好的，我会帮你记住这个。',
  '了解，有什么其他需要吗？',
]

export async function sendToLLM(
  messages: LLMMessage[],
  config: LLMConfig
): Promise<string> {
  if (config.provider === 'mock') {
    // Simulate thinking delay
    await new Promise((r) => setTimeout(r, 800 + Math.random() * 700))
    return MOCK_RESPONSES[Math.floor(Math.random() * MOCK_RESPONSES.length)]
  }

  // Ollama mode
  const url = `${config.ollamaUrl}/api/chat`
  const model = config.model || 'llama3.2'

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model,
        messages,
        stream: false,
      }),
    })

    if (!response.ok) {
      throw new Error(`Ollama API error: ${response.status}`)
    }

    const data = await response.json()
    return data.message?.content ?? ''
  } catch (err) {
    console.error('LLM request failed:', err)
    return '抱歉，无法连接到 LLM 服务，请检查 Ollama 是否正在运行。'
  }
}