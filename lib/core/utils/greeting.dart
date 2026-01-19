import 'dart:math';

/// Get time-based greeting message with variety
///
/// Returns a random greeting appropriate for the current time of day
/// to provide a more personalized and engaging experience.
String getGreeting() {
  final hour = DateTime.now().hour;
  final random = Random();

  if (hour < 6) {
    // Late night / very early morning (0-5)
    const greetings = [
      'Night Owl',
      'Still Up?',
      'Burning Midnight Oil',
      'Sweet Dreams',
    ];
    return greetings[random.nextInt(greetings.length)];
  } else if (hour < 12) {
    // Morning (6-11)
    const greetings = [
      'Good Morning',
      'Rise and Shine',
      'Morning Sunshine',
      'Fresh Start',
      'Hello, Morning',
      'Lovely Morning',
    ];
    return greetings[random.nextInt(greetings.length)];
  } else if (hour < 14) {
    // Noon (12-13)
    const greetings = [
      'Good Afternoon',
      'Lunch Time',
      'Midday Vibes',
      'High Noon',
    ];
    return greetings[random.nextInt(greetings.length)];
  } else if (hour < 18) {
    // Afternoon (14-17)
    const greetings = [
      'Good Afternoon',
      'Afternoon Delight',
      'Keep Going',
      'Afternoon Breeze',
      'Productive Day',
    ];
    return greetings[random.nextInt(greetings.length)];
  } else if (hour < 21) {
    // Evening (18-20)
    const greetings = [
      'Good Evening',
      'Evening Star',
      'Sunset Glow',
      'Peaceful Evening',
      'Twilight Time',
    ];
    return greetings[random.nextInt(greetings.length)];
  } else {
    // Night (21-23)
    const greetings = [
      'Good Night',
      'Sweet Night',
      'Starry Night',
      'Night Falls',
      'Moonlit Evening',
    ];
    return greetings[random.nextInt(greetings.length)];
  }
}

/// Get a simple, stable greeting (for widget or non-animated contexts)
String getSimpleGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 18) return 'Good Afternoon';
  return 'Good Evening';
}
