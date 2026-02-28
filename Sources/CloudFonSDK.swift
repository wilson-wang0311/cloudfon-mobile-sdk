import Foundation
import UIKit
import WebKit

/// CloudFon Mobile SDK 主入口类
/// SDK 为访客使用，无需登录认证
public final class CloudFonSDK {
    
    // MARK: - Singleton
    
    public static let shared = CloudFonSDK()
    
    // MARK: - Properties
    
    private var config: CloudFonConfig?
    private var isInitialized = false
    
    /// 未读数
    public private(set) var unreadCount: Int = 0 {
        didSet {
            unreadCountChangedCallback?(unreadCount)
        }
    }
    
    /// 聊天窗口是否可见
    public private(set) var isMessengerVisible: Bool = false
    
    /// 未读数变化回调
    public var unreadCountChangedCallback: ((Int) -> Void)?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 初始化 SDK
    /// - Parameter config: SDK 配置
    public func initialize(config: CloudFonConfig) {
        self.config = config
        self.isInitialized = true
        
        if config.debug {
            print("CloudFon SDK initialized in debug mode")
        }
        
        // 初始化推送服务
        initializePushService()
    }
    
    /// 显示聊天窗口（访客模式，无需登录）
    /// - Parameter viewController: 父视图控制器
    public func showMessenger(from viewController: UIViewController) {
        checkInitialized()
        
        let chatViewController = ChatWebViewController()
        chatViewController.modalPresentationStyle = .fullScreen
        
        if let cfg = config {
            chatViewController.baseUrl = cfg.baseUrl
            chatViewController.planId = cfg.planId
            chatViewController.apiKey = cfg.apiKey
        }
        
        viewController.present(chatViewController, animated: true)
        isMessengerVisible = true
    }
    
    /// 隐藏聊天窗口
    public func hideMessenger() {
        isMessengerVisible = false
    }
    
    /// 设置 Launcher 按钮可见性
    /// - Parameter visible: 是否可见
    public func setLauncherVisible(_ visible: Bool) {
        // TODO: 实现浮动按钮显示/隐藏
    }
    
    /// 埋点事件
    /// - Parameters:
    ///   - name: 事件名称
    ///   - properties: 事件属性
    public func trackEvent(name: String, properties: [String: Any]? = nil) {
        if config?.debug == true {
            print("CloudFonSDK Track event: \(name), properties: \(String(describing: properties))")
        }
    }
    
    /// 更新未读数
    /// - Parameter count: 未读数
    public func updateUnreadCount(_ count: Int) {
        unreadCount = count
    }
    
    /// 获取当前配置
    public func getConfig() -> CloudFonConfig? {
        return config
    }
    
    /// SDK 是否已初始化
    public func isReady() -> Bool {
        return isInitialized
    }
    
    // MARK: - Private Methods
    
    private func checkInitialized() {
        guard isInitialized else {
            fatalError("CloudFonSDK not initialized. Call initialize() first.")
        }
    }
    
    private func initializePushService() {
        // TODO: 集成 APNs 推送服务
    }
}