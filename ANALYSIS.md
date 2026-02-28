# CloudFon iOS SDK 工程分析文档

## 一、项目概述

### 1.1 项目基本信息
| 项目 | 内容 |
|------|------|
| 项目名称 | CloudFon Mobile SDK |
| 项目类型 | iOS 动态库 (SDK) |
| 当前版本 | 1.0.1 |
| 许可证 | MIT |
| 维护团队 | CloudFon Team |

### 1.2 项目结构
```
ios-sdk/
├── CloudFonMobileSDK.podspec    # CocoaPods 配置文件
├── Sources/
│   ├── CloudFonConfig.swift     # SDK 配置类
│   ├── CloudFonSDK.swift        # SDK 主入口类
│   ├── ChatWebViewController.swift  # WebView 聊天控制器
│   └── ExampleViewController.swift  # 使用示例
├── README.md                    # 项目文档
└── LICENSE                      # MIT 许可证
```

---

## 二、功能分析

### 2.1 核心功能

| 功能 | 状态 | 说明 |
|------|------|------|
| WKWebView 聊天界面 | ✅ 已实现 | 基于 WKWebView 的嵌入式聊天 |
| 访客模式 | ✅ 已实现 | 无需登录认证即可使用 |
| 未读消息计数 | ✅ 已实现 | 通过回调获取未读数变化 |
| 埋点事件追踪 | ✅ 已实现 | trackEvent() 方法 |
| 推送服务集成 (APNs) | ⚠️ 部分实现 | 占位方法，未完成 |
| 调试模式 | ✅ 已实现 | 支持 debug 日志输出 |
| JS Bridge 通信 | ✅ 已实现 | Native 与 Web 双向通信 |
| Launcher 浮动按钮 | ❌ 未实现 | setLauncherVisible() 为空 |

### 2.2 SDK 初始化流程
```swift
// 1. 创建配置
let config = CloudFonConfig(
    baseUrl: "https://your-server.com",
    planId: "your-plan-id",
    apiKey: "your-api-key",
    debug: true
)

// 2. 初始化 SDK
CloudFonSDK.shared.initialize(config: config)

// 3. 显示聊天窗口
CloudFonSDK.shared.showMessenger(from: self)
```

### 2.3 API 能力

#### CloudFonConfig 配置参数
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| baseUrl | String | 是 | - | 服务器基础 URL |
| planId | String | 是 | - | Plan ID |
| apiKey | String | 是 | - | API Key |
| debug | Bool | 否 | false | 调试模式 |
| allowedDomains | [String] | 否 | [] | 域名白名单 |
| pushServiceType | String | 否 | "apns" | 推送服务类型 |
| webViewConfig | WebViewConfig | 否 | 默认值 | WebView 配置 |

#### CloudFonSDK 公共方法
| 方法 | 说明 |
|------|------|
| initialize(config:) | 初始化 SDK |
| showMessenger(from:) | 显示聊天窗口 |
| hideMessenger() | 隐藏聊天窗口 |
| setLauncherVisible(_:) | 设置浮动按钮可见性 (未实现) |
| trackEvent(name:properties:) | 埋点事件 |
| updateUnreadCount(_:) | 更新未读数 |
| getConfig() | 获取当前配置 |
| isInitialized() | 检查是否已初始化 |

---

## 三、配置问题分析

### 3.1 版本配置不一致

| 配置文件 | iOS 部署目标 | Swift 版本 |
|----------|-------------|------------|
| podspec | iOS 13.0 | Swift 5.0 |
| README.md | iOS 14.0 | Swift 5.9 |

**问题**: podspec 与 README 文档中的版本要求不一致，可能导致开发者在集成时产生困惑。

### 3.2 代码未完成标记 (TODO)

| 文件 | 位置 | 说明 |
|------|------|------|
| CloudFonSDK.swift | 第77行 | `setLauncherVisible()` 方法为空，未实现浮动按钮功能 |
| CloudFonSDK.swift | 第115行 | `initializePushService()` 方法为空，推送服务未集成 |
| ChatWebViewController.swift | 第395行 | `requestCurrentUrl` 处理为空 |

### 3.3 配置不同步问题

| 问题 | 说明 |
|------|------|
| allowedDomains 配置未使用 | `CloudFonConfig.allowedDomains` 参数定义了域名白名单，但 `ChatWebViewController` 中使用了硬编码的白名单 `["cloudcx.cloudfon.net", "cloudfon.net", "cloudfon.com"]`，两者未同步 |

---

## 四、安全性分析

### 4.1 当前安全措施
- ✅ URL 域名白名单验证
- ✅ HTTPS 支持

### 4.2 潜在安全问题

| 问题 | 风险等级 | 说明 |
|------|----------|------|
| NSAllowsArbitraryLoads | 中 | README 建议允许任意 HTTP 加载，生产环境应移除 |
| 硬编码测试凭据 | 低 | ExampleViewController 中有测试环境的 planId |

---

## 五、依赖分析

### 5.1 外部依赖
| 依赖 | 版本 | 用途 |
|------|------|------|
| SnapKit | ~> 5.6 | Auto Layout 布局 |

### 5.2 系统框架
- UIKit
- WebKit

---

## 六、配置遗漏清单

### 6.1 高优先级

| # | 遗漏项 | 当前状态 | 建议 |
|---|--------|----------|------|
| 1 | 推送服务集成 | 空方法 | 实现 APNs 推送注册与处理 |
| 2 | Launcher 浮动按钮 | 空方法 | 实现或移除该功能 |
| 3 | 版本一致性 | 不一致 | 统一 podspec 与 README 的版本要求 |
| 4 | 域名白名单同步 | 未同步 | 使用 CloudFonConfig.allowedDomains 替代硬编码 |

### 6.2 中优先级

| # | 遗漏项 | 当前状态 | 建议 |
|---|--------|----------|------|
| 5 | Info.plist 配置 | 缺失 | 应提供 NSAppTransportSecurity 配置示例 |
| 6 | AppDelegate 推送方法 | 缺失 | 需提供 didRegisterForRemoteNotificationsWithDeviceToken 示例 |
| 7 | requestCurrentUrl 处理 | 空实现 | 完善 JS Bridge 回调 |

### 6.3 低优先级

| # | 遗漏项 | 当前状态 | 建议 |
|---|--------|----------|------|
| 8 | Swift Package Manager | README 有描述但未提供 | 添加 Package.swift |
| 9 | 单元测试 | 缺失 | 添加测试 target |
| 10 | CI/CD 配置 | 缺失 | 添加 GitHub Actions |

---

## 七、建议补充的配置文件

### 7.1 Info.plist 必需配置
```xml
<!-- 允许任意加载 (开发环境) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- 推送通知权限 (如需要) -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### 7.2 AppDelegate 推送集成示例
```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(token)")
    // 发送 token 到服务器
}

func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
) {
    print("Failed to register for remote notifications: \(error)")
}
```

---

## 八、总结

### 8.1 整体评价
- **完成度**: 约 75%
- **代码质量**: 良好，结构清晰
- **文档完整性**: 基本完整，存在版本不一致

### 8.2 需要优先完成
1. 统一版本配置
2. 实现推送服务
3. 修复域名白名单配置不同步问题

---

*文档生成时间: 2026-02-27*
