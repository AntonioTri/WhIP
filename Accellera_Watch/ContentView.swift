import SwiftUI
import CoreMotion

var socketConnection:  URLSessionWebSocketTask?

struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    @State var scrollAmount = 0.0
    @State var previousScrollAmount = 0.0
    @State var startTime: Date = Date()
    @State var speed: Double = 0.0
    @State var deltaZ: Double = 0.0
    @State var deltaX: Double = 0.0

    @State private var currentValue: Double = 0
    @State private var previousAcceleration: CMAcceleration?
    @State private var gyroData: CMGyroData?
    let motionManager = CMMotionManager()
    
    
    var body: some View {
        VStack {
            
            let tempScrollAmount = scrollAmount
            
            
            Text("")
                .focusable(true)
                .digitalCrownRotation($scrollAmount)
                .onChange(of: scrollAmount) { newValue in
                    scrollAmount = newValue
                    previousScrollAmount = tempScrollAmount
                    
                    // Calcolo e visualizzazione della velocità
                    let tempoTrascorso = Date().timeIntervalSince(startTime) // Calcola il tempo trascorso
                    speed = abs(scrollAmount - previousScrollAmount) / tempoTrascorso // Calcola la velocità
                    print("Velocità: \(speed)")
                    // Visualizza la velocità formattata
                    
                    
                    startTime = Date() // Reimposta l'ora di inizio per la prossima misurazione
                    
                }
            
            Text(String(format: "%.2f" , speed))
            
            
            
            //        Text("Scroll: \(scrollAmount)")
            if scrollAmount > previousScrollAmount{
                
                Text("su").onAppear(perform: {
                    sendData(key: "scrollSpeed", value: scrollAmount)
                })
                
            }else if scrollAmount < previousScrollAmount{
                
                Text("giù").onAppear(perform: {
                    sendData(key: "scrollSpeed", value: scrollAmount)
                })
                
            }else{
                
                Text("uguali").onAppear(perform: {
                    sendData(key: "scrollSpeed", value: scrollAmount)
                })
                
            }
            
            Text("Value: \(String(format: "%.2f", currentValue))")
                .padding()
            
            if let previousAcceleration = self.previousAcceleration {
                // Check Y value of acceleration and show appropriate text
                let deltaY = previousAcceleration.y
                
                if deltaY < -0.70 {
                    Text("INDIETRO")
                        .onAppear(perform: {
                            sendData(key: "deltaY", value: deltaY)
                        })
                    
                } else if deltaY > -0.50 {
                    Text("AVANTI")
                        .padding()
                        .onAppear(perform: {
                            sendData(key: "deltaY", value: deltaY)
                        })
                }
                if deltaY >= 0.800 {
                    Text("SINISTRA")
                        .padding()
                        .onAppear(perform: {
                            sendData(key: "deltaY", value: deltaY)
                        })
                }
                if deltaY > -0.600 && deltaY < -0.350{
                    Text("DESTRA")
                        .padding()
                        .onAppear(perform: {
                            sendData(key: "deltaX", value: deltaX)
                        })
                }
                if deltaY <= 0.200 && deltaY >= -0.100{
                    Text("CENTRO")
                        .padding()
                        .onAppear(perform: {
                            sendData(key: "deltaY", value: deltaY)
                        })
                }

            }
            
            Spacer()
            
        }
        
        .onAppear {
            // Start accelerometer and gyroscope updates
            self.startAccelerometerUpdates()
            self.startGyroscopeUpdates()
        }
        
    }
    
    func startAccelerometerUpdates() {
        motionManager.accelerometerUpdateInterval = 0.1
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let acceleration = data?.acceleration else { return }
                self.handleAcceleration(acceleration)
                // Print accelerometer data
                print("Acceleration - X: \(acceleration.x), Y: \(acceleration.y), Z: \(acceleration.z)")
                sendData(key: "deltaY", value: acceleration.y)
                sendData(key: "deltaX", value: acceleration.x)
                sendData(key: "deltaZ", value: acceleration.z)


                
            }
        }
    }
    
    func startGyroscopeUpdates() {
        motionManager.gyroUpdateInterval = 0.1
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                guard let gyroData = data else { return }
                self.gyroData = gyroData
            }
        }
    }
    // Aggiorna il metodo handleAcceleration(_:) nel ContentView
    func handleAcceleration(_ acceleration: CMAcceleration) {
        if let previousAcceleration = self.previousAcceleration {
            let deltaX = acceleration.x - previousAcceleration.x
            let deltaY = acceleration.y - previousAcceleration.y
            let deltaZ = acceleration.z - previousAcceleration.z
            let magnitude = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            
            let maxAcceleration: Double = 2.0 // Massima accelerazione per raggiungere 100
            let speed = min(magnitude / maxAcceleration * 1000, 1000) // Calcolo della velocità
            
            
            
            currentValue = speed
            
            sendData(key: "acceleration", value: currentValue)
            
            sendData(key: "scrollSpeed", value: scrollAmount)
            
           
        }
        self.previousAcceleration = acceleration
    }

    
    
    func sendData(key: String, value: Double){
        DispatchQueue.main.async {
            viewModel.sendMessage(key: key, value: value)
        }
    }
    
//    func sendAcceleration(key: String, value: CMAcceleration){
//        DispatchQueue.main.async {
//            viewModel.sendMessage(key: key, value: value)
//        }
//    }
    
}

#Preview {
    ContentView()
}
