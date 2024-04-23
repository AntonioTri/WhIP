//
//  NotificationCenter.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 28/03/24.
//

import Foundation
import UserNotifications

class NotificationCenter: NSObject, UNUserNotificationCenterDelegate, ObservableObject{
    
    var center: UNUserNotificationCenter!
    var content: UNMutableNotificationContent!
    
    // L'inizializzatore istanzia la reference per il centro di controllo notifiche
    // Delega alla classe il compito di "comandante" con delegate = self
    // Richiama la funzione ddella stessa classe che fa comparire la notifica di pop up per chiedere i permessi
    // di inviare notifiche (volendo la si può togliere dal costruttore e la si richiama in un altro momento
    // per non far comparire subito il pop up col rischio che l'utente clicchi istintivamente NO)
    override init() {
        super.init()
        center = UNUserNotificationCenter.current()
        center.delegate = self
        self.askForPermission()
    }
    
    // Questa funzione quando richiamata schedula una nuova notifica basata sul prossimo seed
    func scheduleNotification(currentTable: [[Int]], savingCenter: SavingsCenter){
            
        if !savingCenter.getSavedBool(key: savingCenter.FIRST_GAMEPLAY_EVER) {
            print("E' la prima volta che stai giocando, schedulo la prima notifica per la prossima fascia orarira")
            savingCenter.saveBool(dataToSave: true, key: savingCenter.FIRST_GAMEPLAY_EVER)
            createAndSendNotification(table: currentTable)
            //Salvare la facia oraria corrente
            savingCenter.saveInteger(dataToSave: findHour(calendar: Calendar.current), key: savingCenter.NOTIFICATION_HOUR)
            
        } else {
            
            // Estraggo la fascia oraria salvata e quella attuale
            let savedTime = savingCenter.getSavedInteger(key: savingCenter.NOTIFICATION_HOUR)
            let currentTime = findHour(calendar: Calendar.current)
            // Se sono diverse, schedulo una notifica con il carattere della prossima tavola
            if savedTime != currentTime {
                print("Stai giocando in una facia oraria diversa dalla precedente.\nSchedulo la nuova notifica per la prossima fascia orarira")
                createAndSendNotification(table: currentTable)
                // Salviamo inoltre anche la fascia oraria attuale così da impedire una nuova rischedula
                // Nel caso giocassimo due o più volte nella stessa fascia oraria
                savingCenter.saveInteger(dataToSave: currentTime, key: savingCenter.NOTIFICATION_HOUR)
            } else {
                print("Stai giocando nella stessa fascia oraria precedente, pertanto non schedulo una nuova notifica")
            }
                
        }
            
    }
    
     func createAndSendNotification(table: [[Int]]){
        
        let body = createNotificationBody(table: table)
        let title = "Something changed!"
        let hourToSend = chooseTimeToSend()
        
        print("Corpo della notifica generato in base alle previsioni:\n\(body)")
        print("Ora scelta per la consegna: \(hourToSend)\n")
        
        self.registerNotification(title: title, body: body, hour: hourToSend, daily: false)
        
    }
    
    private func createNotificationBody(table: [[Int]]) -> String {
        
        var mostCommonLegendaries: String
        var mostCommonEpics: String
        
        (mostCommonEpics, mostCommonLegendaries) = findFirstAndScndEpicAndLegendary(table: table)
        
        return String("It Seems that now \(mostCommonLegendaries) are more comon to find, such as \(mostCommonEpics)")
    }
    
    private func chooseTimeToSend() -> Int{
        
        let calendar = Calendar.current
        let hour = findHour(calendar: calendar)
        
        var hourToSend = 0
        
        switch hour {
        case 0:
            hourToSend = 15
        case 1:
            hourToSend = 21
        case 2:
            hourToSend = 24
        case 3:
            hourToSend = 9
        default:
            print("Error")
        }

        return hourToSend
        
    }
    
    private func findFirstAndScndEpicAndLegendary(table: [[Int]]) -> (String, String) {
        
        var rowLegend1 = 0
        var rowLegend2 = 0
        var rowEpic1 = 0
        var rowEpic2 = 0
        
        (rowLegend1, rowLegend2) = findFisrtAndSecondMax(in: table, column: 3)
        (rowEpic1, rowEpic2) = findFisrtAndSecondMax(in: table, column: 2)
        
        let legendaryString = createString(row1: rowLegend1, row2: rowLegend2, choice: 0)
        let epicString = createString(row1: rowEpic1, row2: rowEpic2, choice: 1)
        
        return (epicString, legendaryString)
        
    }
    
    private func findFisrtAndSecondMax(in matrix: [[Int]], column: Int) -> (Int, Int){
        
        guard !matrix.isEmpty, column >= 0, column < matrix[0].count else {
            return (0,0) // Matrice vuota o indice di colonna non valido
        }
        
        var maxIndex = -1
        var secondMaxIndex = -1
        var maxValue = Int.min
        var secondMaxValue = Int.min
        
        for i in 0...8{
            if matrix[i][column] > maxValue {
                secondMaxIndex = maxIndex
                maxIndex = i
                secondMaxValue = maxValue
                maxValue = matrix[i][column]
            } else if matrix[i][column] > secondMaxValue {
                secondMaxValue = matrix[i][column]
                secondMaxIndex = i
                
            }
                
        }
        
        return (maxIndex, secondMaxIndex)
        
    }
    
    
    private func createString(row1: Int, row2: Int, choice: Int) -> String{
        
        if choice != 0 || choice != 1 {
            print("Invalid string type choice: \(choice). Choose 0 or 1.")
            return ""
        }
        
        var first = String()
        var second = String()
        
        switch row1 + 1 {
        case 1:
            first = "Catfish"
        case 2:
            first = "Pufferfish"
        case 3:
            first = "Carp"
        case 4:
            first = "Broomfish"
        case 5:
            first = "Eel"
        case 6:
            first = "Morish Idle"
        case 7:
            first = "Surgeon Fish"
        case 8:
            first = "Octopus"
        case 9:
            first = "Tuna Fish"
        default:
            print("Error")
        }
        
        switch row2 + 1 {
        case 1:
            second = "Catfish"
        case 2:
            second = "Pufferfish"
        case 3:
            second = "Carp"
        case 4:
            second = "Broomfish"
        case 5:
            second = "Eel"
        case 6:
            second = "Morish Idle"
        case 7:
            second = "Surgeon Fish"
        case 8:
            second = "Octopus"
        case 9:
            second = "Tuna Fish"
        default:
            print("Error")
        }
        
        if choice == 0{
            return String("LEGENDARY \"\(first)\" and \"\(second)\"")
        } else if choice == 1{
            return String("EPIC \"\(first)\" and \"\(second)\"")
        } else {
            
            print("Invalid string type choice: \(choice). Choose 0 or 1.")
            return ""
        }
        
    }
    
    

    
    // La funione che crea la notifica e la schedula, richiede in input il titolo della notifica ed il corpo di questu'ultima
    // l'ora a cui deve essere mandata, i minuti e se deve essere mandata tutti i giorni alla ora decisa
    private func registerNotification(title: String, body: String, hour: Int, daily: Bool){
        
        // Si crea il corpo della notifica
        print("Creo la notifica")
        content = UNMutableNotificationContent()
        // Le assegnamo il titolo in input
        content.title = title
        // Le assegnamo il corpo in input
        content.body = body
        
        // Si decide l'ora a cui inviarla
        var dateComponents = DateComponents()
        // Ora
        dateComponents.hour = hour
        // Minuto
        dateComponents.minute = 0
        
        // Si crea il trigger di invio notifica utilizzando l'ora decisa (la variabile repeat viene impostata a true in modo
        // che tutti i giorni alla stessa ora venga reinviata la stessa notifica, sarebbe meglio metterla a false
        // dato che le notifiche sono diverse giorno per giorno)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: daily)
        
        // Si crea la richiesta da mandare al dispatch
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        // Si richiama il centro notifiche per l'invio della noticifa al centro notifiche dell'iphone in modo che
        // venga inviata all'ora decisa
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Richiesta inoltrata allo scheduler")
            }
        }
        
    }
    
    
    // La funzione che invia il pop-up per autorizzare le notifiche
    private func askForPermission(){
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Autorizzazione alle notifiche concessa")
            } else {
                print("Autorizzazione alle notifiche negata")
            }
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
        } else if hour >= 21 && hour <= 24 {
            hour = 2
        } else if hour > 0 && hour < 9 {
            hour = 3
        }
        
        return hour
    }
    
    
}
