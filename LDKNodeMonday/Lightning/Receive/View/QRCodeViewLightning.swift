//
//  QRCodeViewLightning.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 6/2/23.
//

import SwiftUI

struct QRCodeViewLightning: View {
    var invoice: String
    
    var body: some View {
        Image(uiImage: generateQRCode(from: "lightning:\(invoice)"))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .padding()
    }
}

extension QRCodeViewLightning {
    func generateQRCode(from string: String) -> UIImage {
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

struct QRCodeViewLightning_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeViewLightning(
            invoice: "lntbs250u1pj8nu3pdqqpp5v3gsc0wynjm9lsj87jalf6aa8wq5ug6hpx69v5apeq5fuls8yulqsp5luac924ste9k0npj4uhvu2sw9gsq4sw0nk25jjrs0tnhkqcrc9nq9qrsgqcqpjnp4qwes4kw4v57ntfrjkk4adj3a5d665kny9k8prrv6x5ny65fx4epy7xqrrssrzjqftf3ny6cc3lt5d67433puh3kcklllhy8l7dktpqej65racyjl25qqqqqqqqqqqqqyqqqqqqqqqqqqqqrck0lcr089d6pas5ggtt7larv8l5hel6amezcqjpcas6t9dxdncwhrlk8rcle7ms6l85t4365s9zrvzjtgq4nrduf4l5l0xk4253xj8hgq7d3zh7"
        )
    }
}
