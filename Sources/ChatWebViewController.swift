import UIKit
import WebKit

/// 聊天 WebView 视图控制器
public class ChatWebViewController: UIViewController {
    
    // MARK: - Properties
    
    private var webView: WKWebView!
    private var progressView: UIProgressView?
    
    var baseUrl: String = ""
    var planId: String = ""
    var apiKey: String = ""
    var userId: String = ""
    var userEmail: String = ""
    var userName: String = ""
    var userAvatar: String?
    
    /// 窗口关闭回调
    var onDismiss: (() -> Void)?
    
    // 允许的域名白名单
    private let allowedDomains = ["cloudcx.cloudfon.net", "cloudfon.net", "cloudfon.com"]
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupWebView()
        loadChatPage()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressView?.removeFromSuperview()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // 关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 进度条
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
        view.addSubview(progressView)
        self.progressView = progressView
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupWebView() {
        // 配置 WKWebView
        let configuration = WKWebViewConfiguration()
        
        // 启用 JavaScript
        configuration.preferences.javaScriptEnabled = true
        
        // 允许自动打开窗口
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // 启用 DOM Storage
        configuration.websiteDataStore = .default()
        
        // 创建 WKWebView
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: progressView!.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 添加 JS Bridge 消息处理
        addJSBridgeMessageHandler()
        
        // 监听加载进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    private func addJSBridgeMessageHandler() {
        webView.configuration.userContentController.add(
            CloudFonJSBridgeMessageHandler(viewController: self),
            name: "CloudFonNative"
        )
    }
    
    // MARK: - Loading
    
    private func loadChatPage() {
        let chatUrl = buildChatUrl()
        
        guard let url = URL(string: chatUrl) else {
            showAlert(message: "Invalid base URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func buildChatUrl() -> String {
        guard !baseUrl.isEmpty else { return "" }
        
        var components = URLComponents(string: "\(baseUrl)/chat/WelcomeFormView")
        var queryItems: [URLQueryItem] = []
        
        // 添加语言参数
        queryItems.append(URLQueryItem(name: "lang", value: "en"))
        
        if !planId.isEmpty {
            queryItems.append(URLQueryItem(name: "planId", value: planId))
        }
        if !apiKey.isEmpty {
            queryItems.append(URLQueryItem(name: "apiKey", value: apiKey))
        }
        if !userId.isEmpty {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        if !userEmail.isEmpty {
            queryItems.append(URLQueryItem(name: "email", value: userEmail))
        }
        if !userName.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: userName))
        }
        if let avatar = userAvatar, !avatar.isEmpty {
            queryItems.append(URLQueryItem(name: "avatar", value: avatar))
        }
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        return components?.url?.absoluteString ?? ""
    }
    
    // MARK: - URL Validation
    
    private func isUrlAllowed(_ url: String?) -> Bool {
        guard let url = url else { return false }
        return allowedDomains.contains { url.contains($0) }
    }
    
    // MARK: - JS Injection
    
    private func injectCloudFonWebObject() {
        let jsCode = """
            window.CloudFonWeb = {
                call: function(method, params) {
                    window.webkit.messageHandlers.CloudFonNative.postMessage({
                        method: method,
                        params: JSON.stringify(params)
                    });
                },
                setButtonConfig: function(config) {
                    window.CloudFonWeb.call('setButtonConfig', config);
                },
                closeWindow: function() {
                    window.CloudFonWeb.call('closeWindow', {});
                },
                updateUser: function(attributes) {
                    window.CloudFonWeb.call('updateUser', attributes);
                },
                setTheme: function(theme) {
                    window.CloudFonWeb.call('setTheme', {theme: theme});
                },
                setLanguage: function(locale) {
                    window.CloudFonWeb.call('setLanguage', {locale: locale});
                },
                getNativeConfig: function() {
                    window.CloudFonWeb.call('getNativeConfig', {});
                }
            };
            
            // 供 Native 调用 JS 的回调
            window.CloudFonNative = {
                onUnreadCountChanged: function(count) {
                    console.log('Unread count changed:', count);
                },
                onMessageReceived: function(message) {
                    console.log('Message received:', message);
                },
                onWindowReady: function() {
                    console.log('Window ready');
                }
            };
        """
        
        webView.evaluateJavaScript(jsCode) { _, error in
            if let error = error {
                print("Error injecting CloudFonWeb: \(error)")
            }
        }
    }
    
    // MARK: - Native 调用 JS
    
    /// 调用 JS 方法
    func callJavaScript(method: String, params: [String: Any]? = nil, callback: ((Any?, Error?) -> Void)? = nil) {
        var jsCode = "window.CloudFonNative.\(method)("
        if let params = params {
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            if let jsonString = String(data: jsonData!, encoding: .utf8) {
                jsCode += jsonString
            }
        }
        jsCode += ")"
        
        webView.evaluateJavaScript(jsCode) { result, error in
            callback?(result, error)
        }
    }
    
    /// 通知 JS 未读数变化
    func notifyUnreadCountChanged(_ count: Int) {
        callJavaScript(method: "onUnreadCountChanged", params: ["count": count])
    }
    
    /// 通知 JS 收到新消息
    func notifyMessageReceived(_ message: [String: Any]) {
        callJavaScript(method: "onMessageReceived", params: message)
    }
    
    /// 通知 JS 窗口已准备好
    func notifyWindowReady() {
        callJavaScript(method: "onWindowReady")
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        onDismiss?()
        dismiss(animated: true)
    }
    
    // MARK: - KVO
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView?.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3) {
                    self.progressView?.alpha = 0
                }
            } else {
                progressView?.alpha = 1
            }
        }
    }
    
    // MARK: - Helpers
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // 添加内边距
        toastLabel.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

// MARK: - WKNavigationDelegate

extension ChatWebViewController: WKNavigationDelegate {
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }
        
        if isUrlAllowed(url) {
            decisionHandler(.allow)
        } else {
            showAlert(message: "URL not allowed")
            decisionHandler(.cancel)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectCloudFonWebObject()
    }
    
    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        showAlert(message: "Failed to load: \(error.localizedDescription)")
    }
}

// MARK: - WKUIDelegate

extension ChatWebViewController: WKUIDelegate {
    
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // 处理 JS 打开新窗口
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
}

// MARK: - CloudFonJSBridgeMessageHandler

class CloudFonJSBridgeMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var viewController: ChatWebViewController?
    
    init(viewController: ChatWebViewController) {
        self.viewController = viewController
        super.init()
    }
    
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
              let method = body["method"] as? String,
              let params = body["params"] as? String else {
            return
        }
        
        handleNativeCall(method: method, params: params)
    }
    
    private func handleNativeCall(method: String, params: String) {
        switch method {
        case "onUnreadCountChanged":
            if let count = Int(params) {
                CloudFonSDK.shared.updateUnreadCount(count)
            }
        case "onMessageTip":
            viewController?.showToast(message: params)
        case "requestCurrentUrl":
            // 返回当前页面 URL
            if let url = webView.url?.absoluteString {
                callJavaScript(method: "onCurrentUrlReceived", params: ["url": url])
            }
        case "getNativeConfig":
            // 返回 Native 配置给 JS
            let config = CloudFonSDK.shared.getConfig()
            let configJson: [String: Any] = [
                "baseUrl": config?.baseUrl ?? "",
                "planId": config?.planId ?? "",
                "debug": config?.debug ?? false
            ]
            callJavaScript(method: "onNativeConfigReceived", params: configJson)
        case "log":
            print("CloudFon Web Log: \(params)")
        default:
            print("Unknown method: \(method)")
        }
    }
}