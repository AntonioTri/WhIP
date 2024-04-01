import Foundation
import WatchKit
import SwiftUI



//This class represents the fish getting near the bait, it has a function wich uses the lower hapitic feedback class
//to make vibretions based on the fish nearness, the time is based on the "tempo" variable sent by the user at runtime
//It has function to invalidat the timer
class HapticFish {
    
    var contatore = 0
    var timer: Timer?
    private var vibrazione: HapticFeedback = HapticFeedback()
    
    func aboccaPesce(nearness: Double, hearthBitRate: Double){
            
        timer = Timer.scheduledTimer(withTimeInterval: nearness, repeats: true){ timer in
            print("Eseguo un battito con nearness \(nearness)")
  
            self.vibrazione.doVibration(timeInterval: hearthBitRate, chooseVibration: 3, nroVibrazioni: 2)
                
            
        }
    }
    
    func invalidateTimer(){
        self.timer?.invalidate()
    }
}


//This class represents the general Haptic feedback used in different ways trough all the other haptic classes.
//Therefore it's designed to be dynamic and comprehensive
//It also has a timer invalidate function
class HapticFeedback {

    var contatore = 0
    var contatoreLog = 0.0
    var timer: Timer?
    var timeInterval: TimeInterval = 0.1
    var choosedVibration = 0
    var nroVibrazioni = 0

    func doVibration(timeInterval: Double, chooseVibration: Int, nroVibrazioni: Int) {
        // Resetta il contatore quando viene avviato un nuovo set di vibrazioni
        contatore = 0

        // Crea il timer
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            if self.contatore < nroVibrazioni {
                self.makeVibration(chooseVibration: chooseVibration)
                self.contatore += 1
            } else {
                // Invalida il timer quando il numero desiderato di vibrazioni è stato raggiunto
                timer.invalidate()
            }
        }
    }
    
    func makeVibration(chooseVibration: Int) {
        
        let dispositivo = WKInterfaceDevice.current()

        switch chooseVibration {
            
            case 1: dispositivo.play(.directionDown)
            case 2: dispositivo.play(.failure)
            case 3: dispositivo.play(.click)
            case 4: dispositivo.play(.directionDown)
            case 5: dispositivo.play(.directionUp)
            case 6: dispositivo.play(.success)
            case 7: dispositivo.play(.start)
            case 8: dispositivo.play(.stop)

            default: print("Invalid vibration type")
            
        }
        
    }
    
    func invalidateTimer(){
        self.timer?.invalidate()
    }

}
