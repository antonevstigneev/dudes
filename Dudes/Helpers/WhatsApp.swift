//
//  WhatsApp.swift
//  Dudes
//
//  Created by Anton Evstigneev on 12.01.2021.
//

import Foundation
import UIKit


class WAStickerPack {

    let identifier: String // "dudes-\(stickerpack.id)"
    let name: String = "Dudes"
    let publisher: String = "Dudes Stickers"
    let trayImage: String // self.sticker.image!.pngData()?.base64EncodedString() <- put data of the first sticker from stickerpack here
    let publisherWebsite: String = ""
    let privacyPolicyWebsite: String = ""
    let licenseAgreementWebsite: String = ""

    var stickers: [WASticker]

    init(identifier: String, trayImagePNGData: String) {
        
        self.identifier = identifier
        self.trayImage = trayImagePNGData
        
        stickers = []
    }

    func addSticker(imageData: String, emojis: [String]?) {

        let sticker: WASticker = WASticker(imageData: imageData, emojis: emojis)

        stickers.append(sticker)
    }


    /**
     *  Sends current sticker pack to WhatsApp.
     *
     *  - Parameter completionHandler: block that gets called when the sticker pack has been wrapped
     *    into a format that WhatsApp can read and WhatsApp is about to open. Called on the main
     *    queue.
     */
    func sendToWhatsApp(completionHandler: @escaping (Bool) -> Void) {
        var json: [String: Any] = [:]
        json["identifier"] = self.identifier
        json["name"] = self.name
        json["publisher"] = self.publisher
        json["tray_image"] = self.trayImage

        var stickersArray: [[String: Any]] = []
        for sticker in self.stickers {
            var stickerDict: [String: Any] = [:]

            stickerDict["image_data"] = sticker.imageData
            stickerDict["emojis"] = sticker.emojis
            print(stickerDict)

            stickersArray.append(stickerDict)
        }
        json["stickers"] = stickersArray

        let result = WAInteroperability.send(json: json)
        DispatchQueue.main.async {
            completionHandler(result)
        }
    }
}


class WASticker {

    let imageData: String
    let emojis: [String]?

    init(imageData: String, emojis: [String]?) {
        self.imageData = imageData
        self.emojis = emojis
    }

}


struct WAInteroperability {
    private static let DefaultBundleIdentifier: String = "com.getdudesapp.DudesStickers"
    private static let PasteboardExpirationSeconds: TimeInterval = 60
    private static let PasteboardStickerPackDataType: String = "net.whatsapp.third-party.sticker-pack"
    private static let WhatsAppURL: URL = URL(string: "whatsapp://stickerPack")!

    static var iOSAppStoreLink: String?
    static var AndroidStoreLink: String?

    static func canSend() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!)
    }
    
    static func send(json: [String: Any]) -> Bool {
        if Bundle.main.bundleIdentifier?.contains(DefaultBundleIdentifier) == true {
          fatalError("Your bundle identifier must not include the default one.")
        }

        let pasteboard = UIPasteboard.general

        var jsonWithAppStoreLink: [String: Any] = json
        jsonWithAppStoreLink["ios_app_store_link"] = iOSAppStoreLink
        jsonWithAppStoreLink["android_play_store_link"] = AndroidStoreLink

        guard let dataToSend = try? JSONSerialization.data(withJSONObject: jsonWithAppStoreLink, options: []) else {
            return false
        }

        if #available(iOS 10.0, *) {
            pasteboard.setItems([[PasteboardStickerPackDataType: dataToSend]], options: [UIPasteboard.OptionsKey.localOnly: true, UIPasteboard.OptionsKey.expirationDate: NSDate(timeIntervalSinceNow: PasteboardExpirationSeconds)])
        } else {
            pasteboard.setData(dataToSend, forPasteboardType: PasteboardStickerPackDataType)
        }

        DispatchQueue.main.async {
            if canSend() {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(WhatsAppURL)
                } else {
                    UIApplication.shared.openURL(WhatsAppURL)
                }
            }
        }
        return true
    }
}


struct WAStickerEmojis {

    public func canonicalizedEmojis(rawEmojis: [String]?) throws -> [String]? {

        guard let rawEmojis = rawEmojis else { return nil }
        var canonicalizedEmojis: [String] = []

        rawEmojis.forEach { rawEmoji in

            var emojiToAdd = WAStickerEmojis.canonicalizedEmoji(emoji: rawEmoji)

          // If the emoji somehow isn't canonicalized, we'll use the original emoji
          if emojiToAdd.isEmpty {
            emojiToAdd = rawEmoji
          }

          canonicalizedEmojis.append(emojiToAdd)
        }

        return canonicalizedEmojis
    }

    public static func canonicalizedEmoji(emoji: String) -> String {
        var nonExtensionUnicodes: [Character] = []

        for scalar in emoji.unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,    // Emoticons
            0x1F300...0x1F5FF,         // Misc symbols and pictographs
            0x1F680...0x1F6FF,         // Transport and maps
            0x2600...0x26FF,           // Misc symbols
            0x2700...0x27BF,           // Dingbats
            0x1F1E6...0x1F1FF,         // Flags
            0x1F900...0x1F9FF,         // Supplemental symbols and pictographs
            0x200D:                    // Zero-width joiner
                nonExtensionUnicodes.append(Character(UnicodeScalar(scalar.value)!))

            default:
                continue
            }
        }

        var canonicalizedEmoji = ""

        nonExtensionUnicodes.forEach { canonicalizedEmoji.append($0) }
        return canonicalizedEmoji
    }
}
