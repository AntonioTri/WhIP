import Foundation
import CoreMotion

class ManageData {
    
    let viewModel = ViewModel()
    var previousScrollAmount: Double = 0.0
    var previousAcceleration: CMAcceleration?
    
    func processAccelerationData(deltaY: Double) {
        if deltaY < -0.50 {
            // Mostra "INDIETRO" sulla vista ContentView dell'iPhone
            print("INDIETRO")
        } else if deltaY > -0.30 {
            // Mostra "AVANTI" sulla vista ContentView dell'iPhone
            print("AVANTI")
        }
    }
    
    func processScrollData(scrollAmount: Double) {
        if scrollAmount > previousScrollAmount {
            // Mostra "su" sulla vista ContentView dell'iPhone
            print("su")
        } else if scrollAmount < previousScrollAmount {
            // Mostra "giù" sulla vista ContentView dell'iPhone
            print("giù")
        } else {
            // Puoi decidere cosa fare se scrollAmount è uguale a previousScrollAmount
        }
        previousScrollAmount = scrollAmount
    }
    
    func processAcceleration(acceleration: CMAcceleration) {
        guard let previousAcceleration = self.previousAcceleration else {
            self.previousAcceleration = acceleration
            return
        }
        self.previousAcceleration = acceleration
    }
}
