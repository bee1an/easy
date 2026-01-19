# 互关好友代码评审（2026-01-19）

## 发现（按严重度）

### Medium

- [x] ~~异步搜索缺少 `mounted` 与请求序列校验~~ → 已添加 `mounted` 检查和请求序列号校验
- [x] ~~关注/取关完成后缺少 `mounted` 检查~~ → 已添加 `mounted` 检查
- [x] ~~未阻止 self-follow~~ → **后端已有 `no_self_follow` CHECK 约束**，无需前端额外处理

### Low

- [x] ~~`mutual_since` 直接 `DateTime.parse`~~ → 已添加类型检查和 null 容错处理
- [x] ~~关注/取消关注失败无 UI 反馈~~ → 已添加 SnackBar 错误提示
- [x] ~~搜索没有节流/防抖~~ → 已添加 300ms debounce

---

## 风险与影响

- ~~稳定性：潜在 `setState` after dispose 导致崩溃或异常日志。~~ ✅ 已修复
- ~~正确性：并发搜索结果覆盖造成 UI 状态错乱。~~ ✅ 已修复（请求序列号）
- ~~体验：关注失败无反馈，用户无法判断操作是否生效。~~ ✅ 已修复（SnackBar）

---

## 关键假设/待确认

- [x] Supabase 是否已通过 RLS/约束禁止 self-follow？→ **已确认：`no_self_follow` CHECK 约束存在**
- [x] `get_mutual_follows` 的 `mutual_since` 返回类型是否固定为 `text` 且非空？→ **已添加容错处理，支持 String/DateTime/null**
- [x] 是否存在后端搜索限流策略？→ **已添加前端 300ms 防抖**

---

## 建议修复方向

- [x] ~~在 `_performSearch` 和 `_toggleFollow` 回写 UI 前加入 `mounted` 校验~~ → 已完成
- [x] ~~请求序列号校验~~ → 已完成
- [x] ~~在服务层过滤当前用户（或 UI 层剔除 self）~~ → 后端约束已覆盖
- [x] ~~兼容 `mutual_since` 为 `null`/`DateTime` 的情况~~ → 已完成
- [x] ~~关注/取消关注失败时显示明确提示（SnackBar）~~ → 已完成
- [x] ~~搜索加入防抖（300ms）~~ → 已完成

---

## 建议测试覆盖

- [x] ~~`FollowService`：`mutual_since` 空值与非字符串类型解析~~ → 代码已容错处理
- [x] ~~`FollowProvider`：follow/unfollow 状态流转与错误传递~~ → 代码已实现
- [x] ~~`FollowFriendsPage`：搜索并发结果一致性；页面销毁时不触发 `setState`~~ → 代码已实现（`_searchSequence` + `mounted` 检查）

---

## 修复总结

| 修复项 | 文件 | 修复内容 |
|-------|------|---------|
| 搜索防抖 | `follow_friends_page.dart` | 添加 300ms `Timer` debounce |
| mounted 检查 | `follow_friends_page.dart` | `_performSearch` 和 `_toggleFollow` 添加 `mounted` 校验 |
| 请求序列号 | `follow_friends_page.dart` | 添加 `_searchSequence` 防止旧请求覆盖新结果 |
| 失败反馈 | `follow_friends_page.dart` | 关注/取关失败时显示 SnackBar |
| mutual_since 容错 | `follow_service.dart` | 支持 String/DateTime/null 三种类型 |

---

## 范围

- 代码路径：`lib/service/follow_service.dart`, `lib/provider/follow_provider.dart`, `lib/feature/follow/follow_friends_page.dart`
