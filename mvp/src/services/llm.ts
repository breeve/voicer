const MOCK_RESPONSES = [
  '好的，我已经记下了。',
  '有意思，请继续说。',
  '我明白你的意思了。',
  '这个问题很有趣，让我思考一下。',
  '你可以试着这样做。',
  '嗯，我理解你的需求。',
  '让我来帮你分析一下这个问题。',
]

interface LLMConfig {
  provider: 'mock' | 'ollama'
  ollamaUrl: string
  model: string
}

export async function sendToLLM(
  _messages: { role: string; content: string }[],
  config: LLMConfig
): Promise<string> {
  if (config.provider === 'mock') {
    await new Promise((r) => setTimeout(r, 800 + Math.random() * 700))
    return MOCK_RESPONSES[Math.floor(Math.random() * MOCK_RESPONSES.length)]
  }

  try {
    const response = await fetch(`${config.ollamaUrl}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: config.model || 'llama3.2',
        messages: _messages,
      }),
    })

    if (!response.ok) throw new Error('Ollama request failed')
    const data = await response.json()
    return data.message?.content ?? '（无回复）'
  } catch {
    return '抱歉，LLM 服务暂时不可用。'
  }
}
