import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Central email service — sends directly via Gmail SMTP.
/// No system mail app opened. Everything happens inside the app silently.
///
/// ⚠️  SECURITY NOTE:
/// These credentials belong to a SENDER-ONLY Gmail account you create
/// specifically for this app. Never use your personal Gmail credentials here.
/// The receiver (nayatech.myanmar@gmail.com) is separate — it only receives.
class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();

  // ── Sender account (create a dedicated Gmail just for sending) ────────────
  // Create a new Gmail: e.g. "perfectenglish.noreply@gmail.com"
  // Enable 2FA → generate an App Password → paste it below (no spaces)
  static const String _senderEmail = 'perfectenglish.noreply@gmail.com';
  static const String _senderAppPassword = 'ysdaufckgqsytbyc';
  static const String _senderName = 'Perfect English NoReply';

  // ── Receiver ──────────────────────────────────────────────────────────────
  static const String _receiverEmail = 'nayatech.myanmar@gmail.com';
  static const String _receiverName = 'NaYa Myanmar';

  /// Sends a custom app request email.
  /// Returns null on success, error message string on failure.
  Future<String?> sendCustomAppRequest({
    required String fromName,
    required String fromEmail,
    required String requirements,
  }) async {
    final subject = '[$fromName] စိတ်ကြိုက် App တောင်းဆိုမှု';

    final htmlBody =
        '''
<html><body style="font-family: Arial, sans-serif; color: #333;">
  <h2 style="color: #2196F3;">🆕 စိတ်ကြိုက် Application တောင်းဆိုမှု</h2>
  <table style="border-collapse: collapse; width: 100%;">
    <tr>
      <td style="padding: 8px; font-weight: bold; width: 140px;">အမည်:</td>
      <td style="padding: 8px;">$fromName</td>
    </tr>
    <tr style="background: #f5f5f5;">
      <td style="padding: 8px; font-weight: bold;">အီးမေး:</td>
      <td style="padding: 8px;"><a href="mailto:$fromEmail">$fromEmail</a></td>
    </tr>
    <tr>
      <td style="padding: 8px; font-weight: bold; vertical-align: top;">လိုအပ်ချက်:</td>
      <td style="padding: 8px; white-space: pre-wrap;">$requirements</td>
    </tr>
    <tr style="background: #f5f5f5;">
      <td style="padding: 8px; font-weight: bold;">ပေးပို့ချိန်:</td>
      <td style="padding: 8px;">${DateTime.now().toString().substring(0, 19)}</td>
    </tr>
  </table>
  <hr/>
  <p style="color: #888; font-size: 12px;">
    အချေးအငှား App မှ အလိုအလျောက် ပေးပို့သော မက်ဆေ့ဂျ်ဖြစ်ပါသည်။
  </p>
</body></html>
''';

    return _sendEmail(
      subject: subject,
      htmlBody: htmlBody,
      replyToEmail: fromEmail,
      replyToName: fromName,
    );
  }

  /// Sends a feedback email.
  /// Returns null on success, error message string on failure.
  Future<String?> sendFeedback({required String feedbackText}) async {
    const subject = '💬 အချေးအငှား App — အကြံပြုချက်';

    final htmlBody =
        '''
<html><body style="font-family: Arial, sans-serif; color: #333;">
  <h2 style="color: #4CAF50;">💬 အသုံးပြုသူ အကြံပြုချက်</h2>
  <div style="background: #f9f9f9; border-left: 4px solid #4CAF50;
              padding: 16px; margin: 16px 0; border-radius: 4px;">
    <p style="white-space: pre-wrap; margin: 0;">$feedbackText</p>
  </div>
  <table style="border-collapse: collapse; width: 100%;">
    <tr style="background: #f5f5f5;">
      <td style="padding: 8px; font-weight: bold; width: 120px;">ပေးပို့ချိန်:</td>
      <td style="padding: 8px;">${DateTime.now().toString().substring(0, 19)}</td>
    </tr>
  </table>
  <hr/>
  <p style="color: #888; font-size: 12px;">
    အချေးအငှား App မှ အလိုအလျောက် ပေးပို့သော မက်ဆေ့ဂျ်ဖြစ်ပါသည်။
  </p>
</body></html>
''';

    return _sendEmail(subject: subject, htmlBody: htmlBody);
  }

  /// Core send method — shared by all public methods.
  Future<String?> _sendEmail({
    required String subject,
    required String htmlBody,
    String? replyToEmail,
    String? replyToName,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _senderAppPassword);

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(Address(_receiverEmail, _receiverName))
        ..subject = subject
        ..html = htmlBody;

      // Add reply-to so NaYa can reply directly to the user
      if (replyToEmail != null) {
        message.headers['Reply-To'] = replyToEmail;
      }

      await send(message, smtpServer);
      return null; // null = success
    } on MailerException catch (e) {
      final problems = e.problems.map((p) => p.msg).join(', ');
      return 'Mail error: $problems';
    } catch (e) {
      return 'Connection error: $e';
    }
  }
}
