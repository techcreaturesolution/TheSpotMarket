const axios = require('axios');

const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-1.5-flash';
const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';

async function generateChatReply({ system, messages }) {
  const apiKey = (process.env.AI_API_KEY || process.env.OPENAI_API_KEY || process.env.GEMINI_API_KEY || '').trim();
  const provider = (process.env.AI_PROVIDER || (apiKey.startsWith('sk-') ? 'openai' : 'gemini')).toLowerCase();

  if (!apiKey) {
    const err = new Error('AI API key is not configured on the server.');
    err.code = 'AI_NOT_CONFIGURED';
    err.statusCode = 503;
    throw err;
  }

  // Input validation
  if (!Array.isArray(messages) || messages.length === 0) {
    const err = new Error('Invalid request: messages must be a non-empty array.');
    err.code = 'INVALID_INPUT';
    err.statusCode = 400;
    throw err;
  }

  if (messages.length > 30) {
    const err = new Error('Conversation history too long. Maximum 30 messages allowed.');
    err.code = 'PAYLOAD_TOO_LARGE';
    err.statusCode = 413;
    throw err;
  }

  // Normalize and validate message entries
  const normalizedMessages = [];
  for (const msg of messages) {
    if (!msg || typeof msg !== 'object') continue;
    const rawText = typeof msg.text === 'string' ? msg.text : (typeof msg.content === 'string' ? msg.content : '');
    const text = rawText.trim();
    if (!text) continue;
    const role = (msg.role === 'model' || msg.role === 'assistant') ? 'assistant' : 'user';
    normalizedMessages.push({ role, text: text.slice(0, 4000) });
  }

  if (normalizedMessages.length === 0) {
    const err = new Error('Invalid request: at least one message with non-empty text is required.');
    err.code = 'INVALID_INPUT';
    err.statusCode = 400;
    throw err;
  }

  // Handle OpenAI provider (e.g. sk-proj-... keys)
  if (provider === 'openai' || apiKey.startsWith('sk-')) {
    const openAiMessages = [];
    if (system && typeof system === 'string' && system.trim().length > 0) {
      openAiMessages.push({ role: 'system', content: system.trim().slice(0, 2000) });
    }
    for (const msg of normalizedMessages) {
      openAiMessages.push({ role: msg.role, content: msg.text });
    }

    try {
      const response = await axios.post('https://api.openai.com/v1/chat/completions', {
        model: OPENAI_MODEL,
        temperature: 0.4,
        max_tokens: 600,
        messages: openAiMessages
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        timeout: 15000
      });

      const replyText = response.data?.choices?.[0]?.message?.content?.trim();
      if (!replyText) throw new Error('OpenAI returned empty reply.');
      return replyText;
    } catch (error) {
      if (error.response) {
        const status = error.response.status;
        console.warn(`[AI_SERVICE] Upstream OpenAI error HTTP ${status}`);
        const err = new Error(status === 429 ? 'AI rate limit reached. Please try again later.' : 'AI service temporarily unavailable.');
        err.code = status === 429 ? 'AI_RATE_LIMIT' : 'UPSTREAM_ERROR';
        err.statusCode = status === 429 ? 429 : 502;
        throw err;
      }
      throw error;
    }
  }

  // Handle Google Gemini provider
  const sanitizedContents = [];
  for (const msg of normalizedMessages) {
    const role = msg.role === 'assistant' ? 'model' : 'user';
    sanitizedContents.push({
      role,
      parts: [{ text: msg.text }]
    });
  }

  const payload = {
    contents: sanitizedContents,
    generationConfig: {
      temperature: 0.4,
      maxOutputTokens: 600
    }
  };

  if (system && typeof system === 'string' && system.trim().length > 0) {
    payload.system_instruction = {
      parts: [{ text: system.trim().slice(0, 2000) }]
    };
  }

  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

  try {
    const response = await axios.post(geminiUrl, payload, {
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey
      },
      timeout: 15000
    });

    const candidates = response.data?.candidates;
    if (!Array.isArray(candidates) || candidates.length === 0) {
      throw new Error('Gemini returned no candidates.');
    }

    const parts = candidates[0]?.content?.parts;
    if (!Array.isArray(parts)) {
      throw new Error('Invalid response structure from Gemini.');
    }

    const replyText = parts.map(p => (typeof p.text === 'string' ? p.text : '')).join('').trim();
    return replyText;
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      console.warn(`[AI_SERVICE] Upstream Gemini error HTTP ${status}`);
      const err = new Error(status === 429 ? 'AI rate limit reached. Please try again in a few moments.' : 'AI service temporarily unavailable.');
      err.code = status === 429 ? 'AI_RATE_LIMIT' : 'UPSTREAM_ERROR';
      err.statusCode = status === 429 ? 429 : 502;
      throw err;
    }

    if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
      console.warn('[AI_SERVICE] Upstream AI request timed out');
      const err = new Error('AI request timed out. Please try again.');
      err.code = 'GATEWAY_TIMEOUT';
      err.statusCode = 504;
      throw err;
    }

    console.error(`[AI_SERVICE] Error: ${error.message}`);
    const err = new Error('Failed to generate AI response.');
    err.code = 'AI_ERROR';
    err.statusCode = 500;
    throw err;
  }
}

module.exports = {
  generateChatReply
};
