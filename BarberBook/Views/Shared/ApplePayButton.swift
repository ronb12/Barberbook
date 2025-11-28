// ApplePayButton.swift
// Wraps PKPaymentButton so we can place it anywhere in SwiftUI.

import SwiftUI
import PassKit

struct ApplePayButtonView: UIViewRepresentable {
    var type: PKPaymentButtonType = .buy
    var style: PKPaymentButtonStyle = .automatic
    var cornerRadius: CGFloat = 8
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        button.cornerRadius = cornerRadius
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) {
        uiView.isEnabled = context.environment.isEnabled
    }

    final class Coordinator: NSObject {
        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTapButton() {
            action()
        }
    }
}
