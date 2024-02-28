import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ViewModel = ViewModel()
    @State private var scrollDirectionText: String = ""
    @State private var scrollAmountDirectionText: String = ""
    @State private var scrollAmountDirection: String = ""
    @State private var previousScrollAmount: Double = 0.0
    @State private var previousDelta: Double = 0.0
    @State private var AccelerationData: Double = 0.0
    @State private var MAxAccelerationData: Double = 0.0
    @State private var newDeltaX: Double = 0.0
    @State private var previousDeltaX: Double = 0.0
    @State private var previousDeltaZ: Double = 0.0
    @State private var newDeltaZ: Double = 0.0

    // Function to handle acceleration change
    
    
    var body: some View {
        VStack {
            Text("Scroll Speed:  \(viewModel.scrollspeed)")
            Text(scrollDirectionText)
                .padding()
            Text("Acceleration: \(viewModel.acceleation)")
            //Text("DELTAY: \(viewModel.deltaY)")
            
            Text(scrollAmountDirectionText)
        
            
            Text("AccelerationDataAvanti: \(MAxAccelerationData)")
            Text(scrollAmountDirection)
        

        }
        .onReceive(viewModel.$scrollspeed) { scrollAmount in
            if scrollAmount > previousScrollAmount{
                // Mostra "su" sulla vista ContentView dell'iPhone
                scrollDirectionText = "su"
            } else if scrollAmount < previousScrollAmount {
                // Mostra "giù" sulla vista ContentView dell'iPhone
                scrollDirectionText = "giu"
            } else {
                scrollDirectionText = "uguali"
            }
            previousScrollAmount = scrollAmount
        }
        
        .onReceive(viewModel.$deltaY) { newDelta in
            newDeltaX = viewModel.deltaX
            newDeltaZ = viewModel.deltaZ
            // Update text based on acceleration direction
            if newDelta < -0.70 {
                scrollAmountDirectionText = "Indietro"
            } else if newDelta > -0.30 {
                scrollAmountDirectionText = "Avanti"
            }
            if newDelta <= 0.40 && newDelta >= -0.10 {
                scrollAmountDirectionText = "Neutro"
            }
            
            if newDelta <= 1.70  && newDelta >= 0.70 && newDeltaX >= -0.80 && newDeltaX <= -0.45 {
                AccelerationData = viewModel.acceleation / 10
                MAxAccelerationData = 0
            }
            if MAxAccelerationData < AccelerationData{
                MAxAccelerationData = AccelerationData
            }
            if newDelta >= 0.800 {
                scrollAmountDirection = "Sinistra"
            }
            if newDelta < -0.010 && newDelta > -0.350 && newDeltaX > -0.040{
                scrollAmountDirection = "Destra"
            }
            
            previousDelta = newDelta
            previousDeltaX = newDeltaX
            previousDeltaZ = newDeltaZ
           }

        }
    }

