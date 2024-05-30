import SwiftUI
import AVKit

func MakeSong(_ Song: MusicItem, _ VideoID: String, _ StartTime: Double) -> String {
    guard let VideoURL = GetYouTubeVideoURL(VideoID, true) else {
        return "Failed to get video url!"
    }
    return EncodeAudio(MakeMetaData(Song.trackName, Song.artistName, Song.collectionName, GetYearFromDate(Song.releaseDate), Song.artworkUrl100.replacingOccurrences(of: "100x100bb.jpg", with: "1000x1000bb.png"), Song.primaryGenreName, Song.trackNumber), VideoURL.absoluteString, StartTime)
}

func MakeMetaData(_ Title: String, _ Artist: String, _ Album: String, _ Year: String, _ Artwork: String, _ Genre: String, _ TrackNumber: Int) -> [AVMetadataItem] {
    let TitleItem = AVMutableMetadataItem()
    TitleItem.identifier = .commonIdentifierTitle
    TitleItem.value = Title as (NSCopying & NSObjectProtocol)?
    let ArtworkItem = AVMutableMetadataItem()
    ArtworkItem.identifier = .commonIdentifierArtwork
    ArtworkItem.value = Data.Download(Artwork) as (any NSCopying & NSObjectProtocol)?
    let ArtistItem = AVMutableMetadataItem()
    ArtistItem.identifier = .commonIdentifierArtist
    ArtistItem.value = Artist as (any NSCopying & NSObjectProtocol)?
    let YearItem = AVMutableMetadataItem()
    YearItem.identifier = .identifier3GPUserDataRecordingYear
    YearItem.value = Year as (any NSCopying & NSObjectProtocol)?
    let AlbumItem = AVMutableMetadataItem()
    AlbumItem.identifier = .commonIdentifierAlbumName
    AlbumItem.value = Album as (any NSCopying & NSObjectProtocol)?
    let GenreItem = AVMutableMetadataItem()
    GenreItem.identifier = .quickTimeMetadataGenre
    GenreItem.value = Genre as (any NSCopying & NSObjectProtocol)?
    let TrackNumberItem = AVMutableMetadataItem()
    TrackNumberItem.identifier = .iTunesMetadataTrackNumber
    TrackNumberItem.value = TrackNumber as (any NSCopying & NSObjectProtocol)?
    return [TitleItem, ArtistItem, ArtworkItem, YearItem, AlbumItem, GenreItem, TrackNumberItem]
}

func EncodeAudio(_ MetaData: [AVMetadataItem], _ URLString: String, _ StartTime: Double) -> String {
    do {
        let SongName = MetaData.filter({$0.commonKey == .commonKeyTitle}).first?.stringValue ?? "Unknown"
        let Composition = AVMutableComposition()
        let Asset = AVURLAsset(url: URL(string: URLString)!)
        print("Creating Audio Asset Track...")
        guard let AudioAssetTrack = Asset.tracks(withMediaType: AVMediaType.audio).first else { return "Can't get AudioAssetTrack!" }
        guard let AudioCompositionTrack = Composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return "Unable to add track!" }
        try AudioCompositionTrack.insertTimeRange(CMTimeRange(start: CMTime(seconds: StartTime, preferredTimescale: AudioAssetTrack.naturalTimeScale), end: Asset.duration), of: AudioAssetTrack, at: CMTime.zero)
        let OutputURL = URL(fileURLWithPath: "\(AppDataDir())/\(SongName).m4a")
        if FileManager.default.fileExists(atPath: OutputURL.path) {
            try? FileManager.default.removeItem(atPath: OutputURL.path)
        }
        let ExportSession = AVAssetExportSession(asset: Composition, presetName: AVAssetExportPresetPassthrough)!
        ExportSession.outputFileType = AVFileType.m4a
        ExportSession.outputURL = OutputURL
        ExportSession.metadata = MetaData
        print("Exporting...")
        let Semaphore = DispatchSemaphore(value: 0)
        ExportSession.exportAsynchronously {
            defer {
                Semaphore.signal()
            }
            guard case ExportSession.status = AVAssetExportSession.Status.completed else { return }
            print("Done!")
        }
        Semaphore.wait()
        return "Success"
    } catch {
        print(error)
        return error.localizedDescription
    }
}

extension Data {
    static func Download(_ URLString: String) -> Data {
        do {
            return try Data(contentsOf: URL(string: URLString)!)
        } catch {
            print(error)
            return Data()
        }
    }
}

func AppDataDir() -> String {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
}

func GetYearFromDate(_ DateString: String) -> String {
    let MyDateFormatter = DateFormatter()
    MyDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let YearFormatter = DateFormatter()
    YearFormatter.dateFormat = "yyyy"
    return YearFormatter.string(from: MyDateFormatter.date(from: DateString) ?? Date())
}

func ShowAlert(_ Alert: UIAlertController) {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(Alert, animated: true)
    }
}

func Dismiss() {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
    }
}

func GetVideoID(_ Video: String) -> String {
    if Video.contains("youtu.be") {
        return Video.components(separatedBy: "youtu.be/")[1].components(separatedBy: "?")[0]
    } else {
        return Video
    }
}

extension Color {
    init(Hex: String, Opacity: CGFloat = 1.0) {
        let Hex = Hex.replacingOccurrences(of: "#", with: "")
        if Hex.count == 6, let Red = Int(Hex.prefix(2), radix: 16), let Green = Int(Hex.prefix(4).suffix(2), radix: 16), let Blue = Int(Hex.suffix(2), radix: 16) {
            self = Color(UIColor.init(red: CGFloat(Red) / 255, green: CGFloat(Green) / 255, blue: CGFloat(Blue) / 255, alpha: Opacity))
        } else {
            self = .clear
        }
    }
}

extension String {
    func levenshteinDistanceScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Double {
        var firstString = self
        var secondString = string
        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let empty = [Int](repeating:0, count: secondString.count)
        var last = [Int](0...secondString.count)
        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }
        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)
        if let validDistance = last.last {
            return  1 - (Double(validDistance) / Double(lowestScore))
        }
        return 0.0
    }
}

struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .scaleEffect(configuration.isPressed ? 0.8 : 1)
        .opacity(configuration.isPressed ? 0.5 : 1)
        .animation(.easeIn.speed(1.5))
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

func GetSongs() -> [SongInfo] {
    do {
        var Songs: [SongInfo] = []
        for Song in try FileManager.default.contentsOfDirectory(atPath: AppDataDir()).filter({$0.hasSuffix(".m4a")}) {
            Songs.append(GetSongInfo("\(AppDataDir())/\(Song)"))
        }
        return Songs
    } catch {
        print(error)
        return []
    }
}

func GetSongInfo(_ FilePath: String) -> SongInfo {
    let Asset = AVAsset(url: URL(fileURLWithPath: FilePath))
    let AlbumName = Asset.getMetadataItem(.commonKeyAlbumName) as? String       
    let Title = Asset.getMetadataItem(.commonKeyTitle) as? String       
    let Artist = Asset.getMetadataItem(.commonKeyArtist) as? String
    var Artwork: UIImage? = nil
    if let ArtworkData = Asset.getMetadataItem(.commonKeyArtwork) as? Data {
        Artwork = UIImage(data: ArtworkData)
    }
    return SongInfo(Artwork: Artwork, Title: Title, Artist: Artist, AlbumName: AlbumName, FilePath: FilePath)
}

struct SongInfo: Hashable {
    var Artwork: UIImage?
    var Title: String?
    var Artist: String?
    var AlbumName: String?
    var FilePath: String
}

extension AVAsset {
    func getMetadataItem(_ Key: AVMetadataKey) -> Any? {
        return self.commonMetadata.first(where: {$0.commonKey == Key})?.value
    }
}

func SoundPlayer(_ FilePath: String) -> AVAudioPlayer? {
    var Player: AVAudioPlayer?
    do {
        Player = try AVAudioPlayer(data: FileManager.default.contents(atPath: FilePath)!)
    } catch {
        print(error)
    }
    return Player
}

func GetHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
    let secs = Int(seconds)
    let hours = secs / 3600
    let minutes = (secs % 3600) / 60
    let seconds = (secs % 3600) % 60
    return (hours, minutes, seconds)
}

func FormatTimeFor(seconds: Double) -> String {
    let result = GetHoursMinutesSecondsFrom(seconds: seconds)
    let hoursString = "\(result.hours)"
    let minutesString = "\(result.minutes)"
    var secondsString = "\(result.seconds)"
    if secondsString.count == 1 {
        secondsString = "0\(result.seconds)"
    }
    var time = "\(hoursString):"
    if result.hours >= 1 {
        time.append("\(minutesString):\(secondsString)")
    }
    else {
        time = "\(minutesString):\(secondsString)"
    }
    return time
}

func CalculatePercentage(one: Double, two: Double) -> Double {
    let result = ((one)/two)*100
    return (result * pow(10.0, Double(0))).rounded() / pow(10.0, Double(0))
}
