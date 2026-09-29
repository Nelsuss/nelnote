import Foundation

/// 기록, 배경 사진, 화면 설정을 앱 안 파일로 저장한다 (안드로이드의 Store 와 같은 역할)
final class Store {
    private let dir: URL
    private var prefs: [String: String] = [:]

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("NelNote", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        if let data = try? Data(contentsOf: dir.appendingPathComponent("prefs.json")),
           let saved = (try? JSONSerialization.jsonObject(with: data)) as? [String: String] {
            prefs = saved
        }
    }

    func readText(_ name: String) -> String {
        return (try? String(contentsOf: dir.appendingPathComponent(name), encoding: .utf8)) ?? ""
    }

    /// 빈 문자열이면 파일을 지운다. 그 외에는 통째로 안전하게 덮어쓴다.
    func writeText(_ name: String, _ text: String) {
        let url = dir.appendingPathComponent(name)
        if text.isEmpty {
            try? FileManager.default.removeItem(at: url)
            return
        }
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    func readPrefs() -> [String: String] {
        return prefs
    }

    func setPref(_ key: String, _ value: String) {
        prefs[key] = value
        if let data = try? JSONSerialization.data(withJSONObject: prefs) {
            try? data.write(to: dir.appendingPathComponent("prefs.json"), options: .atomic)
        }
    }
}
