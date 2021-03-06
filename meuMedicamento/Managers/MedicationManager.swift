import Foundation
import CoreData

final class MedicationManager: ObservableObject {
    enum dateSection {
        case today
        case next
    }
    
    enum historicStatus {
        case onTime
        case late
        case missed
    }
    
    enum historicType {
        case all
        case all7Days
        case all30Days
        case medication7Days
        case medication30Days
    }
    
    private var notificationManager = NotificationManager()
    private var userSettings = UserSettings()
    let container: NSPersistentCloudKitContainer
    @Published var savedMedications: [Medication] = []
    @Published var savedHistoric: [Historic] = []
    
    init() {
        container = NSPersistentCloudKitContainer(name: "meuMedicamento")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        //let options = NSPersistentCloudKitContainerSchemaInitializationOptions()
        //try? container.initializeCloudKitSchema(options: options)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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
    
    func fetchHistories() {
        let request = NSFetchRequest<Historic>(entityName: "Historic")
        do {
            savedHistoric = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching \(error)")
        }
    }
    
    func deleteHistories() {
        let histories = savedHistoric
        for historic in histories {
            if historic.medication == nil {
                container.viewContext.delete(historic)
            }
        }
        _ = saveData()
    }
    
    
    func fetchHistoric (forStatus status: historicStatus, forType type: historicType, medication: Medication? = nil) -> Int {
        fetchHistories()
        let sevenDays = 604800.0 * -1
        let thirtyDays = 2628000.0  * -1
        switch status {
        case .onTime:
            switch type {
            case .all:
                let onTime = savedHistoric.filter({$0.medicationStatus == "Sem Atraso"}).count
                return onTime
            case .all7Days:
                let onTime = savedHistoric.filter({$0.medicationStatus == "Sem Atraso" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays}).count
                return onTime
            case .all30Days:
                let onTime = savedHistoric.filter({$0.medicationStatus == "Sem Atraso" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays}).count
                return onTime
            case .medication7Days:
                guard let medication = medication else {
                    return 0
                }
                let onTime = savedHistoric.filter({$0.medicationStatus == "Sem Atraso" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays && $0.medication == medication}).count
                return onTime
            case .medication30Days:
                guard let medication = medication else {
                    return 0
                }
                let onTime = savedHistoric.filter({$0.medicationStatus == "Sem Atraso" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays && $0.medication == medication}).count
                return onTime
            }
        case .late:
            switch type {
            case .all:
                let late = savedHistoric.filter({$0.medicationStatus == "Atrasado"}).count
                return late
            case .all7Days:
                let late = savedHistoric.filter({$0.medicationStatus == "Atrasado" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays}).count
                return late
            case .all30Days:
                let late = savedHistoric.filter({$0.medicationStatus == "Atrasado" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays}).count
                return late
            case .medication7Days:
                guard let medication = medication else {
                    return 0
                }
                let late = savedHistoric.filter({$0.medicationStatus == "Atrasado" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays && $0.medication == medication}).count
                return late
            case .medication30Days:
                guard let medication = medication else {
                    return 0
                }
                let late = savedHistoric.filter({$0.medicationStatus == "Atrasado" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays && $0.medication == medication}).count
                return late
            }
        case .missed:
            switch type {
            case .all:
                let missed = savedHistoric.filter({$0.medicationStatus == "N??o tomou"}).count
                return missed
            case .all7Days:
                let missed = savedHistoric.filter({$0.medicationStatus == "N??o tomou" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays}).count
                return missed
            case .all30Days:
                let missed = savedHistoric.filter({$0.medicationStatus == "N??o tomou" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays}).count
                return missed
            case .medication7Days:
                guard let medication = medication else {
                    return 0
                }
                let missed = savedHistoric.filter({$0.medicationStatus == "N??o tomou" && $0.dates?.timeIntervalSinceNow ?? 0 >= sevenDays && $0.medication == medication}).count
                return missed
            case .medication30Days:
                guard let medication = medication else {
                    return 0
                }
                let missed = savedHistoric.filter({$0.medicationStatus == "N??o tomou" && $0.dates?.timeIntervalSinceNow ?? 0 >= thirtyDays && $0.medication == medication}).count
                return missed
            }
        }
    }
    
    func fetchHistoric(forMedication medication: Medication) -> [Historic] {
        var aux = Array(medication.dates as? Set<Historic> ?? [])
        aux = aux.sorted(by: { $0.dates ?? .distantPast > $1.dates ?? .distantPast })
        return aux
    }
    
    func checkMedicationDate(forMedication medication: Medication) -> dateSection {
        let calendar = Calendar.current
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight) else {return .next}
        if medication.date ?? Date() < tomorrow {
            return .today
        } else {
            return .next
        }
    }
    
    func calculateLateMedications() -> Int {
        let lateMedications = savedMedications.filter({$0.date?.timeIntervalSinceNow ?? Date().timeIntervalSinceNow < 0})
        return lateMedications.count
    }
    
    func saveData() -> medicationResult {
        var sucess: medicationResult = .sucess;
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                fetchMedications()
            } catch let error {
                print("Error saving \(error)")
                sucess = .viewContextError
            }
        }
        return sucess
    }
    
    func addMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String) -> medicationResult {
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
        
        var situation: medicationResult = .sucess
        situation = saveData()
        if situation == .sucess {
            guard let timeInterval = newMedication.date?.timeIntervalSinceNow else {
                situation = .notificationTimeIntervalError
                return situation
            }
            guard let identifier = newMedication.id else {
                situation = .notificationTimeIntervalError
                return situation
            }
            if timeInterval > 0 {
                notificationManager.deleteLocalNotifications(identifiers: [identifier])
                let title = NSLocalizedString("Take", comment: "") + " \(newMedication.name ?? "Medication")"
                notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: title, timeInterval: timeInterval) { error in
                    if error == nil {
                        print("Notifica????o criada com id: \(identifier)")
                        situation = .sucess
                    }
                }
            }
        }
        return situation
    }
    
    func editMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, medication: Medication) -> medicationResult {
        
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
        
        var situation: medicationResult = .sucess
        situation = saveData()
        
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {
            situation = .notificationTimeIntervalError
            return situation
        }
        let identifierRepeat = (medication.id ?? UUID().uuidString) + "-Repiting"
        guard let identifier = medication.id else {
            situation = .notificationTimeIntervalError
            return situation
        }
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
            let title = NSLocalizedString("Take", comment: "") + " \(medication.name ?? "Medication")"
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: title, timeInterval: timeInterval) { error in
                if error == nil {
                    print("Notifica????o criada com id: \(identifier)")
                    situation = .sucess
                }
            }
        }
        return situation
    }
    
    func deleteMedication(medication: Medication) {
        guard let identifier = medication.id else {return}
        let identifierRepeat = identifier + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
        container.viewContext.delete(medication)
        let sucess = saveData()
        print(sucess)
    }
    
    func updateRemainingQuantity(medication: Medication) -> medicationResult {
        var situation: medicationResult = .sucess
        if medication.remainingQuantity > 1 {
        situation = scheduleQuantityNotification(forMedication: medication)
        medication.remainingQuantity -= 1
        let historic = Historic(context: container.viewContext)
        historic.dates = Date()
        historic.medication = medication
        if !(medication.repeatPeriod == "Nunca") {
            rescheduleNotification(forMedication: medication, forHistoric: historic)
        }
        situation = saveData()
    } else {
        deleteMedication(medication: medication)
    }
    return situation
}

func scheduleQuantityNotification(forMedication medication: Medication) -> medicationResult {
    var situation: medicationResult = .sucess
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
                let title = NSLocalizedString("Buy", comment: "") + " \(medication.name ?? "Medication")"
                notificationManager.deleteLocalNotifications(identifiers: [identifier])
                notificationManager.createLocalNotificationByDateMatching(identifier: identifier, title: title, hour: hour ?? 12, minute: minute ?? 00) { error in
                    if error == nil {
                        situation = .sucess
                        print("Notifica????o criada com id: \(identifier)")
                    } else {
                        situation = .notificationDateMatchingError
                    }
                }
            }
        }
    }
    return situation
}

func nextDates(forMedication medication: Medication) -> [Date] {
    guard let date1 = medication.date else {
        return []
    }
    var dates = [date1]
    if medication.repeatPeriod != "Nunca" {
        let date2 = Date(timeInterval: medication.repeatSeconds, since: date1)
        let date3 = Date(timeInterval: medication.repeatSeconds, since: date2)
        let date4 = Date(timeInterval: medication.repeatSeconds, since: date3)
        dates.append(date2)
        dates.append(date3)
        dates.append(date4)
    }
    return dates
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
        let title = NSLocalizedString("Take", comment: "") + " \(medication.name ?? "Medication")"
        notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: title, timeInterval: timeInterval) { error in
            if error == nil {}
        }
    } else {
        rescheduleNotification(forMedication: medication, forHistoric: historic)
        historic.medicationStatus = "N??o tomou"
    }
}

func reloadNotifications() {
    notificationManager.removeLocalNotifications()
    for medication in savedMedications {
        guard let date = medication.date else {return}
        if date.timeIntervalSinceNow > 0.0 {
            let timeInterval = date.timeIntervalSinceNow
            guard let identifier = medication.id else {return}
            let title = NSLocalizedString("Take", comment: "") + " \(medication.name ?? "Medication")"
            print("Reagendando notifica????o para \(medication.name ?? "Medicamento")")
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: title, timeInterval: timeInterval) { error in
                if error == nil {}
            }
        }
        _ = scheduleQuantityNotification(forMedication: medication)
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
        seconds = 3600
    case "2 horas":
        seconds = 3600 * 2
    case "4 horas":
        seconds = 3600 * 4
    case "6 horas":
        seconds = 3600 * 6
    case "8 horas":
        seconds = 3600 * 8
    case "12 horas":
        seconds = 3600 * 12
    case "1 dia":
        seconds = 86400
    case "2 dias":
        seconds = 86400 * 2
    case "5 dias":
        seconds = 86400 * 5
    case "1 semana":
        seconds = 604800
    case "2 semanas":
        seconds = 604800 * 2
    case "1 m??s":
        seconds = 2628000
    case "3 meses":
        seconds = 2628000 * 3
    case "6 meses":
        seconds = 2628000 * 6
    default:
        break
    }
    return seconds
}
}
