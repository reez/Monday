//
//  QRView.swift
//
//
//  Created by Daniel Nordh on 2/19/25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

public struct QRView: View {
    public var paymentAddress: PaymentAddress?

    public var body: some View {
        if let address = paymentAddress {
            Image(uiImage: generateQRCode(from: address.qrString))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Text("No Address")
        }
    }

    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
