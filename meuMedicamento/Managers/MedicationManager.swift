import Foundation
import CoreData
import Time

final class MedicationManager: ObservableObject {
    private var notificationManager = NotificationManager()
    private var userSettings = UserSettings()
    let container: NSPersistentContainer
    @Published var savedMedications: [Medication] = []
    
    init() {
        container = NSPersistentContainer(name: "meuMedicamento")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        fetchMedications()
    }
    
    func fetchMedications() {
        let request = NSFetchRequest<Medication>(entityName: "Medication")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
            savedMedications = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching \(error)")
        }
    }
    
    
    func saveData() -> Bool {
        var sucess = true;
        do {
            try container.viewContext.save()
            fetchMedications()
        } catch let error {
            print("Error saving \(error)")
            sucess = false
        }
        return sucess
    }
    
    
    func addMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String) -> Bool {
        let newMedication = Medication(context: container.viewContext)
        newMedication.name = name
        newMedication.remainingQuantity = remainingQuantity
        newMedication.boxQuantity = boxQuantity
        newMedication.id = UUID().uuidString
        newMedication.date = date
        if repeatPeriod == "" {
            newMedication.repeatPeriod = "Nunca"
        } else {
            newMedication.repeatPeriod = repeatPeriod
        }
        newMedication.notes = notes
        newMedication.isSelected = false
        newMedication.repeatSeconds = convertToSeconds(newMedication.repeatPeriod ?? "")
        newMedication.notificationType = notificationType
        
        var sucess = true
        sucess = saveData()
        if sucess {
            guard let timeInterval = newMedication.date?.timeIntervalSinceNow else {
                sucess = false
                return sucess
            }
            guard let identifier = newMedication.id else {
                sucess = false
                return sucess
            }
            if timeInterval > 0 {
                notificationManager.deleteLocalNotifications(identifiers: [identifier])
                notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(newMedication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                    if error == nil {
                        print("Notificação criada com id: \(identifier)")
                        sucess = true
                    }
                }
            }
        }
        return sucess
    }
    
    func editMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, medication: Medication) -> Bool {
        
        medication.name = name
        medication.remainingQuantity = remainingQuantity
        medication.boxQuantity = boxQuantity
        medication.date = date
        if repeatPeriod == "" {
            medication.repeatPeriod = "Nunca"
        } else {
            medication.repeatPeriod = repeatPeriod
        }
        medication.notes = notes
        medication.isSelected = false
        medication.repeatSeconds = convertToSeconds(medication.repeatPeriod ?? "")
        medication.notificationType = notificationType
        
        var sucess = true
        sucess = saveData()
        
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {
            sucess = false
            return sucess
        }
        let identifierRepeat = (medication.id ?? UUID().uuidString) + "-Repiting"
        guard let identifier = medication.id else {
            sucess = false
            return sucess
        }
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(medication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {
                    print("Notificação criada com id: \(identifier)")
                    sucess = true
                }
            }
        }
        return sucess
    }
    
    func deleteMedication(medication: Medication) {
        guard let identifier = medication.id else {return}
        let identifierRepeat = identifier + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
        container.viewContext.delete(medication)
        let sucess = saveData()
        print(sucess)
    }
    
    func updateRemainingQuantity(medication: Medication) -> Bool {
        var success = true
        if medication.remainingQuantity > 1 {
            if Double(medication.remainingQuantity) <= Double(medication.boxQuantity) * (userSettings.limitMedication/100.0) {
                if userSettings.limitNotification {
                    print("USERDEFAULTS-----------")
                    print(userSettings.limitNotification)
                    print(userSettings.limitMedication)
                    print("---------------------------")
                    let identifier = (medication.id ?? UUID().uuidString) + "-Repiting"
                    let dateMatching = Calendar.current.dateComponents([.hour,.minute], from: userSettings.limitDate)
                    let hour = dateMatching.hour
                    let minute = dateMatching.minute
                    notificationManager.deleteLocalNotifications(identifiers: [identifier])
                    notificationManager.createLocalNotificationByDateMatching(identifier: identifier, title: "Comprar \(medication.name ?? "Medicamento")", hour: hour ?? 12, minute: minute ?? 00) { error in
                        if error == nil {
                            print("Notificação criada com id: \(identifier)")
                        }
                    }
                }
            }
            medication.remainingQuantity -= 1
            
            let historic = Historic(context: container.viewContext)
            historic.dates = Date()
            historic.medication = medication
            if !(medication.repeatPeriod == "Nunca") {
                rescheduleNotification(forMedication: medication, forHistoric: historic)
            }
            success = saveData()
        } else {
            deleteMedication(medication: medication)
        }
        return success
    }
    
    func rescheduleNotification(forMedication medication: Medication, forHistoric historic: Historic) {
        medicationStatus(forMedication: medication, forHistoric: historic)
        if medication.notificationType == "Regularmente" {
            medication.date = Date(timeInterval: medication.repeatSeconds, since: medication.date ?? Date())
        } else {
            medication.date = Date(timeIntervalSinceNow: medication.repeatSeconds)
        }
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {return}
        guard let identifier = medication.id else {return}
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(medication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {}
            }
        } else {
            rescheduleNotification(forMedication: medication, forHistoric: historic)
            historic.medicationStatus = "Não tomou"
        }
    }
    
    func medicationStatus(forMedication medication: Medication, forHistoric historic: Historic) {
        var timeIntervalComparation = 0.0
        if let timeIntervalDate = medication.date?.timeIntervalSince(historic.dates ?? Date()) {
            timeIntervalComparation = timeIntervalDate
        }
        if timeIntervalComparation < -900.0 {
            historic.medicationStatus = "Atrasado"
        } else {
            historic.medicationStatus = "Sem Atraso"
        }
    }
    
    func refreshRemainingQuantity(medication: Medication) {
        medication.remainingQuantity += medication.boxQuantity
        let sucess = saveData()
        print(sucess)
        guard let id = medication.id else {return}
        let identifier = id + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier])
    }
    
    func convertToSeconds(_ time: String) -> Double {
        var seconds = 3.0
        switch time {
        case "Nunca":
            seconds = 0.0
        case "1 hora":
            seconds = 1.hours.inSeconds.value
        case "2 horas":
            seconds = 2.hours.inSeconds.value
        case "4 horas":
            seconds = 4.hours.inSeconds.value
        case "6 horas":
            seconds = 6.hours.inSeconds.value
        case "8 horas":
            seconds = 8.hours.inSeconds.value
        case "12 horas":
            seconds = 12.hours.inSeconds.value
        case "1 dia":
            seconds = 1.days.inSeconds.value
        case "2 dias":
            seconds = 2.days.inSeconds.value
        case "5 dias":
            seconds = 5.days.inSeconds.value
        case "1 semana":
            seconds = 7.days.inSeconds.value
        case "2 semanas":
            seconds = 14.days.inSeconds.value
        case "1 mês":
            seconds = 30.days.inSeconds.value
        case "3 meses":
            seconds = 90.days.inSeconds.value
        case "6 meses":
            seconds = 180.days.inSeconds.value
        default:
            break
        }
        return seconds
    }
}


public extension NSManagedObject {

    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }

}
