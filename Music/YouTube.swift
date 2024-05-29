import Foundation
import SwiftUI

func GetYouTubeVideoURL(_ VideoID: String, _ AudioOnly: Bool = false) -> URL? {
    do {
        let StreamingData = try JSONDecoder().decode(YouTubeData.self, from: MakeURLRequest("https://www.youtube.com/youtubei/v1/player?key=AIzaSyCIk6XLkc299fofTTz4adOxe2sMQL7oVA8", ["Content-Type": "application/json"], Data("{\"context\":{\"client\":{\"clientVersion\":\"17.33.2\",\"clientName\":\"ANDROID\"}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"\(VideoID)\",\"params\":\"CgIQBg==\"}".utf8))).streamingData
        if AudioOnly {
            if let Streams = StreamingData.adaptiveFormats, let StreamURL = Streams.first(where: {$0.mimeType.hasPrefix("audio/mp4")})?.url {
                return URL(string: StreamURL)
            }
        } else {
            if let Streams = StreamingData.formats, let StreamURL = Streams.first?.url {
                return URL(string: StreamURL)
            }
        }
        return nil
    } catch {
        print(error)
        return nil
    }
}

struct YouTubeData: Hashable, Decodable {
    var streamingData: YouTubeStreamingData
}

struct YouTubeStreamingData: Hashable, Decodable {
    var formats: [YouTubeFormats]?
    var adaptiveFormats: [YouTubeFormats]?
}

struct YouTubeFormats: Hashable, Decodable {
    var url: String?
    var mimeType: String
}

func MakeURLRequest(_ URLString: String, _ Headers: [String: String], _ PostData: Data? = nil) -> Data {
    var ResponseData = Data()
    var request = URLRequest(url: URL(string: URLString)!)
    if let PostData = PostData {
        request.httpBody = PostData
    }
    request.httpMethod = PostData == nil ? "GET" : "POST"
    request.allHTTPHeaderFields = Headers
    let semaphore = DispatchSemaphore(value: 0)
    let task = URLSession.shared.dataTask(with: request) { data, _, _ in
        defer {
            semaphore.signal()
        }
        if let responseData = data {
            ResponseData = responseData
        }
    }
    task.resume()
    semaphore.wait()
    return ResponseData
}