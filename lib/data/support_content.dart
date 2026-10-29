import 'package:flutter/material.dart';

/// Static copy for Help, Safety centre and Terms & privacy. Replace with CMS content later.

class Faq {
  final String category, question, answer;
  const Faq(this.category, this.question, this.answer);
}

const faqCategories = ['All', 'Account', 'Profile', 'Matching', 'Safety', 'Payments'];

const faqs = [
  Faq('Account', 'How do I change my email or phone number?',
      'Go to Settings → Email & phone, tap the one you want to change and enter the new value. We’ll send a 6-digit code to confirm it.'),
  Faq('Account', 'How do I delete my account?',
      'Go to Settings and tap “Delete account” at the bottom. This permanently removes your profile, matches and messages.'),
  Faq('Account', 'I can’t sign in. What should I do?',
      'Check that you’re using the email you signed up with, then tap “Forgot password?” on the sign-in screen. Still stuck? Contact support below.'),
  Faq('Profile', 'How do I edit my profile?',
      'Open the Profile tab and tap “Edit profile”. Every section — bio, teasers, hobbies, places and more — can be changed there.'),
  Faq('Profile', 'Why should I verify my profile?',
      'Verified profiles get a blue badge and around twice as many likes. It takes a short selfie video and less than a minute.'),
  Faq('Profile', 'How many photos can I add?',
      'You can add up to 6 photos. Your first photo is your main photo — long-press to reorder them.'),
  Faq('Matching', 'How does matching work?',
      'Swipe right to like and left to pass. When someone you liked likes you back, it’s a match and you can start chatting.'),
  Faq('Matching', 'Why am I not seeing many people?',
      'Try widening your age range or distance in Preferences. Filters like height or lifestyle can also narrow your feed.'),
  Faq('Matching', 'Can I undo a swipe?',
      'Yes — use Rewind on the Discover screen to bring back the last profile you swiped.'),
  Faq('Safety', 'How do I report someone?',
      'Open their profile, tap ••• and choose Report. You can also report from the Safety centre. Reports are anonymous.'),
  Faq('Safety', 'What happens when I block someone?',
      'They can no longer see your profile, match with you or message you. They aren’t notified. You can unblock them in Settings → Blocked profiles.'),
  Faq('Payments', 'How do I cancel my subscription?',
      'Subscriptions are managed through the App Store or Google Play. Cancel there at least 24 hours before renewal.'),
  Faq('Payments', 'Can I get a refund?',
      'Refunds are handled by the App Store or Google Play under their policies. Contact support and we’ll help where we can.'),
];

class SafetyTip {
  final IconData icon; final String title, body;
  const SafetyTip(this.icon, this.title, this.body);
}

const meetingTips = [
  SafetyTip(Icons.storefront_outlined, 'Meet in a public place',
      'Choose a busy café, restaurant or mall for the first few dates. Never meet at your home or theirs.'),
  SafetyTip(Icons.share_location_outlined, 'Tell a friend your plans',
      'Share who you’re meeting, where and when. Check in with them during and after the date.'),
  SafetyTip(Icons.directions_car_outlined, 'Arrange your own ride',
      'Get yourself to and from the date so you can leave whenever you want.'),
  SafetyTip(Icons.local_bar_outlined, 'Stay in control',
      'Know your limits and keep your drink with you. If you feel uncomfortable, it’s okay to leave.'),
];

const onlineTips = [
  SafetyTip(Icons.payments_outlined, 'Never send money',
      'No matter the story, never send money, gift cards or bank details to someone you met online.'),
  SafetyTip(Icons.lock_outline_rounded, 'Protect personal info',
      'Keep your home address, workplace and financial details private until you truly trust someone.'),
  SafetyTip(Icons.chat_outlined, 'Keep chats on Amour',
      'Scammers often push to move to other apps quickly. Staying here keeps reporting tools in reach.'),
  SafetyTip(Icons.verified_user_outlined, 'Look for the verified badge',
      'Verified members have proven they match their photos. Ask for a video call before meeting.'),
];

const helplines = [
  (Icons.emergency_outlined, 'Emergency', '112'),
  (Icons.support_agent_outlined, 'Women helpline', '181'),
  (Icons.security_outlined, 'Cyber crime helpline', '1930'),
];

const reportReasons = [
  (Icons.person_off_outlined, 'Fake profile or scam'),
  (Icons.no_photography_outlined, 'Inappropriate photos'),
  (Icons.report_outlined, 'Harassment or threats'),
  (Icons.child_care_outlined, 'May be under 18'),
  (Icons.more_horiz_rounded, 'Something else'),
];

class PolicySection {
  final String title, body;
  const PolicySection(this.title, this.body);
}

const policyUpdated = '1 October 2026';

const termsSections = [
  PolicySection('Who can use Amour',
      'You must be at least 18 years old and legally able to enter this agreement. One account per person.'),
  PolicySection('Your account',
      'Keep your sign-in details secure. You’re responsible for activity on your account and for keeping your information accurate.'),
  PolicySection('Community rules',
      'Be respectful. No harassment, hate speech, nudity, scams, impersonation or commercial promotion. We may remove content or accounts that break these rules.'),
  PolicySection('Your content',
      'You own what you post. By posting, you let us display it within Amour so others can see your profile.'),
  PolicySection('Purchases',
      'Subscriptions renew automatically until cancelled through your app store. Prices may vary by region.'),
  PolicySection('Ending your account',
      'You can delete your account at any time from Settings. We may suspend accounts that violate these terms.'),
  PolicySection('Liability',
      'Amour isn’t responsible for the conduct of members on or off the app. Always follow our safety tips when meeting someone.'),
];

const privacySections = [
  PolicySection('What we collect',
      'Information you give us (name, birthday, photos, profile answers, email, phone), how you use Amour, and approximate location to show people near you.'),
  PolicySection('How we use it',
      'To run your account, suggest matches, keep the community safe, prevent fraud and improve the app.'),
  PolicySection('What others see',
      'Your profile — first name, age, photos and the details you add. Your email, phone number and exact location are never shown.'),
  PolicySection('Sharing',
      'We don’t sell your data. We share it only with service providers who help run Amour, or when the law requires it.'),
  PolicySection('Verification data',
      'Selfie videos are used only to confirm you match your photos and are deleted once verification is complete.'),
  PolicySection('Your choices',
      'Edit your profile any time, hide your online status, download a copy of your data or delete your account from Settings.'),
  PolicySection('Retention',
      'We keep your data while your account is active and delete it within 30 days of account deletion, except where the law requires longer.'),
];

const supportEmail = 'support@amour.app';
