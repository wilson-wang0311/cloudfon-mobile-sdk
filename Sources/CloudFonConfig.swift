import Foundation

/// CloudFon SDK 配置类
public struct CloudFonConfig {
    /// 服务器基础 URL
    public let baseUrl: String
    
    /// Plan ID
    public let planId: String
    
    /// API Key
    public let apiKey: String
    
    /// 是否启用调试模式
    public let debug: Bool
    
    /// 允许的域名白名单
    public let allowedDomains: [String]
    
    /// 推送服务类型: "fcm" 或 "apns"
    public let pushServiceType: String
    
    /// 自定义 WebView 配置
    public let webViewConfig: WebViewConfig
    
    public init(
        baseUrl: String,
        planId: String,
        apiKey: String,
        debug: Bool = false,
        allowedDomains: [String] = [],
        pushServiceType: String = "apns",
        webViewConfig: WebViewConfig = WebViewConfig()
    ) {
        self.baseUrl = baseUrl
        self.planId = planId
        self.apiKey = apiKey
        self.debug = debug
        self.allowedDomains = allowedDomains
        self.pushServiceType = pushServiceType
        self.webViewConfig = webViewConfig
    }
}

/// WebView 配置类
public struct WebViewConfig {
    /// 是否启用 JavaScript
    public let javaScriptEnabled: Bool
    
    /// 是否启用 DOM Storage
    public let domStorageEnabled: Bool
    
    /// 是否允许文件访问
    public let allowFileAccess: Bool
    
    /// 是否允许地理位置
    public let geolocationEnabled: Bool
    
    /// 是否启用数据库存储
    public let databaseEnabled: Bool
    
    public init(
        javaScriptEnabled: Bool = true,
        domStorageEnabled: Bool = true,
        allowFileAccess: Bool = true,
        geolocationEnabled: Bool = true,
        databaseEnabled: Bool = true
    ) {
        self.javaScriptEnabled = javaScriptEnabled
        self.domStorageEnabled = domStorageEnabled
        self.allowFileAccess = allowFileAccess
        self.geolocationEnabled = geolocationEnabled
        self.databaseEnabled = databaseEnabled
    }
}