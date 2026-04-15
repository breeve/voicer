import Foundation

final class LLMRefiner: @unchecked Sendable {
    static let shared = LLMRefiner()

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "llmRefinerEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "llmRefinerEnabled") }
    }

    var apiBaseURL: String {
        get { UserDefaults.standard.string(forKey: "llmRefinerAPIBaseURL") ?? "https://api.openai.com/v1" }
        set { UserDefaults.standard.set(newValue, forKey: "llmRefinerAPIBaseURL") }
    }

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "llmRefinerAPIKey") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "llmRefinerAPIKey") }
    }

    var model: String {
        get { UserDefaults.standard.string(forKey: "llmRefinerModel") ?? "gpt-4o-mini" }
        set { UserDefaults.standard.set(newValue, forKey: "llmRefinerModel") }
    }

    var isConfigured: Bool { !apiKey.isEmpty }

    private var currentTask: URLSessionDataTask?

    private let systemPrompt = """
    You are a conservative speech recognition error corrector. \
    ONLY fix clear, obvious transcription mistakes. When in doubt, leave the text unchanged.

    What to fix:
    - English words/acronyms wrongly rendered as Chinese characters \
    (e.g. "配森" → "Python", "杰森" → "JSON", "阿皮爱" → "API")
    - Obvious Chinese homophone errors where context makes the correct character clear
    - Broken English words or phrases split/merged incorrectly by the recognizer

    What NOT to do:
    - Do NOT rephrase, rewrite, or "improve" any text
    - Do NOT add or remove words beyond fixing recognition errors
    - Do NOT change text that could plausibly be correct
    - Do NOT alter punctuation unless clearly wrong

    If the input appears correct, return it exactly as-is. Return ONLY the text, nothing else.
    """

    func refine(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard isEnabled && isConfigured else {
            completion(.success(text))
            return
        }

        let baseURL = apiBaseURL.hasSuffix("/") ? String(apiBaseURL.dropLast()) : apiBaseURL
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(RefinerError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text],
            ],
            "temperature": 0.3,
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        currentTask = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data else {
                DispatchQueue.main.async { completion(.failure(RefinerError.invalidResponse)) }
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String
            else {
                DispatchQueue.main.async { completion(.failure(RefinerError.invalidResponse)) }
                return
            }
            let refined = content.trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async { completion(.success(refined)) }
        }
        currentTask?.resume()
    }

    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }

    enum RefinerError: LocalizedError {
        case invalidURL
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid API base URL"
            case .invalidResponse: return "Invalid response from LLM API"
            }
        }
    }
}
