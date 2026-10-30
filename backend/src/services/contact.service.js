/**
 * Contact Service
 * Handles outbound email delivery for website contact form inquiries via nodemailer.
 * If SMTP credentials are not configured, throws an informative 503 error.
 */

const env = require('../config/env');

function isSmtpConfigured() {
  return Boolean(env.SMTP_HOST && env.SMTP_USER && env.SMTP_PASS);
}

/**
 * Send an email notification for a user contact submission
 * @param {Object} data
 * @param {string} data.name - Submitter name
 * @param {string} data.email - Submitter email address
 * @param {string} data.subject - Category / subject
 * @param {string} data.message - Body text
 * @param {string} [data.clientIp] - Client IP address
 * @returns {Promise<{success: boolean, messageId?: string}>}
 */
async function sendContactEmail({ name, email, subject, message, clientIp }) {
  if (!isSmtpConfigured()) {
    const error = new Error(
      'Email delivery service is currently unconfigured on this server. Please write to thespotmarket29@gmail.com directly.'
    );
    error.code = 'SMTP_NOT_CONFIGURED';
    error.status = 503;
    throw error;
  }

  let nodemailer;
  try {
    nodemailer = require('nodemailer');
  } catch (err) {
    const error = new Error('Nodemailer library is not available. Please write to thespotmarket29@gmail.com directly.');
    error.code = 'SMTP_MODULE_MISSING';
    error.status = 503;
    throw error;
  }

  const transporter = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE,
    auth: {
      user: env.SMTP_USER,
      pass: env.SMTP_PASS,
    },
    // Timeout limits to avoid hanging connections
    connectionTimeout: 10000,
    greetingTimeout: 5000,
    socketTimeout: 15000,
  });

  const timestamp = new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' });

  const mailOptions = {
    from: `"TheSpotMarket Contact Form" <${env.SMTP_USER}>`,
    replyTo: `"${name}" <${email}>`,
    to: env.CONTACT_TO_EMAIL,
    subject: `[TheSpotMarket Contact] ${subject} - from ${name}`,
    text: `New Contact Submission from TheSpotMarket Website:

Name: ${name}
Email: ${email}
Subject: ${subject}
Date: ${timestamp} IST
IP: ${clientIp || 'Unknown'}

Message:
----------------------------------------
${message}
----------------------------------------
`,
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; background: #040A07; color: #FFFFFF; border-radius: 12px; border: 1px solid #10B981;">
        <h2 style="color: #10B981; margin-top: 0;">New Contact Form Submission</h2>
        <table style="width: 100%; border-collapse: collapse; margin: 16px 0; color: #E5E7EB; font-size: 14px;">
          <tr>
            <td style="padding: 8px 0; font-weight: bold; width: 100px; color: #34D399;">Name:</td>
            <td style="padding: 8px 0;">${escapeHtml(name)}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; font-weight: bold; color: #34D399;">Email:</td>
            <td style="padding: 8px 0;"><a href="mailto:${escapeHtml(email)}" style="color: #10B981;">${escapeHtml(email)}</a></td>
          </tr>
          <tr>
            <td style="padding: 8px 0; font-weight: bold; color: #34D399;">Subject:</td>
            <td style="padding: 8px 0;">${escapeHtml(subject)}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; font-weight: bold; color: #34D399;">Received:</td>
            <td style="padding: 8px 0;">${timestamp} IST (IP: ${escapeHtml(clientIp || 'N/A')})</td>
          </tr>
        </table>
        <div style="margin-top: 16px; padding: 16px; background: #0C1610; border-radius: 8px; border: 1px solid rgba(255,255,255,0.1);">
          <h4 style="margin: 0 0 8px 0; color: #34D399;">Message:</h4>
          <p style="white-space: pre-wrap; margin: 0; line-height: 1.6; color: #D1D5DB;">${escapeHtml(message)}</p>
        </div>
        <p style="font-size: 11px; color: #6B7280; margin-top: 24px; text-align: center;">
          Sent securely from TheSpotMarket Website Contact Engine
        </p>
      </div>
    `,
  };

  const info = await transporter.sendMail(mailOptions);
  return {
    success: true,
    messageId: info.messageId,
  };
}

function escapeHtml(str) {
  if (typeof str !== 'string') return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

module.exports = {
  isSmtpConfigured,
  sendContactEmail,
};
