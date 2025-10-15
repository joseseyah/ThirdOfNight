import SwiftUI
import GoogleMobileAds

struct BannerAdController: UIViewControllerRepresentable {
    let adUnitID: String   // e.g. "ca-app-pub-3940256099942544/2934735716" (TEST)

    func makeUIViewController(context: Context) -> BannerHostVC {
        BannerHostVC(adUnitID: adUnitID)
    }

    func updateUIViewController(_ uiViewController: BannerHostVC, context: Context) {
        uiViewController.reloadIfWidthChanged()
    }
}

final class BannerHostVC: UIViewController {
    private let adUnitID: String
    private var banner: BannerView?
    private var lastWidth: CGFloat = 0

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadBanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadIfWidthChanged()
    }

    func reloadIfWidthChanged() {
        let w = view.bounds.inset(by: view.safeAreaInsets).width
        guard abs(w - lastWidth) > 1 else { return }
        lastWidth = w
        loadBanner()
    }

    private func loadBanner() {
        banner?.removeFromSuperview()

      let width = lastWidth > 0 ? lastWidth : view.bounds.width
      let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)

        let bv = BannerView(adSize: adSize)
        bv.adUnitID = adUnitID
        bv.rootViewController = RootViewFinder.topMost(from: self) ?? self
        bv.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bv)
        NSLayoutConstraint.activate([
            bv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bv.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        bv.load(Request())
        banner = bv
    }
}

enum RootViewFinder {
    static func topMost(from seed: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        if let nav = seed as? UINavigationController { return topMost(from: nav.visibleViewController) }
        if let tab = seed as? UITabBarController { return topMost(from: tab.selectedViewController) }
        if let presented = seed?.presentedViewController { return topMost(from: presented) }
        return seed
    }
}
