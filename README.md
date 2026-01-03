# easy

## Shorebird 热更新 (Hot Updates)

本项目已集成 [Shorebird](https://shorebird.dev/)，支持在不重新安装 IPA 的情况下推送 Dart 代码更新。

### 1. 发布新版本 (Release)

当你添加了新的原生插件、修改了原生代码或升级了 Flutter SDK 时，需要发布一个全新的 Release。

```bash
# 1. 开启代理 (如果需要)
proxy

# 2. 生成 Release 并上传到 Shorebird 控制台
shorebird release ios --no-codesign
```

**导出并安装 (针对 SideStore 用户)：**
1. 构建完成后，在 Xcode 中打开归档：`open build/ios/archive/Runner.xcarchive`
2. **手动打包 IPA** (因 `--no-codesign` 无法自动生成 IPA)：
   - 进入目录：`build/ios/archive/Runner.xcarchive/Products/Applications`
   - 创建 `Payload` 文件夹并将 `Runner.app` 放入其中。
   - 压缩 `Payload` 文件夹并改名为 `Easy.ipa`。
   - *或者直接在根目录执行：* `mkdir -p build/ios/ipa/Payload && cp -r build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app build/ios/ipa/Payload/ && cd build/ios/ipa && zip -r Easy.ipa Payload && rm -rf Payload`
3. 通过 SideStore 安装 `Easy.ipa` 到手机。

### 2. 推送热更新 (Patch)

如果你只是修改了 Dart 业务逻辑或 UI，可以使用补丁功能瞬间推送给用户。

```bash
# 直接运行封装好的脚本即可
./patch.sh
```

**脚本说明：**
- 会自动开启终端代理 (`http://127.0.0.1:7897`)
- 自动读取 `pubspec.yaml` 中的版本号
- 静默推送补丁到 Shorebird 服务器

### 3. 工作流建议

- **Patch (补丁)**: 用于修复 Bug、微调 UI、添加纯 Dart 实现的功能。用户下次启动 App 时会自动在后台下载，第二次启动生效。
- **Release (发布)**: 用于由于 `pubspec.yaml` 中新增了原生依赖、修改了 `ios/` 目录下的原生代码、或通过 `shorebird patch` 无法涵盖的重大变更。

---

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).

