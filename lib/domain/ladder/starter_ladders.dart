import '../entities/ladder_step.dart';

/// Hand-written ladders. Used to seed the first launch and by the offline
/// breakdown service. Every ladder starts absurdly small on purpose.
class StarterLadders {
  StarterLadders._();

  static MicroStep _s(String text, [int? minutes]) => MicroStep(
    text,
    suggestedDuration: minutes == null ? null : Duration(minutes: minutes),
  );

  /// Title -> ladder, in the order the seed uses.
  static final Map<String, List<MicroStep>> byTitle = {
    'Just sit up': [
      _s('Lie on your back with your eyes open for 1 minute', 1),
      _s('Say out loud "I am going to sit up"', 1),
      _s('Prop yourself up on one elbow for 1 minute', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Sit on the edge of the bed with your feet on the floor for 2 minutes', 2),
      _s('Stand up and stay standing for 1 minute', 1),
    ],
    'Laundry': [
      _s('Think about laundry for 1 minute', 1),
      _s('Say out loud "I\'d like to do laundry"', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Stand in the doorway of the room with the pile', 2),
      _s('Sit next to the pile for 5 minutes', 5),
      _s('Put 3 items in the basket', 3),
      _s('Carry the basket to the machine', 5),
      _s('Start one load', 10),
      _s('Full laundry cycle', 30),
    ],
    'Shower': [
      _s('Think about a shower for 1 minute', 1),
      _s('Say out loud "a shower would be nice"', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Stand in the bathroom doorway', 2),
      _s('Turn the shower on and listen to it for a minute', 2),
      _s('Put a hand under the water', 2),
      _s('Rinse off, no soap needed', 5),
      _s('Full shower', 10),
    ],
    'Go outside': [
      _s('Look out of the window for 1 minute', 1),
      _s('Say out loud "I\'d like some air"', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Put socks on', 2),
      _s('Stand by the front door', 2),
      _s('Open the door and breathe for 1 minute', 1),
      _s('Stand on the step or balcony', 3),
      _s('Walk to the end of the street and back', 5),
      _s('A ten minute walk', 10),
    ],
    'Reply to someone': [
      _s('Think about the person for 1 minute', 1),
      _s('Say their name out loud and one thing you would say to them', 1),
      _s('Open the conversation and read it', 2),
      _s('Type one word and leave it in the draft', 2),
      _s('Send a one-line reply, no explanation needed', 3),
      _s('Send a proper reply', 5),
    ],
    'Eat something': [
      _s('Think of one food you could stand to eat', 1),
      _s('Say out loud "I could eat something"', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Walk to the kitchen and stand there', 2),
      _s('Drink a glass of water', 2),
      _s('Eat one bite of anything', 2),
      _s('Eat something small', 5),
      _s('Make and eat a simple meal', 15),
    ],
    'Dishes': [
      _s('Think about the dishes for 1 minute', 1),
      _s('Stand in the kitchen doorway', 2),
      _s('Stand at the sink with the water running for 1 minute', 1),
      _s('Wash one thing', 2),
      _s('Wash three things', 3),
      _s('Clear the sink', 10),
    ],
    'Brush teeth': [
      _s('Think about your teeth for 1 minute', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Stand at the bathroom sink', 2),
      _s('Put toothpaste on the brush', 1),
      _s('Brush for 30 seconds', 1),
      _s('Brush for 2 minutes', 2),
    ],
    'Get dressed': [
      _s('Sit up for 2 minutes', 2),
      _s('Pick one item of clothing and hold it', 1),
      _s('Put socks on', 1),
      _s('Change your top', 2),
      _s('Get fully dressed', 5),
    ],
  };

  /// Keyword groups used to match a free-text title to a starter ladder.
  static const Map<String, List<String>> _keywords = {
    'Just sit up': ['sit up', 'sit-up', 'get up', 'out of bed'],
    'Laundry': ['laundry', 'washing', 'clothes wash'],
    'Shower': ['shower', 'bath', 'wash myself'],
    'Go outside': ['outside', 'walk', 'fresh air', 'go out'],
    'Reply to someone': ['reply', 'text', 'message', 'email', 'call', 'respond'],
    'Eat something': ['eat', 'food', 'meal', 'breakfast', 'lunch', 'dinner', 'snack'],
    'Dishes': ['dish', 'sink', 'wash up', 'washing up'],
    'Brush teeth': ['teeth', 'tooth', 'brush'],
    'Get dressed': ['dress', 'clothes', 'change'],
  };

  /// Best matching starter ladder for a title, or null.
  static List<MicroStep>? match(String title) {
    final t = title.toLowerCase().trim();
    if (t.isEmpty) return null;
    for (final entry in byTitle.entries) {
      if (entry.key.toLowerCase() == t) return entry.value;
    }
    for (final entry in _keywords.entries) {
      for (final kw in entry.value) {
        if (t.contains(kw)) return byTitle[entry.key];
      }
    }
    return null;
  }

  /// A generic ladder for any task title.
  static List<MicroStep> generic(String title) {
    final t = title.trim().isEmpty ? 'this' : title.trim();
    return [
      _s('Think about "$t" for 1 minute', 1),
      _s('Say out loud "I\'d like to do $t"', 1),
      _s('Sit up for 2 minutes', 2),
      _s('Stand up and stay standing for 1 minute', 1),
      _s('Go to where "$t" happens and stand there', 2),
      _s('Do the very first small piece of "$t"', 3),
      _s('Do "$t" for 5 minutes', 5),
      _s('$t, the whole thing', 25),
    ];
  }

  /// Steps that are all smaller than or equal to [rung].
  static List<MicroStep> smallerThan(String rung, {int? rungMinutes}) {
    final r = rung.trim();
    return [
      _s('Think about "$r" for 1 minute', 1),
      _s('Say out loud "$r is next"', 1),
      _s('Get into the position you would be in to $r, and stay for 1 minute', 1),
      _s('Do the first 10 seconds of "$r"', 1),
      _s('Do "$r" for 1 minute', 1),
      _s(r, rungMinutes),
    ];
  }
}
