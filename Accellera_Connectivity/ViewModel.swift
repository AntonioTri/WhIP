//
//  ViewModel.swift
//  AccelerometerData
//
//  Created by MauroNardi on 21/02/24.
//
//
//  ViewModel.swift
//  AccelerometerData
//
//  Created by Antonio Tridente on 21/02/24.
//
//
//  ViewModel.swift
//  SignalKApp
//
//  Created by Antonio Tridente on 12/02/24.
//

import Foundation
import Combine


// MARK: - Value
struct Value: Codable {
    let path: String
    let value: Double
}

class ViewModel: ObservableObject{
    
    private var connectivityProvider: ConnectivityProvider
    
    @Published var scrollspeed: Double = 0.0
    @Published var acceleation: Double = 0.0
    @Published var deltaY: Double = 0.0
    @Published var deltaX: Double = 0.0
    @Published var deltaZ: Double = 0.0

    var valueModel: PassthroughSubject<Value, Never> = PassthroughSubject<Value, Never>()
    var requests: AnyCancellable?
    
    init (){
        self.connectivityProvider = ConnectivityProvider(modelUpdates: valueModel)
        self.connectivityProvider.connect()
        requests = valueModel.sink(receiveValue: {
            value in
            switch value.path{
            case "scrollSpeed":
                self.scrollspeed = value.value
            case "acceleration":
                self.acceleation = value.value
            case "deltaY":
                self.deltaY = value.value
            case "deltaX":
                self.deltaX = value.value
            case "deltaZ":
                self.deltaZ = value.value
            default:
                print("error")
            }
        })
    }
    
    func sendMessage(key: String, value: Any){
        let message = ["path": key, "value": value]
        connectivityProvider.send(message: message)
    }
    // Aggiungi questo metodo nella classe ViewModel
    
  



    
    
}
