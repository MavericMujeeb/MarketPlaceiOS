//
//  StorageManager.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 22/08/23.
//

import Foundation


class StorageManager {
    
    static let shared = StorageManager()
    let preferences = UserDefaults.standard
    
    func getValueForKey (key:String) -> String {
        return preferences.value(forKey: key) as! String
    }
    
    func setValueForKey (key:String, value:String){
        preferences.set(value, forKey: key)
    }
    
    func getBoolForKey (key:String) -> Bool {
        return preferences.value(forKey: key) as! Bool
    }
    
    func setBoolForKey (key:String, value:Bool) {
        preferences.set(value, forKey: key)
    }
}
