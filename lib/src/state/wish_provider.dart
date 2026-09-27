import 'wish_model.dart';

/// The old name for [WishModel].
///
/// The class used to hold the data, the filter selection and the form state in
/// one `ChangeNotifier`, which is what made the board's behaviour untestable:
/// voting, filtering and validation could only be exercised by mounting
/// widgets. They are now three view models, and this alias is what keeps
/// `ChangeNotifierProvider<WishProvider>(create: (_) => WishKit.createProvider())`
/// in existing host code compiling.
///
/// [WishKit.createProvider] now returns a [WishModel]. A host that called the
/// removed `WishProvider` methods directly should move to:
///
/// | old                       | new                                        |
/// |---------------------------|--------------------------------------------|
/// | `fetchList()`             | `WishModel.fetchList()` — unchanged        |
/// | `wishes`                  | `all`                                      |
/// | `getByState(state)`       | `WishFiltering.list(model.lists, filter)`  |
/// | `vote(id)`                | `vote(id)` — now returns `Future<bool>`    |
/// | `removeVote(id)`          | `removeVote(id)`                           |
/// | `createWish(req)`         | `createWish(req)` — unchanged              |
/// | `addComment(id, text)`    | `createComment(wishId:, description:)`     |
///
/// The filter selection moved to `WishlistViewModel` and the form state to
/// `CreateWishViewModel`; both are owned by the screen that uses them rather
/// than by a single app-wide notifier.
@Deprecated('Use WishModel. Kept as an alias so existing provider code compiles.')
typedef WishProvider = WishModel;
