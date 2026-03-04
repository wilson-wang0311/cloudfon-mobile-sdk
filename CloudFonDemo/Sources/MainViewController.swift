import UIKit
import CloudFonMobileSDK
import SnapKit

class MainViewController: UIViewController {

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CloudFon SDK Demo"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "JS Bridge 测试"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.text = "SDK 已初始化"
        return label
    }()

    private lazy var openChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("打开测试页面", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(openTestPageTapped), for: .touchUpInside)
        return button
    }()

    private lazy var testJSBridgeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("测试 Native→Web 通信", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(testJSBridgeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送消息给 WebView", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
        return button
    }()

    private lazy var closeWindowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关闭 WebView", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(closeWindowTapped), for: .touchUpInside)
        return button
    }()

    private let logTextView: UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.text = "日志:\n"
        return textView
    }()

    private let configInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "测试环境: cloudcx.cloudfon.net\nPlan ID: 95fb1eff-6453-4fce-a392-74fb3a5b9c0d"
        return label
    }()

    // MARK: - Properties

    private var unreadCount: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "CloudFon Demo"

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(statusLabel)
        view.addSubview(openChatButton)
        view.addSubview(testJSBridgeButton)
        view.addSubview(sendMessageButton)
        view.addSubview(closeWindowButton)
        view.addSubview(logTextView)
        view.addSubview(configInfoLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        openChatButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }

        testJSBridgeButton.snp.makeConstraints { make in
            make.top.equalTo(openChatButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }

        sendMessageButton.snp.makeConstraints { make in
            make.top.equalTo(testJSBridgeButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }

        closeWindowButton.snp.makeConstraints { make in
            make.top.equalTo(sendMessageButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }

        logTextView.snp.makeConstraints { make in
            make.top.equalTo(closeWindowButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(150)
        }

        configInfoLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
    }

    private func setupCallbacks() {
        CloudFonSDK.shared.unreadCountChangedCallback = { [weak self] count in
            DispatchQueue.main.async {
                self?.addLog("未读数变化: \(count)")
            }
        }
    }

    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logTextView.text += "[\(timestamp)] \(message)\n"
        
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }

    // MARK: - Actions

    @objc private func openTestPageTapped() {
        // 使用本地测试页面或远程 URL
        let testPageURL = "https://raw.githubusercontent.com/wilson-wang0311/cloudfon-mobile-sdk/main/CloudFonDemo/Resources/test_page.html"
        
        // 修改 CloudFonConfig 使用测试页面
        let config = CloudFonConfig(
            baseUrl: testPageURL,
            planId: "test-plan-id",
            apiKey: "",
            debug: true
        )
        
        CloudFonSDK.shared.initialize(config: config)
        
        // 创建测试用的 ChatWebViewController
        let chatVC = ChatWebViewController()
        chatVC.baseUrl = testPageURL
        chatVC.planId = "test-plan-id"
        chatVC.modalPresentationStyle = .fullScreen
        
        present(chatVC, animated: true)
        addLog("已打开测试页面")
    }

    @objc private func testJSBridgeTapped() {
        // 测试调用 WebView 中的方法
        let testData: [String: Any] = [
            "event": "testEvent",
            "message": "Hello from Native!",
            "timestamp": Date().timeIntervalSince1970,
            "userId": "test-user-123"
        ]
        
        CloudFonSDK.shared.callJavaScriptMethod("onCustomEvent", params: testData) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.addLog("JS 调用失败: \(error.localizedDescription)")
                } else {
                    self?.addLog("JS 调用成功，结果: \(String(describing: result))")
                }
            }
        }
        
        addLog("发送自定义事件给 WebView")
    }

    @objc private func sendMessageTapped() {
        // 发送消息给 WebView
        let messageData: [String: Any] = [
            "type": "text",
            "content": "这是一条来自 Native 的测试消息",
            "from": "Native App",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        CloudFonSDK.shared.sendMessageToWebView(messageData)
        
        // 同时通知未读数
        unreadCount += 1
        CloudFonSDK.shared.notifyUnreadCountToWebView(unreadCount)
        
        addLog("发送消息: \(messageData["content"] ?? "")")
        addLog("通知未读数: \(unreadCount)")
    }

    @objc private func closeWindowTapped() {
        CloudFonSDK.shared.hideMessenger()
        addLog("已关闭 WebView")
    }
}
