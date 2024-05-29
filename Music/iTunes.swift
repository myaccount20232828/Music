import Foundation

func GetSongInfo(_ TrackID: String) -> MusicItem? {
    do {
        return try JSONDecoder().decode(JSONResult.self, from: try Data(contentsOf: "https://itunes.apple.com/lookup?id=\(TrackID)&entity=musicTrack".encodedUrl()!)).results.first
    } catch {
        print(error)
        return nil
    }
}

struct JSONResult: Decodable {
    var results: [MusicItem]
}

struct MusicItem: Decodable, Identifiable {
    var id: String {
        return UUID().uuidString
    }
    var trackName: String
    var artworkUrl100: String
    var artistName: String
    var releaseDate: String
    var collectionName: String
    var primaryGenreName: String
    var trackNumber: Int
    var trackExplicitness: String
}

extension String {
    func encodedUrl() -> URL? {
        guard let decodedString = self.removingPercentEncoding,
              let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters),
              let components = URLComponents(string: unicodeEncodedString),
              let percentEncodedUrl = components.url else {
            return nil
        }
        return percentEncodedUrl
    }
}

extension CharacterSet {
    static var urlAllowedCharacters: CharacterSet {
        var characters = CharacterSet(charactersIn: "#")
        characters.formUnion(.urlUserAllowed)
        characters.formUnion(.urlPasswordAllowed)
        characters.formUnion(.urlHostAllowed)
        characters.formUnion(.urlPathAllowed)
        characters.formUnion(.urlQueryAllowed)
        characters.formUnion(.urlFragmentAllowed)
        return characters
    }
}