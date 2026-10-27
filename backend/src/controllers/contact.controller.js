/**
 * Contact Controller
 * Validates incoming contact form requests, performs honeypot anti-bot verification,
 * and delegates to contactService for email dispatch.
 */

const contactService = require('../services/contact.service');

// Standard allowed subjects
const ALLOWED_SUBJECTS = [
  'General Inquiry',
  'IPO Allotment Support',
  'SpotAI Feedback',
  'Bug Report / Feature Request',
  'Partnership & Press',
  'Other',
];

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

async function submitContact(req, res, next) {
  try {
    const { name, email, subject, message, hp, _honeypot, website } = req.body || {};

    // 1. Honeypot Anti-Bot Verification
    // Legitimate users will not fill out invisible honeypot inputs.
    if (hp || _honeypot || website) {
      console.warn('[CONTACT_BOT_BLOCKED]', {
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        honeypotValue: hp || _honeypot || website,
      });
      return res.status(400).json({
        success: false,
        error: 'BOT_DETECTED',
        message: 'Spam submission blocked.',
      });
    }

    // 2. Server-Side Input Validation
    const errors = [];

    // Name validation
    const trimmedName = typeof name === 'string' ? name.trim() : '';
    if (!trimmedName || trimmedName.length < 2) {
      errors.push({ field: 'name', message: 'Name must be at least 2 characters.' });
    } else if (trimmedName.length > 100) {
      errors.push({ field: 'name', message: 'Name must not exceed 100 characters.' });
    }

    // Email validation
    const trimmedEmail = typeof email === 'string' ? email.trim() : '';
    if (!trimmedEmail) {
      errors.push({ field: 'email', message: 'Email is required.' });
    } else if (!EMAIL_REGEX.test(trimmedEmail) || trimmedEmail.length > 150) {
      errors.push({ field: 'email', message: 'Please enter a valid email address.' });
    }

    // Subject validation
    const trimmedSubject = typeof subject === 'string' ? subject.trim() : '';
    if (!trimmedSubject) {
      errors.push({ field: 'subject', message: 'Please select or provide a subject.' });
    } else if (trimmedSubject.length > 120) {
      errors.push({ field: 'subject', message: 'Subject must not exceed 120 characters.' });
    }

    // Message validation
    const trimmedMessage = typeof message === 'string' ? message.trim() : '';
    if (!trimmedMessage || trimmedMessage.length < 10) {
      errors.push({ field: 'message', message: 'Message must be at least 10 characters long.' });
    } else if (trimmedMessage.length > 4000) {
      errors.push({ field: 'message', message: 'Message must not exceed 4000 characters.' });
    }

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'VALIDATION_FAILED',
        message: 'Please correct the highlighted form errors.',
        errors,
      });
    }

    // 3. Delegate to Contact Email Service
    const clientIp = req.ip || req.headers['x-forwarded-for'] || req.connection?.remoteAddress;

    try {
      const result = await contactService.sendContactEmail({
        name: trimmedName,
        email: trimmedEmail,
        subject: trimmedSubject,
        message: trimmedMessage,
        clientIp,
      });

      return res.status(200).json({
        success: true,
        message: 'Thank you! Your message has been sent successfully. Our team will review and reply promptly.',
        messageId: result.messageId,
      });
    } catch (serviceErr) {
      // Return friendly 503 if SMTP is not configured
      if (serviceErr.status === 503 || serviceErr.code === 'SMTP_NOT_CONFIGURED' || serviceErr.code === 'SMTP_MODULE_MISSING') {
        return res.status(503).json({
          success: false,
          error: 'SERVICE_UNAVAILABLE',
          message:
            'Contact email delivery is currently unconfigured or unavailable. Please reach out directly to support@thespotmarket.com.',
        });
      }

      console.error('[CONTACT_DISPATCH_ERROR]', serviceErr);
      return res.status(500).json({
        success: false,
        error: 'DELIVERY_FAILED',
        message: 'An error occurred while sending your message. Please try again or email us directly at support@thespotmarket.com.',
      });
    }
  } catch (err) {
    next(err);
  }
}

module.exports = {
  submitContact,
  ALLOWED_SUBJECTS,
};
