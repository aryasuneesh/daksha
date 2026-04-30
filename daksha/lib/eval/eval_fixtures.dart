class EvalFixture {
  final String id;
  final String problemText;
  final String expectedSubject;
  final String expectedSlug;
  final String sampleCorrectAttempt;
  final String sampleIncorrectAttempt;

  const EvalFixture({
    required this.id,
    required this.problemText,
    required this.expectedSubject,
    required this.expectedSlug,
    required this.sampleCorrectAttempt,
    required this.sampleIncorrectAttempt,
  });
}

const evalFixtures = [
  EvalFixture(
    id: 'math-01',
    problemText: 'Solve for x: 2x + 4 = 10',
    expectedSubject: 'math',
    expectedSlug: 'linear-equations',
    sampleCorrectAttempt: 'x = 3',
    sampleIncorrectAttempt: 'x = 7',
  ),
  EvalFixture(
    id: 'math-02',
    problemText: 'What is 3/4 + 1/2?',
    expectedSubject: 'math',
    expectedSlug: 'fractions',
    sampleCorrectAttempt: '5/4',
    sampleIncorrectAttempt: '4/6',
  ),
  EvalFixture(
    id: 'physics-01',
    problemText: 'A car travels 60 km in 2 hours. What is its speed?',
    expectedSubject: 'physics',
    expectedSlug: 'motion',
    sampleCorrectAttempt: '30 km/h',
    sampleIncorrectAttempt: '120 km/h',
  ),
  EvalFixture(
    id: 'chemistry-01',
    problemText: 'What happens when an acid reacts with a base?',
    expectedSubject: 'chemistry',
    expectedSlug: 'acids-bases',
    sampleCorrectAttempt: 'They neutralize each other, forming salt and water.',
    sampleIncorrectAttempt: 'They produce oxygen gas.',
  ),
  EvalFixture(
    id: 'biology-01',
    problemText: 'What is the powerhouse of the cell?',
    expectedSubject: 'biology',
    expectedSlug: 'cell-biology',
    sampleCorrectAttempt: 'Mitochondria',
    sampleIncorrectAttempt: 'Nucleus',
  ),
];
