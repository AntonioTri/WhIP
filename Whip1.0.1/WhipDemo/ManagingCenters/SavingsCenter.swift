//
//  SavingsCenter.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 28/03/24.
//

import Foundation

// Questa classe è molto semplice quanto importante, salva i dati che le vengono mandate in un database
// Chiave-Valore locale all'interno dell'iPhone. Possiede 2 tipologie di metodi
// I metodi per salvare un tipo di dato fondamentale
// I metodi per ottenere informazioni salvate

// !!! Le chiavi per i dati da salvare vanno dichiarate nella classe delle costanti !!!

class SavingsCenter {
    
    // Queste sono tutte le chiavi che identificano i dati salvati nel
    // Database interno
    public let FIRST_GAMEPLAY_EVER = "FGE"
    public let COMMON_FISH_SHOWED_UP = "ComonFishShowedUp"
    public let FLY_TUTORIAL = "flyTutorial"
    public let BLOW_TUTORIAL = "blowTutorial"
    public let NOTIFICATION_HOUR = "notifichescionHour"
    public let GUI_HOUR_SAVED = "GuiHourSaved"
    public let SKSCRIPT_HOUR_SAVED = "SKScriptHourSaved"
    public let TABLE_GENERATED = "TableGenerated"
    public let SEED_GENERATED = "SeedGenerated"
    public let CURRENT_SEED = "CurrentSeed"
    public let HOUR_SAVED = "HourSaved"
    public let DAY_SAVED = "DaySaved"
    public let MONTH_SAVED = "MonthSaved"
    
    
    // Con questo metodo salviamo una STRINGA nel database
    func saveString(dataToSave: String, key: String ){
        UserDefaults.standard.set(dataToSave, forKey: key)
    }
    
    // Con questo metodo salviamo un VALORE BOOLEANO nel database
    func saveBool(dataToSave: Bool, key: String){
        UserDefaults.standard.set(dataToSave, forKey: key)
    }
    
    // Con questo metodo salviamo un INTERO nel database
    func saveInteger(dataToSave: Int, key: String){
        UserDefaults.standard.set(dataToSave, forKey: key)
    }
    
    // Con questo metodo salviamo una ARRAY DI INTERI nel database
    func saveIntArray(dataToSave: [Int], key: String) {
        UserDefaults.standard.set(dataToSave, forKey: key)
    }
    
    // Con questo metodo cerchiamo e ritorniamo una STRINGA dal database
    // Se la chiave ricercata NON è mai stata salvata viene ritornata una stringa vuota
    func getSavedString(key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    // Con questo metodo cerchiamo e ritorniamo un VALORE BOOLEANO dal database
    // Se la chiave ricercata NON è mai stata salvata viene ritornato FALSE di default
    func getSavedBool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // Con questo metodo cerchiamo e ritorniamo un INTERO dal database
    // Se la chiave ricercata NON è mai stata salvata viene ritornato 0
    func getSavedInteger(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // Con questo metodo cerchiamo e ritorniamo un ARRAY DI INTERI dal database
    // Se la chiave ricercata NON è mai stata salvata, viene ritornata una matrice vuota
    func getSavedIntArray(key: String) -> [Int] {
        return UserDefaults.standard.array(forKey: key) as? [Int] ?? []
    }
    
}
