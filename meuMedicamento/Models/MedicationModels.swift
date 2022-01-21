import Foundation

struct RepeatPeriod{
    static let periods = [
        "Nunca",
        "1 hora",
        "2 horas",
        "4 horas",
        "6 horas",
        "8 horas",
        "12 horas",
        "1 dia",
        "2 dias",
        "5 dias",
        "1 semana",
        "2 semanas",
        "1 mês",
        "3 meses",
        "6 meses"
    ]
}

struct NotificationType{
    static let type = [
    "Após Conclusão",
    "Regularmente"
    ]
}

enum medicationResult {
    case sucess
    case notificationTimeIntervalError
    case notificationDateMatchingError
    case viewContextError
}

enum Field {
    case name
    case remainingQuantity
    case boxQuantity
}

let longDateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateStyle = .full
         formatter.timeStyle = .short
         //formatter.locale = Locale(identifier: "pt-BR")
         return formatter
     }()

let shortDateFormatter: DateFormatter = {
         let formatter = DateFormatter()
        formatter.dateStyle = .short
         formatter.timeStyle = .short
         //formatter.locale = Locale(identifier: "pt-BR")
         return formatter
     }()
