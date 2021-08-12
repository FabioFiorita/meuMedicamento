import Foundation

let tabs = [
    Page(image: "Logo", title: "Organize seus medicamentos", text: "meuMedicamento tem como objetivo ajudar pessoas a controlar seus medicamentos, por meio dele o usuário consegue receber notificações, alertas se o medicamento estiver acabando e é preciso comprar mais e visualizar um mapa com todas as farmácias próximas da sua localização."),
    Page(image: "pill", title: "Controle seus medicamentos", text: "Adicione seus medicamentos utilizando o botão + no canto superior esquerdo do app\nTenha controle de quantidade de medicamentos restantes, horários, histórico de uso e muito mais."),
    Page(image: "map", title: "Descubra as farmácias próximas", text: "Utilize o mapa que está dentro do app para achar todas as farmácias próxima da sua localização"),
    Page(image: "gear", title: "Personalize seu uso", text: "Configure funções do app ou contate o suporte.")
]

struct Page {
    let image: String
    let title: String
    let text: String
}
