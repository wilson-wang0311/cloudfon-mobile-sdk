import UIKit
import CloudFonMobileSDK

/// CloudFon SDK 示例视图控制器
/// SDK 为访客使用，无需登录认证
class ExampleViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let showChatButton = UIButton(type: .system)
    
    // 测试环境配置
    private let baseUrl = "https://cloudcx.cloudfon.net"
    private let planId = "95fb1eff-6453-4fce-a392-74fb3a5b9c0d"
    private let apiKey = "" // 无需 API Key
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initSDK()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "CloudFon SDK 示例"
        
        // 访客提示标签
        let guestLabel = UILabel()
        guestLabel.text = "访客模式，无需登录"
        guestLabel.textAlignment = .center
        guestLabel.font = .systemFont(ofSize: 14)
        guestLabel.textColor = .gray
        guestLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guestLabel)
        
        // 显示聊天按钮
        showChatButton.setTitle("打开聊天窗口", for: .normal)
        showChatButton.addTarget(self, action: #selector(showChatTapped), for: .touchUpInside)
        showChatButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showChatButton)
        
        // 测试环境标签
        let testEnvLabel = UILabel()
        testEnvLabel.text = "测试环境: cloudcx.cloudfon.net\nPlan ID: 95fb1eff-6453-4fce-a392-74fb3a5b9c0d"
        testEnvLabel.textAlignment = .center
        testEnvLabel.font = .systemFont(ofSize: 12)
        testEnvLabel.textColor = .gray
        testEnvLabel.numberOfLines = 0
        testEnvLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testEnvLabel)
        
        // 布局约束
        NSLayoutConstraint.activate([
            guestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            guestLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            guestLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            showChatButton.topAnchor.constraint(equalTo: guestLabel.bottomAnchor, constant: 32),
            showChatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            showChatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            showChatButton.heightAnchor.constraint(equalToConstant: 44),
            
            testEnvLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            testEnvLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            testEnvLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func initSDK() {
        // 创建配置
        let config = CloudFonConfig(
            baseUrl: baseUrl,
            planId: planId,
            apiKey: apiKey,
            debug: true // 启用调试模式
        )
        
        // 初始化 SDK
        CloudFonSDK.shared.initialize(config: config)
        
        // 注册未读数变化监听
        CloudFonSDK.shared.unreadCountChangedCallback = { [weak self] count in
            self?.showToast(message: "未读数: \(count)")
        }
        
        showToast(message: "CloudFon SDK 已初始化")
    }
    
    // MARK: - Actions
    
    @objc private func showChatTapped() {
        // 显示聊天窗口
        CloudFonSDK.shared.showMessenger(from: self)
    }
    
    // MARK: - Helpers
    
    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}