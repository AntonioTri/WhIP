import HealthKit

class ForegroundLoop {
    private let healthStore = HKHealthStore()
    
    init() {
        // Richiedi l'autorizzazione per accedere ai dati di HealthKit
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        // Definisci i tipi di dati a cui desideri accedere (ad esempio, dati di allenamento)
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        
        // Richiedi l'autorizzazione all'utente
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                // L'autorizzazione è stata concessa, avvia la sessione di allenamento
                self.startWorkoutSession()
            } else {
                // L'utente ha negato l'autorizzazione o si è verificato un errore
                print("Errore nell'autorizzazione a HealthKit: \(error?.localizedDescription ?? "Errore sconosciuto")")
            }
        }
    }
    
    private func startWorkoutSession() {
        // Crea una configurazione per la sessione di allenamento
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking // Imposta il tipo di attività (es. corsa)
        workoutConfiguration.locationType = .unknown // Imposta il tipo di posizione (es. esterno)
        
        // Crea la sessione di allenamento
        do {
            let workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            
            // Avvia la sessione di allenamento
            workoutSession.startActivity(with: Date())
        } catch {
            print("Errore durante la creazione della sessione di allenamento: \(error.localizedDescription)")
        }
    }
}
