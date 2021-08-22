import Foundation
import CoreData

final class MedicationManager: ObservableObject {
    private var notificationManager = NotificationManager()
    private var userSettings = UserSettings()
    
    func saveContext(viewContext: NSManagedObjectContext) -> Bool {
        var sucess = true;
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            print(error)
            sucess = false
            //fatalError("Failed to save Medication: \(error)")
        }
        return sucess
    }
    
    
    func addMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, viewContext: NSManagedObjectContext) -> Bool {
        let newMedication = Medication(context: viewContext)
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
        sucess = saveContext(viewContext: viewContext)
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
    
    func editMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, viewContext: NSManagedObjectContext, medication: Medication) -> Bool {
        
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
        sucess = saveContext(viewContext: viewContext)
        
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
    
    func deleteMedication(medication: Medication, viewContext: NSManagedObjectContext) {
        guard let identifier = medication.id else {return}
        let identifierRepeat = identifier + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
        viewContext.delete(medication)
        let sucess = saveContext(viewContext: viewContext)
        print(sucess)
    }
    
    func updateRemainingQuantity(medication: Medication, viewContext: NSManagedObjectContext) -> Bool {
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
            
            let historic = Historic(context: viewContext)
            historic.dates = Date()
            historic.medication = medication
            if !(medication.repeatPeriod == "Nunca") {
                rescheduleNotification(forMedication: medication, forHistoric: historic)
            }
            success = saveContext(viewContext: viewContext)
            if historic.medicationStatus == "Não tomou" {
                success = false
            }
        } else {
            deleteMedication(medication: medication, viewContext: viewContext)
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
    
    func refreshRemainingQuantity(medication: Medication, viewContext: NSManagedObjectContext) {
        medication.remainingQuantity += medication.boxQuantity
        let sucess = saveContext(viewContext: viewContext)
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
            seconds = 3600.0
        case "2 horas":
            seconds = 7200.0
        case "4 horas":
            seconds = 14400.0
        case "6 horas":
            seconds = 21600.0
        case "8 horas":
            seconds = 28800.0
        case "12 horas":
            seconds = 43200.0
        case "1 dia":
            seconds = 86400.0
        case "2 dias":
            seconds = 172800.0
        case "5 dias":
            seconds = 432000.0
        case "1 semana":
            seconds = 604800.0
        case "2 semanas":
            seconds = 1209600.0
        case "1 mês":
            seconds = 2419200.0
        case "3 meses":
            seconds = 72576000.0
        case "6 meses":
            seconds = 145152000.0
        default:
            break
        }
        return seconds
    }
}


