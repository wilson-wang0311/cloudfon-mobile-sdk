# CloudFon iOS SDK

CloudFon 移动通讯 SDK 的 iOS 实现，基于 WKWebView 提供即时通讯功能。

## 功能特性

- WKWebView 嵌入式聊天界面
- 访客模式，无需登录认证
- 未读消息计数
- 埋点事件追踪
- 推送服务集成（APNs）
- 调试模式支持

## 环境要求

- Xcode 15.0 或更高版本
- iOS 14.0 及以上
- Swift 5.9
- CocoaPods 或 Swift Package Manager

## 快速开始

### 1. 安装 SDK

#### 使用 CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'CloudFonMobileSDK', :git => 'https://github.com/your-repo/CloudFonMobileSDK.git'
```

然后运行：

```bash
pod install
```

#### 使用 Swift Package Manager

在 Xcode 中，选择 `File > Add Package Dependencies`，然后添加：

```
https://github.com/your-repo/CloudFonMobileSDK.git
```

### 2. 初始化 SDK

在 `AppDelegate.swift` 中初始化：

```swift
import CloudFonMobileSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let config = CloudFonConfig(
        baseUrl: "https://your-server.com",
        planId: "your-plan-id",
        apiKey: "your-api-key",
        debug: true
    )
    
    CloudFonSDK.shared.initialize(config: config)
    
    return true
}
```

### 3. 显示聊天窗口

```swift
CloudFonSDK.shared.showMessenger(from: self)
```

## API 参考

### CloudFonConfig

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| baseUrl | String | 是 | 服务器基础 URL |
| planId | String | 是 | Plan ID |
| apiKey | String | 是 | API Key |
| debug | Bool | 否 | 调试模式，默认 false |
| allowedDomains | [String] | 否 | 允许的域名白名单 |
| pushServiceType | String | 否 | 推送服务类型，默认 "apns" |
| webViewConfig | WebViewConfig | 否 | WebView 配置 |

### CloudFonSDK

#### 初始化

```swift
func initialize(config: CloudFonConfig)
```

#### 显示聊天窗口

```swift
func showMessenger(from viewController: UIViewController)
```

#### 隐藏聊天窗口

```swift
func hideMessenger()
```

#### 埋点事件

```swift
func trackEvent(name: String, properties: [String: Any]? = nil)
```

#### 更新未读数

```swift
func updateUnreadCount(_ count: Int)
```

#### 获取未读数

```swift
var unreadCount: Int { get }
```

#### 未读数变化回调

```swift
var unreadCountChangedCallback: ((Int) -> Void)?
```

## 示例项目

参考 [`Sources/ExampleViewController.swift`](Sources/ExampleViewController.swift) 中的完整示例。

## 推送配置

### 配置 APNs

1. 在 Apple Developer Portal 创建 App ID 并启用 Push Notifications
2. 生成并下载推送证书
3. 在 Xcode 中配置证书

### 在 SDK 中启用推送

```swift
let config = CloudFonConfig(
    baseUrl: "https://your-server.com",
    planId: "your-plan-id",
    apiKey: "your-api-key",
    pushServiceType: "apns"
)
```

## 权限配置

确保 `Info.plist` 包含必要权限：

### 基本配置

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 推送通知配置 (可选)

如需使用推送通知功能，添加以下配置：

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## AppDelegate 推送集成

如需接收推送通知，在 `AppDelegate.swift` 中添加以下方法：

```swift
// 注册推送通知
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in
        if granted {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    return true
}

// 获取设备 Token
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("CloudFon Device Token: \(token)")
}

// 注册失败处理
func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
) {
    print("CloudFon Failed to register for remote notifications: \(error)")
}
```

> **注意**: 生产环境建议将 `NSAllowsArbitraryLoads` 设置为 `false`，并只允许特定域名。

## 常见问题

### Q: 聊天页面加载失败
A: 检查 `baseUrl` 配置是否正确，确保服务器地址可访问。

### Q: 无法获取未读数
A: 确保已调用 `updateUnreadCount()` 方法更新未读数。

### Q: 调试模式下看不到日志
A: 确保 `CloudFonConfig.debug` 设置为 `true`。

## 更新日志

### v1.0.0
- 初始版本发布
- 支持 WKWebView 聊天界面
- 支持访客模式，无需登录
- 支持基本埋点功能