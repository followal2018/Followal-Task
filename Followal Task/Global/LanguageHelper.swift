//
//  LanguageHelper.swift
//  PMR
//
//  Created by PC on 12/5/18.
//  Copyright © 2018 PC. All rights reserved.
//

import Foundation

enum Language: String {
    case english = "en"
    case swedish = "sv"
}

class LanguageHelper {
    
    static let shared = LanguageHelper()
    var isEnglish = true
    var language = Language.english.rawValue
    
    init() {
        isEnglish = true
        language = Language.english.rawValue
    }
    
    func set(lang: Language) {
        language = Language.english.rawValue
        switch lang
        {
        case .english:
            isEnglish = true
            UserDefaults.standard.set(Language.english.rawValue, forKey: "appLang")
            
        case .swedish:
            isEnglish = false
            UserDefaults.standard.set(Language.english.rawValue, forKey: "appLang")
        }
    }
}

func LocalizedString(key: String) -> String {
    let language:String!
    
    if LanguageHelper.shared.isEnglish {
        language = "Base"
    } else {
        language = "sv"
    }
    
    let path = Bundle.main.path(forResource: language, ofType: "lproj")
    let bundle = Bundle(path: path!)
    
    return (bundle?.localizedString(forKey: key, value: "", table: nil))!
}

extension String {
    
    var localized: String {
        return LocalizedString(key: self)
    }
}
