# SocialPlus SDK — High-Severity Issues

Analysis focused on **Communities**, **Users**, and **Messaging** domains.
All 50 items rated **High** severity.

---

## 1. Stream subscriptions never cancelled — memory leaks & ghost updates
**Area:** Communities  
**File:** `lib/viewmodel/my_community_viewmodel.dart:34`

Stream listeners are created but the returned `StreamSubscription` is discarded (not stored, not cancelled). When `initMyCommunity` is called again (e.g., on search), the old subscription keeps firing alongside the new one — causing duplicate `notifyListeners()` calls, ghost UI updates, and memory leaks.

---

## 2. `ChatRoomVM.dispose()` is a no-op
**Area:** Messaging  
**File:** `lib/viewmodel/chat_room_viewmodel.dart:145`

`dispose()` only calls `super.dispose()`. The `messageLiveCollection` stream subscription and `scrollcontroller` listener are never cancelled or disposed. Every time a chat room is opened, live collection resources accumulate and are never freed.

---

## 3. Duplicate scroll listeners in `MemberManagementVM`
**Area:** Communities  
**File:** `lib/viewmodel/community_member_viewmodel.dart:60`

Both `initMember()` and `initModerators()` call `scrollController.addListener(loadNextPage)` on the **same** `scrollController`. If both are called (which is the normal flow), every scroll event triggers pagination twice, issuing duplicate API requests.

---

## 4. Hard-coded limit of 100 communities bypasses pagination
**Area:** Communities  
**File:** `lib/viewmodel/community_viewmodel.dart:219`

`getPagingData(limit: 100)` fetches all communities in a single request. For users with many communities, this is a large, uncontrolled payload causing significant memory pressure and slow load times, with no fallback or incremental loading.

---

## 5. Double data fetch in `initAmityCommunityFeed` — filter applied inconsistently
**Area:** Communities  
**File:** `lib/viewmodel/community_feed_viewmodel.dart:132`

After setting up a `PagingController` with `.feedType(AmityFeedType.PUBLISHED)`, a second raw `getPagingData()` call **without** `.feedType()` overwrites `_amityCommunityFeedPosts`. On first render, reviewing/declined posts may be displayed until the paging controller catches up.

---

## 6. Pagination trigger uses `==` (exact equality) on scroll position
**Area:** Communities  
**File:** `lib/viewmodel/community_feed_viewmodel.dart:300`

```dart
if ((scrollcontroller.position.pixels == scrollcontroller.position.maxScrollExtent) && ...)
```

Floating-point scroll positions rarely hit exact equality, so `loadnextpage` may **never** fire on many devices, effectively breaking infinite scroll for the community feed. Same bug exists in `post_viewmodel.dart`.

---

## 7. `UserVM.getUsers()` loads all users without pagination
**Area:** Users  
**File:** `lib/viewmodel/user_viewmodel.dart:74`

`.getUsers().sortBy(...).query()` is an unbounded fetch that can pull the entire user base into memory. This is a severe performance and memory issue in any deployment with a non-trivial number of users.

---

## 8. `BuildContext` used after async gaps — crash risk suppressed with `ignore_for_file`
**Area:** Communities, Users, Messaging  
**Files:** `lib/amity_uikit.dart:1`, `lib/view/social/community_list.dart:179`

`use_build_context_synchronously` is suppressed file-wide in multiple files. Code calling `Provider.of<...>(context)` after `await` will throw or access a disposed widget tree if the user navigates away mid-async, causing runtime crashes.

---

## 9. Scroll listener removal in `MyCommunityVM` removes nothing
**Area:** Communities  
**File:** `lib/viewmodel/my_community_viewmodel.dart:47`

```dart
scrollcontroller.removeListener(() {});
```

This passes a **new anonymous function** as the argument — it removes nothing. The old `loadNextPage` listener stacks up on every `initMyCommunity` call (e.g., per search keystroke), multiplying API calls on every subsequent scroll event.

---

## 10. Community list is a one-shot fetch with no live updates
**Area:** Communities  
**File:** `lib/viewmodel/community_viewmodel.dart:205`

`initAmityMyCommunityList` uses a one-shot `getPagingData()` call instead of a `LiveCollection`. Joining or leaving a community from elsewhere in the app will not be reflected in the list without a full manual refresh, leading to stale state that can mislead users about their membership status.

---

## 11. Message sent twice on resend — duplicate message delivery
**Area:** Messaging  
**Files:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`, `lib/v4/chat/group_message/bloc/amity_group_chat_page_bloc.dart`

The resend handler calls both the original `sendMessage()` and then immediately calls it again inside the resend code path. Every "retry" results in two messages being delivered to the channel.

---

## 12. Stale `BuildContext` stored as BLoC field
**Area:** Messaging  
**File:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`

A `BuildContext` is captured at BLoC construction time and stored as `_context`. If the widget rebuilds or is replaced, the BLoC continues holding the old (potentially disposed) context, leading to crashes or wrong-tree lookups when used later.

---

## 13. Scroll listeners accumulate on every `initFeed` call
**Area:** Communities, Users  
**File:** `lib/viewmodel/feed_viewmodel.dart`

`initFeed()` calls `scrollcontroller.addListener(loadNextPage)` without first removing any existing listener. Each refresh/reinit stacks an additional listener, causing exponentially increasing API calls per scroll event.

---

## 14. `getPostStream` subscription leaked in `PostVM`
**Area:** Communities, Users  
**File:** `lib/viewmodel/post_viewmodel.dart`

The subscription returned by `getPostStream().listen(...)` is never stored or cancelled. Each time a post detail screen is opened a new live subscription is created without the old one being cleaned up.

---

## 15. `deletePost` calls both success and error callbacks
**Area:** Users  
**File:** `lib/viewmodel/user_feed_viewmodel.dart`

After a successful deletion the code calls `onSuccess()` then falls through to also call `onError()`. The caller receives both callbacks for a single operation, causing undefined UI behaviour (e.g., showing both a success toast and an error dialog).

---

## 16. N+1 sequential API calls in `NotificationVM`
**Area:** Communities  
**File:** `lib/viewmodel/notification_viewmodel.dart`

For each notification in a list the viewmodel fires an individual API request synchronously inside a `for` loop. With even a modest notification count this serializes tens of requests, blocking the UI thread and causing severe latency.

---

## 17. Hard-coded REST URLs in `NotificationVM`
**Area:** Communities  
**File:** `lib/viewmodel/notification_viewmodel.dart`

Base URLs are string literals baked into the viewmodel. When the server region or environment changes the app must be recompiled. There is also no certificate pinning or domain validation, making the endpoint trivially redirectable.

---

## 18. `loadConfig()` called on every `AmityUIKitProvider` rebuild
**Area:** Communities, Users, Messaging  
**File:** `lib/amity_uikit.dart`

`loadConfig()` — which reads and parses a JSON asset — is invoked inside `build()` with no guard. Every widget rebuild (including unrelated ancestor rebuilds) re-parses the config file, causing unnecessary I/O and CPU work in the hot path.

---

## 19. Three anonymous scroll listeners added per `initUserFeed` call
**Area:** Users  
**File:** `lib/viewmodel/user_feed_viewmodel.dart`

`initUserFeed()` calls `addListener` three times (once per feed tab) using anonymous closures. Anonymous closures cannot be removed with `removeListener`, so each call to `initUserFeed` permanently adds three more listeners.

---

## 20. N concurrent API calls opened on reply sheet expand
**Area:** Communities  
**File:** `lib/viewmodel/reply_viewmodel.dart`

When the reply panel opens, `initReply()` is called for every visible comment simultaneously. Each call independently fetches the full reply list, issuing N parallel requests for N visible comments with no deduplication or throttle.

---

## 21. Null crash when custom API endpoint is not set
**Area:** Communities, Users, Messaging  
**File:** `lib/amity_uikit.dart`

`AmityUIKit.setup()` dereferences `endpoint!` without a null check when the caller omits the optional parameter. Any integration that doesn't pass an endpoint will crash on startup with an unhandled null dereference.

---

## 22. Inverted null guard — post is never added to feed
**Area:** Communities  
**File:** `lib/viewmodel/feed_viewmodel.dart`

```dart
if (post == null) { _posts.add(post); }
```

The condition is inverted: posts are only added when they are `null`, and valid post objects are silently dropped. The community feed is permanently empty after this guard runs.

---

## 23. `pending_request_viewmodel` listener factory is never executed
**Area:** Communities  
**File:** `lib/viewmodel/pending_request_viewmodel.dart`

`scrollController.addListener(listener)` is passed a function that **returns** the real callback rather than being the callback itself. The scroll event fires the factory, which creates and immediately discards a closure — pagination never triggers.

---

## 24. `removeMembers` result not awaited — silent failures
**Area:** Communities  
**File:** `lib/viewmodel/community_member_viewmodel.dart`

`removeMember()` calls the SDK method but does not `await` it. If the operation fails, the error is swallowed and the UI shows the member as removed while they remain on the server, causing a desync between local state and truth.

---

## 25. Scroll listeners accumulate on category change in `ExplorePageVM`
**Area:** Communities  
**File:** `lib/viewmodel/explore_page_viewmodel.dart`

Switching community categories calls `initCategoryFeed()` which adds a new scroll listener each time without clearing the previous one. After browsing several categories the scroll handler fires dozens of times per scroll event.

---

## 26. Orphaned `ScrollController` in `FollowerVM`
**Area:** Users  
**File:** `lib/viewmodel/follower_viewmodel.dart`

A `ScrollController` is created in the viewmodel's constructor and a listener is added, but `dispose()` never calls `scrollController.dispose()`. The controller (and its associated ticker/vsync resources) leaks for the lifetime of the app session.

---

## 27. Empty `catch` blocks swallow all errors silently
**Area:** Messaging  
**Files:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`, `lib/v4/chat/group_message/bloc/amity_group_chat_page_bloc.dart`

Multiple `try/catch` blocks have empty `catch` bodies. Network errors, permission errors, and SDK exceptions are silently discarded — the user sees no feedback, and engineers have no log trail to diagnose failures.

---

## 28. `initLiveCollection` not awaited — race condition on message load
**Area:** Messaging  
**File:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`

`initLiveCollection()` is called without `await` and the code immediately proceeds to register listeners on the not-yet-initialized collection. On slow devices the listener fires before the collection is ready, producing empty or partial message lists.

---

## 29. `late` subscription field accessed before initialization — crash
**Area:** Messaging  
**File:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`

A `late StreamSubscription` field is accessed in `dispose()` (and potentially error paths) before it is guaranteed to be assigned. Any early teardown or exception during init will throw `LateInitializationError`.

---

## 30. `communityFeedLiveCollection` stream never cancelled
**Area:** Communities  
**File:** `lib/viewmodel/my_community_viewmodel.dart`

The live collection stream opened for the community feed is stored but its `cancel()` is never called in `dispose()`. This stream remains open and firing callbacks even after the owning widget is unmounted.

---

## 31. `initUserFeed` reinitialises all controllers on follow/unfollow
**Area:** Users  
**File:** `lib/viewmodel/user_feed_viewmodel.dart`

Toggling follow status calls `initUserFeed()` to refresh content. This recreates all `PagingController` instances and re-attaches all scroll listeners, compounding the anonymous-listener leak (issue #19) on every follow/unfollow action.

---

## 32. Force-unwrap of `navigatorKey.currentContext!` in `NotificationVM`
**Area:** Communities  
**File:** `lib/viewmodel/notification_viewmodel.dart`

`navigatorKey.currentContext!` is force-unwrapped. If the navigator has not yet built its first frame, or if the key is not attached to the tree, this throws a `Null check operator used on a null value` crash at runtime.

---

## 33. Four scroll listeners stacked from four `init` methods
**Area:** Communities  
**File:** `lib/viewmodel/community_feed_viewmodel.dart`

`initAmityCommunityFeed`, `initAmityNewsFeed`, `initAmityGlobalFeed`, and `initAmityPendingFeed` each add a listener to the same `scrollcontroller`. If the widget cycles through feed types without full disposal, all four listeners remain active simultaneously.

---

## 34. Subscription leaked on each `deleteComment` call
**Area:** Communities, Users  
**File:** `lib/viewmodel/post_viewmodel.dart`

`deleteComment()` opens a new SDK stream subscription to observe the delete result but never stores or cancels it. Every delete action permanently leaks a subscription for the lifetime of the session.

---

## 35. Wrong API used — `getFollowers` called instead of `getFollowings`
**Area:** Users  
**File:** `lib/viewmodel/user_feed_viewmodel.dart` (and `follower_following_viewmodel.dart`)

The "Following" tab calls the `getFollowers()` SDK endpoint instead of `getFollowings()`. The current user's following list is populated with their followers, showing completely wrong data to the user.

---

## 36. Two listeners attached to the same controller in `PendingRequestVM`
**Area:** Communities  
**File:** `lib/viewmodel/pending_request_viewmodel.dart`

Both `initPendingMemberRequest()` and `initPendingPost()` call `addListener` on the same `scrollController`. Both listeners fire on every scroll event, issuing duplicate pagination requests for whichever list is currently visible.

---

## 37. `communityFeedLiveCollection` stream never cancelled (dispose gap)
**Area:** Communities  
**File:** `lib/viewmodel/my_community_viewmodel.dart`

Distinct from issue #30 — the `liveCollection` opened inside the trending/explore flow is a different reference that is also never cancelled, meaning two separate live streams remain open after the view is destroyed.

---

## 38. Wrong scroll controller used for moderator pagination
**Area:** Communities  
**File:** `lib/viewmodel/community_member_viewmodel.dart`

`initModerators()` attaches its `loadNextPage` callback to `scrollController` (the member list controller) instead of `moderatorScrollController`. Scrolling the moderator list never triggers pagination; scrolling the member list triggers both.

---

## 39. `checkAreAllPathsComplete` uses global navigator context
**Area:** Communities  
**File:** `lib/viewmodel/create_post_viewmodel.dart`

Post creation validation resolves context via the global `navigatorKey` rather than the local widget context. If the navigator key is not set or the route has been popped, this produces a stale-context access that crashes or silently no-ops.

---

## 40. Nullable `subscription.cancel()` crash in group chat BLoC
**Area:** Messaging  
**File:** `lib/v4/chat/group_message/bloc/amity_group_chat_page_bloc.dart`

`_subscription?.cancel()` is called in `close()`, but the field is declared as non-nullable. If an exception occurs before `_subscription` is assigned, calling `cancel()` on the uninitialized field throws `LateInitializationError` during teardown.

---

## 41. Trending & recommended communities are stale one-shot fetches
**Area:** Communities  
**File:** `lib/viewmodel/community_viewmodel.dart`

`getTrendingCommunities()` and `getRecommendedCommunities()` each perform a single `getPagingData()` fetch at widget mount. There is no refresh mechanism and no live update — the lists become stale immediately and show outdated data for the session lifetime.

---

## 42. Mutable non-final `_context` field in `ChatPageBloc`
**Area:** Messaging  
**File:** `lib/v4/chat/message/bloc/chat_page_bloc.dart`

`_context` is a mutable class field that can be reassigned from outside the BLoC. Concurrent reassignment from different event handlers or widget rebuilds can cause race conditions where one handler reads a context set by another.

---

## 43. Scroll listener accumulates per keystroke in user search
**Area:** Users  
**File:** `lib/viewmodel/user_viewmodel.dart`

The search field calls `initSearch()` on every keystroke change. `initSearch()` adds a scroll listener without removing the previous one. After typing a 10-character query, 10 scroll listeners are active — each scroll fires 10 API calls.

---

## 44. Hot-path logging in `localeResolutionCallback`
**Area:** Communities, Users, Messaging  
**File:** `lib/amity_uikit.dart`

`debugPrint` is called inside `localeResolutionCallback`, which is invoked on every widget build that touches locale. In a large widget tree this produces a flood of log output in debug builds and wasted string-format work in profile/release builds.

---

## 45. `deselectFile` is a no-op — selected files cannot be removed
**Area:** Communities  
**File:** `lib/viewmodel/create_postV2_viewmodel.dart`

`deselectFile(index)` runs but never modifies the backing list. The UI shows the deselect affordance but the file remains attached to the post. Users cannot remove accidentally selected media before posting.

---

## 46. Upload stream subscription leaked in `CreatePostV2VM`
**Area:** Communities  
**File:** `lib/viewmodel/create_postV2_viewmodel.dart`

Each call to `uploadFiles()` creates a new stream subscription on the SDK upload observable. The subscription is never stored or cancelled. If the user cancels and retries, the old upload continues silently and both subscriptions deliver events to the same handlers.

---

## 47. `ReplyVM` shares `PostVM`'s scroll controller
**Area:** Communities, Users  
**File:** `lib/viewmodel/reply_viewmodel.dart`

Reply pagination is wired to the post feed's `scrollController` instead of its own. Scrolling the post list triggers reply pagination, and the reply panel's own scroll events are ignored — replies never load additional pages.

---

## 48. All ViewModels registered at root scope — never disposed
**Area:** Communities, Users, Messaging  
**File:** `lib/amity_uikit.dart`

`MultiProvider` at the root registers every viewmodel for the entire app lifetime. ViewModels that hold live collections, stream subscriptions, and scroll controllers are never disposed when the feature screen is popped, keeping all resources alive permanently.

---

## 49. `isLoading` flag never reset on error path in `FeedVM`
**Area:** Communities  
**File:** `lib/viewmodel/feed_viewmodel.dart`

When `loadNextPage()` encounters an SDK error it returns early without setting `isLoading = false`. The feed is permanently locked in a loading state — the user sees an infinite spinner and cannot trigger further loads or pull-to-refresh.

---

## 50. `joinInitialCommunity` swallows all errors silently
**Area:** Communities  
**File:** `lib/amity_uikit.dart`

The initial community join call is wrapped in a `try/catch` that does nothing in the `catch` block. If the join fails (network error, permission denied, community not found), setup silently continues — the user is never enrolled in the default community and no diagnostic information is recorded.
