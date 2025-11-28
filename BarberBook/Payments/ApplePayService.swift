// ApplePayService.swift
// Encapsulates PKPaymentAuthorizationController usage so SwiftUI views can stay declarative.

import Foundation
import PassKit

/// Static configuration used when building Apple Pay payment requests.
struct ApplePayConfiguration {
    /// Update with your real merchant identifier in Xcode once Apple Pay is fully provisioned.
    static let merchantIdentifier = "merchant.com.example.BarberBook"
    static let countryCode = "US"
    static let currencyCode = "USD"
    static let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover]
    static let merchantCapabilities: PKMerchantCapability = [.capability3DS, .capabilityCredit, .capabilityDebit]
}

/// Errors that can surface while attempting an Apple Pay payment.
enum ApplePayError: LocalizedError {
    case serviceMissing
    case unableToPresent
    case cancelled

    var errorDescription: String? {
        switch self {
        case .serviceMissing:
            return "No service is attached to this booking."
        case .unableToPresent:
            return "Apple Pay could not be presented on this device."
        case .cancelled:
            return "Payment was cancelled before completion."
        }
    }
}

final class ApplePayService: NSObject {
    static let shared = ApplePayService()

    private var completion: ((Result<Void, Error>) -> Void)?
    private var didAuthorize = false

    /// Checks whether the device can process payments with the declared networks.
    var isApplePayAvailable: Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: ApplePayConfiguration.supportedNetworks)
    }

    /// Presents the Apple Pay sheet for the provided booking. The caller is responsible for updating persistence once the payment succeeds.
    func presentPayment(for booking: Booking, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let service = booking.service else {
            DispatchQueue.main.async {
                completion(.failure(ApplePayError.serviceMissing))
            }
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayConfiguration.merchantIdentifier
        request.countryCode = ApplePayConfiguration.countryCode
        request.currencyCode = ApplePayConfiguration.currencyCode
        request.merchantCapabilities = ApplePayConfiguration.merchantCapabilities
        request.supportedNetworks = ApplePayConfiguration.supportedNetworks

        let price = NSDecimalNumber(value: service.price)
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: service.name, amount: price),
            PKPaymentSummaryItem(label: "BarberBook", amount: price)
        ]

        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        self.completion = completion
        didAuthorize = false

        controller.present { presented in
            guard presented else {
                DispatchQueue.main.async {
                    completion(.failure(ApplePayError.unableToPresent))
                }
                self.cleanup()
                return
            }
        }
    }

    private func cleanup() {
        completion = nil
        didAuthorize = false
    }
}

extension ApplePayService: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        didAuthorize = true
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        DispatchQueue.main.async { [weak self] in
            self?.completion?(.success(()))
            self?.cleanup()
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            guard let self else { return }
            guard self.didAuthorize else {
                DispatchQueue.main.async { [weak self] in
                    self?.completion?(.failure(ApplePayError.cancelled))
                    self?.cleanup()
                }
                return
            }
        }
    }
}
