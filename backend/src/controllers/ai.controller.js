const aiService = require('../services/ai.service');

async function chat(req, res, next) {
  try {
    const { system, messages, prompt } = req.body || {};

    let formattedMessages = messages;
    if (!formattedMessages && typeof prompt === 'string') {
      formattedMessages = [{ role: 'user', text: prompt }];
    }

    const reply = await aiService.generateChatReply({
      system,
      messages: formattedMessages
    });

    return res.json({
      success: true,
      text: reply,
      reply: reply
    });
  } catch (error) {
    const statusCode = error.statusCode || 500;
    return res.status(statusCode).json({
      success: false,
      error: error.code || 'AI_ERROR',
      message: error.message || 'Internal Server Error'
    });
  }
}

module.exports = {
  chat
};
