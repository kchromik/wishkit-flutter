import 'package:wishkit/wishkit.dart';

/// Builds a wish with a deterministic identity, so an assertion can name the
/// row it expects instead of an index that shifts when the sort order changes.
Wish makeWish({
  required String id,
  WishState state = WishState.approved,
  String userUuid = 'other-user',
  int votes = 0,
  List<String>? voterUuids,
  List<Comment> comments = const [],
  String title = 'title',
  String description = 'description',
}) {
  return Wish(
    id: id,
    userUUID: userUuid,
    title: title,
    description: description,
    state: state,
    votingUsers: voterUuids != null
        ? voterUuids.map((uuid) => WishKitUser(uuid: uuid)).toList()
        : List<WishKitUser>.generate(
            votes,
            (index) => WishKitUser(uuid: 'voter-$index'),
          ),
    comments: comments,
  );
}

/// The ids of [wishes], in order. Shorter than `map((w) => w.id)` everywhere, and
/// prints the rows that were actually returned rather than an index that shifts
/// when the sort order changes.
List<String> idsOf(List<Wish> wishes) =>
    wishes.map((wish) => wish.id).toList(growable: false);
