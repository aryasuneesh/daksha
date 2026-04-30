import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/domain/taxonomy.dart';

void main() {
  group('Topic', () {
    test('Topic.fromJson parses correctly', () {
      final json = {
        'subject': 'math',
        'slug': 'linear-equations',
        'displayName': 'Linear Equations',
      };

      final topic = Topic.fromJson(json);

      expect(topic.subject, equals('math'));
      expect(topic.slug, equals('linear-equations'));
      expect(topic.displayName, equals('Linear Equations'));
    });

    test('Topic equality is by subject and slug only', () {
      final topic1 = const Topic(
        subject: 'math',
        slug: 'fractions',
        displayName: 'Fractions & Decimals',
      );

      final topic2 = const Topic(
        subject: 'math',
        slug: 'fractions',
        displayName: 'Fractions (Different Display Name)',
      );

      expect(topic1, equals(topic2));
      expect(topic1.hashCode, equals(topic2.hashCode));
    });

    test('Topics with different slug are not equal', () {
      final topic1 = const Topic(
        subject: 'math',
        slug: 'fractions',
        displayName: 'Fractions & Decimals',
      );

      final topic2 = const Topic(
        subject: 'math',
        slug: 'decimals',
        displayName: 'Fractions & Decimals',
      );

      expect(topic1, isNot(equals(topic2)));
    });
  });

  group('TaxonomyLoader', () {
    test('filterBySubject returns only matching subjects', () {
      final topics = [
        const Topic(
          subject: 'math',
          slug: 'linear-equations',
          displayName: 'Linear Equations',
        ),
        const Topic(
          subject: 'math',
          slug: 'fractions',
          displayName: 'Fractions & Decimals',
        ),
        const Topic(
          subject: 'physics',
          slug: 'motion',
          displayName: 'Motion & Speed',
        ),
      ];

      final mathTopics = TaxonomyLoader.filterBySubject(topics, 'math');

      expect(mathTopics, hasLength(2));
      expect(
        mathTopics.every((t) => t.subject == 'math'),
        isTrue,
      );
    });

    test('filterBySubject returns empty list for non-existent subject', () {
      final topics = [
        const Topic(
          subject: 'math',
          slug: 'linear-equations',
          displayName: 'Linear Equations',
        ),
      ];

      final result = TaxonomyLoader.filterBySubject(topics, 'biology');

      expect(result, isEmpty);
    });

    test('findBySlug returns matching topic', () {
      final topics = [
        const Topic(
          subject: 'physics',
          slug: 'motion',
          displayName: 'Motion & Speed',
        ),
        const Topic(
          subject: 'physics',
          slug: 'force-pressure',
          displayName: 'Force & Pressure',
        ),
      ];

      final topic = TaxonomyLoader.findBySlug(topics, 'motion');

      expect(topic, isNotNull);
      expect(topic!.slug, equals('motion'));
      expect(topic.displayName, equals('Motion & Speed'));
    });

    test('findBySlug returns null for unknown slug', () {
      final topics = [
        const Topic(
          subject: 'physics',
          slug: 'motion',
          displayName: 'Motion & Speed',
        ),
      ];

      final topic = TaxonomyLoader.findBySlug(topics, 'nonexistent');

      expect(topic, isNull);
    });

    test('findBySlug returns first match when multiple topics with same slug',
        () {
      final topics = [
        const Topic(
          subject: 'math',
          slug: 'motion',
          displayName: 'Motion in Math',
        ),
        const Topic(
          subject: 'physics',
          slug: 'motion',
          displayName: 'Motion & Speed',
        ),
      ];

      final topic = TaxonomyLoader.findBySlug(topics, 'motion');

      expect(topic, isNotNull);
      expect(topic!.subject, equals('math'));
    });
  });
}
