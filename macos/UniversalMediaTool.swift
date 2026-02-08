import Foundation
import AppKit

class UniversalMediaProvider {
    
    init() {
    }
    
    func getActiveMediaInfo() -> [String: Any] {
        if let cliResult = getNowPlayingFromCLI() {
            return cliResult
        }
        
        return [
            "status": "nothing_playing",
            "is_playing": false,
            "error": "No media playing"
        ]
    }
    
    // Get media info using nowplaying-cli
    private func getNowPlayingFromCLI() -> [String: Any]? {
        guard let allInfo = runCLICommand(args: ["get", "title", "artist", "album", "duration", "elapsedTime", "playbackRate"]),
              !allInfo.isEmpty else {
            return nil
        }
        
        // Parse the multi-line output
        let lines = allInfo.components(separatedBy: .newlines)
        guard lines.count >= 6 else {
            return getNowPlayingIndividually()
        }
        
        let title = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let album = lines[2].trimmingCharacters(in: .whitespacesAndNewlines)
        let durationStr = lines[3].trimmingCharacters(in: .whitespacesAndNewlines)
        let elapsedTimeStr = lines[4].trimmingCharacters(in: .whitespacesAndNewlines)
        let playbackRateStr = lines[5].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty && !artist.isEmpty else {
            return nil
        }
        
        let duration = Double(durationStr) ?? 0
        let elapsed = Double(elapsedTimeStr) ?? 0
        let playbackRate = Double(playbackRateStr) ?? 0
        
        let isPlaying = playbackRate > 0
        let progress = duration > 0 ? min(100, Int((elapsed / duration) * 100)) : 0
        
        let source = detectMediaSource(title: title, artist: artist)
        
        return [
            "title": title,
            "artist": artist,
            "album": album,
            "duration": Int(duration * 1000), // Convert to milliseconds
            "elapsed": elapsed,
            "progress": progress,
            "is_playing": isPlaying,
            "playback_rate": playbackRate,
            "source": source,
            "status": isPlaying ? "playing" : "paused"
        ]
    }
    
    private func getNowPlayingIndividually() -> [String: Any]? {
        guard let title = runCLICommand(args: ["get", "title"]),
              let artist = runCLICommand(args: ["get", "artist"]),
              !title.isEmpty, !artist.isEmpty else {
            return nil
        }
        
        let album = runCLICommand(args: ["get", "album"]) ?? ""
        let durationStr = runCLICommand(args: ["get", "duration"]) ?? "0"
        let elapsedTimeStr = runCLICommand(args: ["get", "elapsedTime"]) ?? "0"
        let playbackRateStr = runCLICommand(args: ["get", "playbackRate"]) ?? "0"
        
        let duration = Double(durationStr) ?? 0
        let elapsed = Double(elapsedTimeStr) ?? 0
        let playbackRate = Double(playbackRateStr) ?? 0
        
        let isPlaying = playbackRate > 0
        let progress = duration > 0 ? min(100, Int((elapsed / duration) * 100)) : 0
        
        let source = detectMediaSource(title: title, artist: artist)
        
        return [
            "title": title,
            "artist": artist,
            "album": album,
            "duration": Int(duration * 1000), // Convert to milliseconds
            "elapsed": elapsed,
            "progress": progress,
            "is_playing": isPlaying,
            "playback_rate": playbackRate,
            "source": source,
            "status": isPlaying ? "playing" : "paused"
        ]
    }
    
    private func runCLICommand(args: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/nowplaying-cli")
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if task.isRunning {
                task.terminate()
            }
        }
        
        do {
            try task.run()
            task.waitUntilExit()
            timeoutTimer.invalidate()
            
            // Only proceed if task completed successfully
            guard task.terminationStatus == 0 else {
                return nil
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return output?.isEmpty == false ? output : nil
            
        } catch {
            timeoutTimer.invalidate()
            return nil
        }
    }
    
    // Detect media source
    private func detectMediaSource(title: String?, artist: String?) -> String {
        guard let title = title, !title.isEmpty, title != "Unknown" else {
            return "Unknown"
        }
        
        let runningApps = NSWorkspace.shared.runningApplications
        let mediaApps = [
            ("com.spotify.client", "Spotify"),
            ("com.apple.Music", "Music"),
            ("com.colliderli.iina", "IINA"),
            ("org.videolan.vlc", "VLC"),
            ("com.apple.QuickTimePlayerX", "QuickTime"),
            ("com.google.Chrome", "Chrome"),
            ("com.apple.Safari", "Safari"),
            ("org.mozilla.firefox", "Firefox"),
            ("com.microsoft.edgemac", "Edge")
        ]
        
        for (bundleId, appName) in mediaApps {
            if runningApps.contains(where: { $0.bundleIdentifier == bundleId }) {
                return appName
            }
        }
        if title.contains("YouTube") || artist?.contains("YouTube") == true {
            return "YouTube"
        } else if title.contains("Spotify") || artist?.contains("Spotify") == true {
            return "Spotify"
        } else if title.contains("Apple Music") || artist?.contains("Apple Music") == true {
            return "Apple Music"
        } else if artist?.contains("Safari") == true || artist?.contains("Chrome") == true {
            return "Browser"
        }
        
        return "System"
    }

}

func printJSON(_ data: [String: Any]) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    } catch {
        print("{\"error\": \"JSON serialization failed\"}")
    }
}

let provider = UniversalMediaProvider()
let mediaInfo = provider.getActiveMediaInfo()
printJSON(mediaInfo)