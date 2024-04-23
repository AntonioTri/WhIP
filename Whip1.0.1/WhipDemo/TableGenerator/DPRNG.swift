//
//  PNRG.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 30/03/24.
//

import Foundation



// Questa struttura è la DPRGN ( Deterministic Pseudo Radom Number Generator )
// Genera delle sequenze di numeri pseudo casuali sulla base di un seed scelto da noi
// Il seed è generato falla funzione generateSeed dela classe TableGenerator
struct DPRNG {
    
    private var seed: UInt64 = 0
    private let savingCenter = SavingsCenter()
    
    // Quando la classe viene istanziata effettua i calcoli per generare il seed
    // Sulla base della data ed ora corrente se la flag in ingresso arriva falsa
    // Altrimenti genererà un seed speciale, ovvero quello della prossima sessione
    // Di gameplay, ad esempio, se giochiamo di mattina e la flag n ingresso è vera,
    // Verrà generato il seed del pomeriggio, questo serve alla TableGenerator per
    // Schedulare la prossima notifica all'interno del dispositivo
    init(generateNextSeed: Bool) {
        
        if generateNextSeed {
            self.seed = UInt64(generateNextSessionSeed())
        } else {
            self.seed = UInt64(generateSeed())
        }
        
    }

    // La funzione next ci permette di avere un numero randomico sulla base del seed attuale
    // Ogni qual volta questa viene chiamata, bisogna reinizializzare l'istanza o la variabile seed
    // per far ripartire la sequenza da 0
    mutating func next() -> UInt64 {
        // Algoritmo lineare congruenziale (LCG)
        let a: UInt64 = 1664525
        let c: UInt64 = 1013904223
        let m: UInt64 = 4294967296 // 2^32

        seed = (a &* seed &+ c) % m
        return seed % 1772 // Restituisce un numero tra 0 e 1771
    }
    
    // Seed generation Function
    private func generateSeed() -> Int{
        
        let calendar = Calendar.current
        
        // Queste 3 funzioni controllano se vi è stato un cambiamento in una di queste 3
        // Caratteristiche, andando a segnalare in questo caso, il cambiamento
        let currentHour = checkHourChanged(calendar: calendar)
        let currentDay = checkDayChanged(calendar: calendar)
        let currentMonth = checkMonthChanged(calendar: calendar)
        
        // Questo controllo fallisce se è fallito anche il precedente if, serve a generare un nuovo seed
        // Sulla base della data e dell'ora
        if !savingCenter.getSavedBool(key: savingCenter.SEED_GENERATED) {
            
            print("Qualcosa è cambiato, genero un nuovo seed.")
            // Autolock
            savingCenter.saveBool(dataToSave: true, key: savingCenter.SEED_GENERATED)
            
            // Interpoliamo data mese ed ora per generare un intero unico
            // E lo salviamo come seed corrente
            let seed = Int("\(currentDay)" + "\(currentMonth)" + "\(currentHour)")
            savingCenter.saveInteger(dataToSave: seed!, key: savingCenter.CURRENT_SEED)
            
            // Ritorniamo il seed corrente una volta creato
            print("Nuovo seed generato: \(seed!)")
            return seed!
            
        } else {
            // Nel caso il seed sia stato già generato perchè l'orario coincide con quello dell'ultima
            // sessione di gioco
            print("Non ho generato un nuovo seed, seed attuale: \(savingCenter.getSavedInteger(key: savingCenter.CURRENT_SEED))")
            return savingCenter.getSavedInteger(key: savingCenter.CURRENT_SEED)
        }
        
    }
    
    // Questa funzione è divesa dalla precedente, di fatto il seed che restituisce non è quello
    // Attuale ma il prossimo, relativo alla prossima sessio di gioco in cui le percentuali cambiano
    private func generateNextSessionSeed() -> Int{
        
        // Si estraggono le informazioni in modo diretto, senza controllare che siano cambiate
        // A differenza della funzione precedente
        let calendar = Calendar.current
        let date = Date()
        
        let currentHour = calendar.component(.hour, from: date)
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        
        var nextHour = 0
        var nextDay = 0
        var nextMonth = 0
        
        // Dopodichè si trovano le successive
        //Per le ore
        if currentHour >= 9 && currentHour < 15 {
            nextHour = 1
        } else if currentHour >= 15 && currentHour < 21 {
            nextHour = 2
            
            // Se l'ora corrente è tra le 21 e mezzanotte alle 24 il seed ricambierà
            // Pertanto in questo caso viene anche fatto il calcolo sul giorno
            // facendo attenzione a rispettare il numero di giorni di quel mese
        } else if (currentHour >= 21 && currentHour < 24) || (currentHour > 0 && currentHour < 9) {
            nextHour = 0
            
            if currentHour > 0 && currentHour < 9 {
                switch currentMonth {
                case 4, 6, 9, 11:
                    if currentDay == 30 {
                        nextDay = 1
                        nextMonth = getNextMonth(currentMonth: currentMonth)
                    } else {
                        nextDay += 1
                    }
                case 1, 3, 5, 7, 8, 10, 12:
                    if currentDay == 31 {
                        nextDay = 1
                        nextMonth = getNextMonth(currentMonth: currentMonth)
                    } else {
                        nextDay += 1
                    }
                default:
                    nextDay = savingCenter.getSavedInteger(key: savingCenter.MONTH_SAVED)
                }
            }
            
        }
        
        return Int("\(nextMonth)\(nextDay)\(nextHour)") ?? savingCenter.getSavedInteger(key: savingCenter.CURRENT_SEED)
        
    }
    
    private func getNextMonth(currentMonth: Int) -> Int {
        
        if currentMonth == 12 {
            return 1
        } else {
            return currentMonth + 1
        }
        
    }
    
    private func checkHourChanged(calendar: Calendar) -> Int{
        // Vengono estratte l'ora corrente e quella dell'ultima generazione seed
        let currentHour = findHour(calendar: calendar)
        let previousHour = savingCenter.getSavedInteger(key: savingCenter.HOUR_SAVED)
        
        // Se queste sono diverse viene segnalato che il seed deve essere rigenerato
        // e si salva l'ora corrente come quella attuale
        if currentHour != previousHour {
            savingCenter.saveBool(dataToSave: false, key: savingCenter.SEED_GENERATED)
            savingCenter.saveInteger(dataToSave: currentHour, key: savingCenter.HOUR_SAVED)
            // Viene ritornata la nuova ora corrente se questa è cambiata
            return currentHour
        } else {
            // Altrimenti si ritorna quella salvata
            return savingCenter.getSavedInteger(key: savingCenter.HOUR_SAVED)
        }
    }
    
    // La stessa operazione viene fatta sul giorno ...
    private func checkDayChanged(calendar: Calendar) -> Int{
        
        let currentDay = calendar.component(.day, from: Date())
        let previousDay = savingCenter.getSavedInteger(key: savingCenter.DAY_SAVED)
        
        if currentDay != previousDay {
            savingCenter.saveBool(dataToSave: false, key: savingCenter.SEED_GENERATED)
            savingCenter.saveInteger(dataToSave: currentDay, key: savingCenter.DAY_SAVED)
            return currentDay
        } else {
            return savingCenter.getSavedInteger(key: savingCenter.DAY_SAVED)
        }
        
    }
    
    // ... e sul mese
    private func checkMonthChanged(calendar: Calendar) -> Int{
        
        let currentMonth = calendar.component(.month, from: Date())
        let previousMonth = savingCenter.getSavedInteger(key: savingCenter.MONTH_SAVED)
        
        if currentMonth != previousMonth {
            savingCenter.saveBool(dataToSave: false, key: savingCenter.SEED_GENERATED)
            savingCenter.saveInteger(dataToSave: currentMonth, key: savingCenter.MONTH_SAVED)
            return currentMonth
        } else {
            return savingCenter.getSavedInteger(key: savingCenter.MONTH_SAVED)
        }
        
    }
    
    // Questa funzione serve a normalizzare il valore dell'ora per indicare 3 fasce orarie specifiche
    // 0 indica il giorno, 1 il pomeriggio e 2 sera e notte
    private func findHour(calendar: Calendar) -> Int {
     
        var hour = calendar.component(.hour, from: Date())
        
        if hour >= 9 && hour < 15 {
            hour = 0
        } else if hour >= 15 && hour < 21 {
            hour = 1
        } else if (hour >= 21 && hour <= 24) || (hour > 0 && hour < 9) {
            hour = 2
        }
        
        return hour
    }
}



