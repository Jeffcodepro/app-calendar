require "net/http"
require "json"

class OpenaiClient
  API_URL = "https://api.openai.com/v1/chat/completions".freeze

  def self.generate_destination_text(destination:, month:, avoid: [])
    key = ENV["OPENAI_API_KEY"]
    return nil if key.to_s.strip.empty?

    avoid_text = avoid.any? ? "Nao repita este texto: #{avoid.join(' | ')}." : ""
    prompt = <<~PROMPT
      Voce e um avaliador de destinos. Gere um texto curto (2 frases) explicando o local "#{destination}" e por que e uma otima escolha para o mes de #{month}. Seja direto e objetivo. #{avoid_text}
    PROMPT

    payload = {
      model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
      messages: [
        { role: "system", content: "Responda em portugues do Brasil, sem usar emojis." },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 80
    }

    uri = URI(API_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{key}"
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(payload)

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.read_timeout = 8
    http.open_timeout = 8
    http.verify_mode = if ENV["OPENAI_INSECURE_SSL"] == "true"
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("OpenAI error: status=#{response.code} body=#{response.body}")
      return nil
    end

    body = JSON.parse(response.body)
    body.dig("choices", 0, "message", "content")
  rescue JSON::ParserError, SocketError, Errno::ECONNRESET
    nil
  end
end
