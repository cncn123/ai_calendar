import Foundation
import SwiftUI

private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language: String) {
        defer { object_setClass(Bundle.main, PrivateBundle.self) }
        objc_setAssociatedObject(Bundle.main, &bundleKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let language = objc_getAssociatedObject(self, &bundleKey) as? String
        guard let language = language, language != "system",
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            Bundle.setLanguage(currentLanguage)
        }
    }
    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage")
        currentLanguage = saved ?? "system"
        if let lang = saved, lang != "system" {
            Bundle.setLanguage(lang)
        }
    }
} 