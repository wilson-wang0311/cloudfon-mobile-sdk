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
        label.text = "访客模式，无需登录"
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
        button.setTitle("打开聊天窗口", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(openChatTapped), for: .touchUpInside)
        return button
    }()

    private lazy var testUnreadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("测试未读数变化", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(testUnreadTapped), for: .touchUpInside)
        return button
    }()

    private lazy var trackEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送埋点事件", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(trackEventTapped), for: .touchUpInside)
        return button
    }()

    private let unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "未读数: 0"
        return label
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
        view.addSubview(testUnreadButton)
        view.addSubview(trackEventButton)
        view.addSubview(unreadCountLabel)
        view.addSubview(configInfoLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
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
            make.top.equalTo(statusLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(50)
        }

        testUnreadButton.snp.makeConstraints { make in
            make.top.equalTo(openChatButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        trackEventButton.snp.makeConstraints { make in
            make.top.equalTo(testUnreadButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        unreadCountLabel.snp.makeConstraints { make in
            make.top.equalTo(trackEventButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        configInfoLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
    }

    private func setupCallbacks() {
        CloudFonSDK.shared.unreadCountChangedCallback = { [weak self] count in
            DispatchQueue.main.async {
                self?.unreadCountLabel.text = "未读数: \(count)"
                self?.showToast(message: "未读数变化: \(count)")
            }
        }
    }

    // MARK: - Actions

    @objc private func openChatTapped() {
        CloudFonSDK.shared.showMessenger(from: self)
    }

    @objc private func testUnreadTapped() {
        unreadCount += 1
        CloudFonSDK.shared.updateUnreadCount(unreadCount)
        showToast(message: "已更新未读数: \(unreadCount)")
    }

    @objc private func trackEventTapped() {
        CloudFonSDK.shared.trackEvent(
            name: "demo_button_clicked",
            properties: [
                "button_name": "track_event",
                "timestamp": Date().timeIntervalSince1970
            ]
        )
        showToast(message: "埋点事件已发送")
    }

    // MARK: - Helpers

    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
