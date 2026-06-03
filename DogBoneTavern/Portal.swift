import Foundation
import SwiftUI

struct Portal: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let name: String
    let url: String
    let desc: String
    let gradient: [String]
}

enum PortalStore {
    static let defaultURL = "http://aaa.xixisillytavern.top:8000/"

    static let portals: [Portal] = [
        Portal(emoji: "✈️", name: "小狗阿里云1号狗洞", url: "http://aaa.xixisillytavern.top:8000/", desc: "小狗阿里云 8000 入口", gradient: ["#0B2545", "#D8C08D"]),
        Portal(emoji: "☁️", name: "小狗阿里云2号狗洞", url: "http://aaa.xixisillytavern.top:8443/", desc: "小狗阿里云 8443 入口", gradient: ["#1E3A5F", "#F2EFE8"]),
        Portal(emoji: "🏰", name: "小狗西西画家狗洞", url: "http://aaa.xn--pss82d789a4qsa.top:8888/", desc: "西西大画家 8888 入口", gradient: ["#6F7F8D", "#D8C08D"]),
        Portal(emoji: "🚇", name: "小狗隧道4号狗洞", url: "http://8.129.24.112:5705/", desc: "小狗隧道入口", gradient: ["#07111F", "#7E8EA1"])
    ]
}

extension String {
    var color: SwiftUI.Color {
        SwiftUI.Color(hex: self)
    }
}
