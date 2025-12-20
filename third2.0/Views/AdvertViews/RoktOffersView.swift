//
//  RoktOffersView.swift
//  Night Prayers
//

import SwiftUI
import UIKit
import Rokt_Widget

// MARK: - UIViewController wrapper

final class RoktOffersViewController: UIViewController {

    private let viewName: String
    private let userEmail: String?

    var onLoad: (() -> Void)?
    var onUnload: (() -> Void)?
    var onShowLoading: (() -> Void)?
    var onHideLoading: (() -> Void)?
    var onEmbeddedSizeChange: ((String, CGFloat) -> Void)?

    private let embeddedView = RoktEmbeddedView()

    init(viewName: String, userEmail: String?) {
        self.viewName = viewName
        self.userEmail = userEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        embeddedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(embeddedView)

        NSLayoutConstraint.activate([
            embeddedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            embeddedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            embeddedView.topAnchor.constraint(equalTo: view.topAnchor),
            embeddedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        var attributes: [String: String] = [:]
        if let email = userEmail {
            attributes["email"] = email
        }

        Rokt.execute(
            viewName: viewName,
            attributes: attributes,
            placements: [
                "default": embeddedView
            ],
            onLoad: { [weak self] in
                self?.onLoad?()
            },
            onUnLoad: { [weak self] in
                self?.onUnload?()
            },
            onShouldShowLoadingIndicator: { [weak self] in
                self?.onShowLoading?()
            },
            onShouldHideLoadingIndicator: { [weak self] in
                self?.onHideLoading?()
            },
            onEmbeddedSizeChange: { [weak self] placement, height in
                self?.onEmbeddedSizeChange?(placement, height)
            }
        )
    }
}

// MARK: - SwiftUI bridge

struct RoktOffersView: UIViewControllerRepresentable {

    let viewName: String
    let userEmail: String?

    @Binding var isLoading: Bool
    @Binding var hasError: Bool

    func makeUIViewController(context: Context) -> RoktOffersViewController {
        let controller = RoktOffersViewController(
            viewName: viewName,
            userEmail: userEmail
        )

        controller.onLoad = {
            DispatchQueue.main.async {
                isLoading = false
                hasError = false
            }
        }

        controller.onUnload = {
            DispatchQueue.main.async {
                hasError = true
                isLoading = false
            }
        }

        controller.onShowLoading = {
            DispatchQueue.main.async {
                isLoading = true
            }
        }

        controller.onHideLoading = {
            DispatchQueue.main.async {
                isLoading = false
            }
        }

        controller.onEmbeddedSizeChange = { _, _ in
            // height provided if you want to adapt layout
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: RoktOffersViewController,
        context: Context
    ) {
        // no-op
    }
}

// MARK: - Container view

struct RoktOffersContainer: View {

    let userEmail: String?

    @State private var isLoading = true
    @State private var hasError = false

    private let roktViewName = "your_rokt_view_name"

    var body: some View {
        VStack(spacing: 12) {
            if isLoading {
                ProgressView().padding()
            } else if hasError {
                Text("Unable to load offers")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                RoktOffersView(
                    viewName: roktViewName,
                    userEmail: userEmail,
                    isLoading: $isLoading,
                    hasError: $hasError
                )
                .frame(minHeight: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}
