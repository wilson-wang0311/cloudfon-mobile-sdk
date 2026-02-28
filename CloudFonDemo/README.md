# CloudFon Demo

CloudFon SDK iOS 示例项目

## 环境要求

- Xcode 15.0+
- iOS 14.0+
- CocoaPods
- XcodeGen

## 快速开始

### 1. 安装 XcodeGen

```bash
brew install xcodegen
```

### 2. 生成 Xcode 项目

```bash
cd CloudFonDemo
xcodegen generate
```

### 3. 安装 CocoaPods 依赖

```bash
pod install
```

### 4. 运行项目

在 Xcode 中打开 `CloudFonDemo.xcworkspace`，选择模拟器并运行。

## 功能测试

Demo 项目提供以下测试功能：

| 功能 | 说明 |
|------|------|
| SDK 自动初始化 | App 启动时自动初始化 CloudFon SDK |
| 打开聊天窗口 | 点击按钮打开 WKWebView 聊天界面 |
| 未读数变化 | 点击测试按钮模拟未读数变化 |
| 埋点事件 | 点击发送测试埋点事件 |

## 配置说明

在 `AppDelegate.swift` 中修改配置：

```swift
let config = CloudFonConfig(
    baseUrl: "https://your-server.com",  // 服务器地址
    planId: "your-plan-id",               // Plan ID
    apiKey: "your-api-key",               // API Key
    debug: true,                          // 调试模式
    allowedDomains: ["your-domain.com"],  // 允许的域名
    pushServiceType: "apns",              // 推送服务类型
    webViewConfig: WebViewConfig()        // WebView 配置
)
```

## 项目结构

```
CloudFonDemo/
├── project.yml           # XcodeGen 配置
├── Podfile              # CocoaPods 依赖
├── Sources/
│   ├── AppDelegate.swift       # 应用代理
│   ├── SceneDelegate.swift     # 场景代理
│   └── MainViewController.swift  # 主界面
└── Resources/
    ├── Info.plist              # 应用配置
    └── LaunchScreen.storyboard # 启动屏幕
```
