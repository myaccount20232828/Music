import SwiftUI
import AVKit
import MediaPlayer

struct ContentView: View {
    @StateObject var MP = MusicPlayer.shared
    @State var ShowPlayer = false
    @State var Search = ""
    var body: some View {
        NavigationView {
            ZStack {
                DarkGray
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                if MP.Mode == .Shuffle {
                                    MP.Mode = .Normal
                                } else {
                                    MP.Mode = .Shuffle
                                }
                            } label: {
                                Text("Shuffle")
                                .foregroundColor(MP.Mode == .Shuffle ? .red : .white)
                            }
                            Button {
                                if MP.Mode == .Repeat {
                                    MP.Mode = .Normal
                                } else {
                                    MP.Mode = .Repeat
                                }
                            } label: {
                                Text("Repeat")
                                .foregroundColor(MP.Mode == .Repeat ? .red : .white)
                            }
                        }
                        if let Song = MP.Song {
                            Button {
                                ShowPlayer = true
                            } label: {
                                Text(Song.Title ?? "Unknown")
                            }
                        }
                        ForEach(MP.Songs.filter({(Search.isEmpty ? true : $0.Title?.contains(Search) ?? false) || ($0.Artist?.contains(Search) ?? false) || ($0.AlbumName?.contains(Search) ?? false)}), id: \.self) { Song in
                            Button {
                                MP.PlaySong(Song)
                            } label: {
                                ZStack {
                                    Gray
                                    HStack {
                                        if Song.Artwork == nil {
                                            ZStack {
                                                LightGray
                                                    .frame(width: 67, height: 67)
                                                    .cornerRadius(12)
                                                Gray
                                                    .frame(width: 65, height: 65)
                                                    .cornerRadius(12)
                                                DarkGray
                                                    .opacity(0.5)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                                Image(systemName: "play")
                                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                    .foregroundColor(Color.white)
                                            }
                                        } else {
                                            ZStack {
                                                Gray
                                                    .frame(width: 67, height: 67)
                                                    .cornerRadius(12)
                                                Image(uiImage: Song.Artwork ?? UIImage())
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 67, height: 67)
                                                    .cornerRadius(12)
                                            }
                                        }
                                        VStack(alignment: .leading) {
                                            Text(Song.Title ?? "Unknown")
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                            Text(Song.Artist ?? "Unknown")
                                                .foregroundColor(Gray2)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 14)
                                        if Song.FilePath == MP.Song?.FilePath {
                                            Spacer()
                                            Image(systemName: "play")
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)
                                    //.offset(x: 10)
                                }
                                .frame(width: UIScreen.main.bounds.width - 25, height: 100)
                                .cornerRadius(16)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Music 18")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white)
                }
            }
            .navigationBarItems(
                leading:
                    Color.clear
                    .frame(width: 65, height: 25)                
                ,
                trailing:
                    NavigationLink {
                        AddMusicView()
                    } label: {
                        ZStack {
                            Gray
                                .frame(width: 65, height: 25)
                                .cornerRadius(12)
                           Text("Add")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.white)
                        }
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .searchable(text: $Search)
        .refreshable {
            MP.UpdateSongs()
        }
        .sheet(isPresented: $ShowPlayer) {
            PlayerView()
        }
    }
}

struct PlayerView: View {
    @StateObject var MP = MusicPlayer.shared
    @State var IsPlaying = false
    @State var CurrentDuration: Double = 0
    @State var RemainingDuratation: Double = 0
    @State var DurationFull: Double = 0
    @State var ShowAlbumName = false
    var body: some View {
        ZStack {
            DarkGray
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    Color.clear
                        .frame(width: UIScreen.main.bounds .width - 60, height: UIScreen.main.bounds .width - 60)
                    if let Artwork = MP.Song?.Artwork {
                        Image(uiImage: Artwork)
                            .resizable()
                            .frame(width: IsPlaying ? UIScreen.main.bounds .width - 60 : UIScreen.main.bounds .width - 140, height: IsPlaying ? UIScreen.main.bounds .width - 60 : UIScreen.main.bounds .width - 140)
                            .cornerRadius(15)
                    } else {
                        Image("Artwork")
                            .resizable()
                            .frame(width: IsPlaying ? UIScreen.main.bounds .width - 60 : UIScreen.main.bounds .width - 140, height: IsPlaying ? UIScreen.main.bounds .width - 60 : UIScreen.main.bounds .width - 140)
                            .cornerRadius(15)
                    }
                }
                Text(MP.Song?.Title ?? "Unknown Title")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                if ShowAlbumName {
                    Text(MP.Song?.AlbumName ?? "Unknown Album Name")
                        .fontWeight(.semibold)
                        .opacity(0.5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    ShowAlbumName.toggle()
                                }
                            }
                        }
                } else {
                    Text(MP.Song?.Artist ?? "Unknown Artist")
                        .fontWeight(.semibold)
                        .opacity(0.5)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    ShowAlbumName.toggle()
                                }
                            }
                        }
                }
                VStack(spacing: 10) {
                    ProgressView(value: CalculatePercentage(one: CurrentDuration, two: DurationFull), total: 100)
                        .accentColor(.gray)
                    HStack {
                        Text(FormatTimeFor(seconds: CurrentDuration))
                            .font(.system(size: 10))
                            .opacity(0.6)
                        Spacer()
                        Text("-\(FormatTimeFor(seconds: RemainingDuratation))")
                            .font(.system(size: 10))
                            .opacity(0.6)
                    }
                }
                .padding(30)
                HStack(spacing: 35) {
                    Button {
                        withAnimation {
                            MP.PlayPreviousSong()
                        }
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 45))
                    }
                    Button {
                        withAnimation {
                            MP.TogglePlayback()
                            IsPlaying = MP.Player?.isPlaying ?? false
                        }
                    } label: {
                        Image(systemName: IsPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 45))
                    }
                    Button {
                        withAnimation {
                            MP.PlayNextSong()
                        }
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 45))
                    }
                }
                .buttonStyle(PlayButtonStyle())
            }
        }
        .onAppear {
            IsPlaying = MP.Player?.isPlaying ?? false
            DurationFull = MP.Player?.duration ?? 0
            CurrentDuration = MP.Player?.currentTime ?? 0
            RemainingDuratation = DurationFull - CurrentDuration
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { time in
            withAnimation {
                IsPlaying = MP.Player?.isPlaying ?? false
                DurationFull = MP.Player?.duration ?? 0
                CurrentDuration = MP.Player?.currentTime ?? 0
                RemainingDuratation = DurationFull - CurrentDuration
            }
        }
    }
}

enum PlaybackMode {
    case Shuffle
    case Repeat
    case Normal
}

class MusicPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    override init() {
        super.init()
        UpdateSongs()
        SetupAudioSession()
        SetupRemoteTransportControls()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    @Published var Song: SongInfo?
    @Published var Player: AVAudioPlayer?
    @Published var Songs: [SongInfo] = []
    @Published var Mode: PlaybackMode = .Normal
    var NowPlayingInfo: [String: Any] = [:]
    var PlaybackTimer: Timer?
    static let shared = MusicPlayer()
    func PlaySong(_ Song: SongInfo) {
        do {
            self.Song = Song
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
            Player?.stop()
            try Player = SoundPlayer(Song.FilePath)
            Player?.delegate = self
            Player?.prepareToPlay()
            Player?.play()
            SetupNowPlayingInfo()
            StartPlaybackTimer()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    func SetupAudioSession() {
        do {
            let AudioSession = AVAudioSession.sharedInstance()
            try AudioSession.setCategory(.playback, mode: .default)
            try AudioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    func SetupNowPlayingInfo() {
        if let Title = Song?.Title {
            NowPlayingInfo[MPMediaItemPropertyTitle] = Title
        }        
        if let Artist = Song?.Artist {
            NowPlayingInfo[MPMediaItemPropertyArtist] = Artist
        }
        if let Artwork = Song?.Artwork {
            NowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: Artwork)
        }
        NowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Player?.duration ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = NowPlayingInfo
    }
    func StartPlaybackTimer() {
        PlaybackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.UpdateNowPlayingInfo()
        }
    }
    func UpdateNowPlayingInfo() {
        guard let Player = Player else { return }
        NowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Player.currentTime
        NowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = Player.isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = NowPlayingInfo
    }
    func TogglePlayback() {
        if Player?.isPlaying ?? false {
            Player?.pause()
        } else {
            Player?.play()
        }
        UpdateNowPlayingInfo()
    }
    func PlayNextSong() {
        guard let CurrentIndex = Songs.firstIndex(where: { $0 == Song }) else {
            return
        }
        PlaySong(Songs[CurrentIndex == Songs.count - 1 ? 0 : CurrentIndex + 1])
    }
    func PlayPreviousSong() {
        guard let CurrentIndex = Songs.firstIndex(where: { $0 == Song }) else {
            return
        }        
        PlaySong(Songs[CurrentIndex == 0 ? Songs.count - 1 : CurrentIndex - 1])
    }
    func PlayRandomSong() {
        if let Song = Songs.randomElement() {
            PlaySong(Song)
        }
    }
    func SetupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.TogglePlayback()
            return .success
        }
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.TogglePlayback()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.PlayPreviousSong()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.PlayNextSong()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            let newPositionTime = event.positionTime
            self.Player?.currentTime = TimeInterval(newPositionTime)
            self.UpdateNowPlayingInfo()
            return .success
        }
    }
    func UpdateSongs() {
        DispatchQueue.global(qos: .utility).async {
            self.Songs = GetSongs()
        }
    }
    func audioPlayerDidFinishPlaying(_ Player: AVAudioPlayer, successfully Success: Bool) {
        if Success {
            switch Mode {
                case .Shuffle: PlayRandomSong()
                case .Repeat: Player.play()
                case .Normal: PlayNextSong()
            }
        }
    }
}
