import Foundation
import AVKit

func MakeSong(_ Song: MusicItem, _ VideoID: String, _ StartTime: Double) {
    print("Getting video URL...")
    guard let VideoURL = GetYouTubeVideoURL(VideoID, true) else {
        print("Failed to get video url!")
        return
    }
    EncodeAudio(MakeMetaData(Song.trackName, Song.artistName, Song.collectionName, GetYearFromDate(Song.releaseDate), Song.artworkUrl100.replacingOccurrences(of: "100x100bb.jpg", with: "1000x1000bb.png"), Song.primaryGenreName, Song.trackNumber), VideoURL.absoluteString, StartTime)
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

func EncodeAudio(_ MetaData: [AVMetadataItem], _ URLString: String, _ StartTime: Double) {
    do {
        let SongName = MetaData.filter({$0.commonKey == .commonKeyTitle}).first?.stringValue ?? "Unknown"
        let Composition = AVMutableComposition()
        let Asset = AVURLAsset(url: URL(string: URLString)!)
        print("Creating Audio Asset Track...")
        guard let AudioAssetTrack = Asset.tracks(withMediaType: AVMediaType.audio).first else { print("Can't get AudioAssetTrack!") 
return }
        guard let AudioCompositionTrack = Composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        try AudioCompositionTrack.insertTimeRange(CMTimeRange(start: CMTime(seconds: StartTime, preferredTimescale: AudioAssetTrack.naturalTimeScale), end: Asset.duration), of: AudioAssetTrack, at: CMTime.zero)
        let OutputURL = URL(fileURLWithPath: "\(AppDataDir())/\(SongName).m4a")
        if FileManager.default.fileExists(atPath: OutputURL.path) {
            try? FileManager.default.removeItem(atPath: OutputURL.path)
        }
        let ExportSession = AVAssetExportSession(asset: Composition, presetName: AVAssetExportPresetPassthrough)!
        ExportSession.outputFileType = AVFileType.m4a
        ExportSession.outputURL = OutputURL
        ExportSession.metadata = MetaData
        var ShouldWait = true
        print("Exporting...")
        ExportSession.exportAsynchronously {
            guard case ExportSession.status = AVAssetExportSession.Status.completed else { return }
            print("Done!")
            ShouldWait = false
        }
        while ShouldWait {
        }
    } catch {
        print(error)
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
