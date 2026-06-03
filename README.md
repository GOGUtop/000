# 狗骨酒馆 iOS 版（Safari 兼容模式）

这是把 Android 版核心功能迁移到 iOS 的 SwiftUI 项目。

## 这一版主要变化

- 默认使用 **SFSafariViewController / Safari 兼容模式** 打开狗洞。
- 适合 Safari 能打开、内置 WKWebView 却一直转圈的 HTTP / 非标准端口入口。
- 仍保留一个“试试内置 WebView”的按钮，方便对比测试。
- 已删除缓存状态、小狗加速器提示、缓存命中率、缓存目录等 Android 专属逻辑。

## 已保留

- 狗洞入口选择
- 上次入口记录
- Safari 兼容模式打开酒馆网页
- 换狗洞
- 重置 WKWebView 网页数据
- 小说化阅读器
- 导入 JSON / JSONL / TXT
- 复制 / 导出文本

## 打 unsigned IPA

上传到 GitHub 后，进入 Actions，运行：

`Build unsigned IPA`

运行结束后在 Artifacts 下载：

`DogBoneTavern-unsigned-ipa`

解压后拿 `DogBoneTavern-unsigned.ipa` 去签名。
