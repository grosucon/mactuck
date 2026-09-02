import os

enum Log {
    static let app = Logger(subsystem: "com.grosucon.mactuck", category: "app")
    static let cover = Logger(subsystem: "com.grosucon.mactuck", category: "cover")
    static let menu = Logger(subsystem: "com.grosucon.mactuck", category: "menu")
}
