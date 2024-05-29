import SwiftUI
import AVKit

struct ContentView: View {
    @State var Songs: [SongInfo] = []
    var body: some View {
        NavigationView {
            ZStack {
                DarkGray
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer()
                        ForEach(Songs, id: \.self) { Song in
                            NavigationLink {
                                PlayerView(Info: Song)
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
                                                .foregroundColor(Color("Gray2"))
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 14)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .offset(x: 10)
                                }
                                .frame(width: UIScreen.main.bounds.width - 25, height: 87)
                                .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Music")
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
        .onAppear {
            DispatchQueue.global(qos: .utility).async {
                print(AppDataDir())
                Songs = GetSongs()
            }
        }
    }
}

struct PlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var Player: AVAudioPlayer? = nil
    @State var IsPlaying = false
    @State var Info: SongInfo
    @State var CurrentDuration: Double = 0
    @State var RemainingDuratation: Double = 0
    @State var DurationFull: Double = 0
    @State var ShowAlbumName = false
    var body: some View {
        ZStack {
            Color("DarkGray")
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    Color.clear
                        .frame(width: UIScreen.main.bounds .width - 60, height: UIScreen.main.bounds .width - 60)
                    if let Artwork = Info.Artwork {
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
                Text(Info.Title ?? "Unknown Title")
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
                if ShowAlbumName {
                    Text(Info.AlbumName ?? "Unknown Album Name")
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
                    Text(Info.Artist ?? "Unknown Artist")
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
                Button {
                    withAnimation {
                        if IsPlaying {
                            Player?.pause()
                        } else {
                            Player?.play()
                        }
                        IsPlaying = Player?.isPlaying ?? false
                    }
                } label: {
                    Image(systemName: IsPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 45))
                }
                .buttonStyle(PlayButtonStyle())
            }
        }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
            } catch {
                print(error)
            }
            Player = SoundPlayer(Info.FilePath)
            Player?.prepareToPlay()
            DurationFull = Player?.duration ?? 0
            CurrentDuration = Player?.currentTime ?? 0
            RemainingDuratation = DurationFull - CurrentDuration
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { time in
            withAnimation {
                IsPlaying = Player?.isPlaying ?? false
                CurrentDuration = Player?.currentTime ?? 0
                RemainingDuratation = DurationFull - CurrentDuration
            }
        }
        .navigationBarItems(
            leading:
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    ZStack {
                        Color("Gray")
                            .frame(width: 65, height: 25)
                            .cornerRadius(12)
                       Text("Back")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white)
                    }
                }
            ,
            trailing:
                Color.clear
                .frame(width: 65, height: 25)
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
    let AVItems = AVPlayerItem(url: URL(fileURLWithPath: FilePath)).asset.commonMetadata
    var Artwork: UIImage?
    var Title: String?
    var Artist: String?
    var AlbumName: String?
    for item in AVItems {
        if item.commonKey == .commonKeyTitle {
            Title = item.stringValue
        }
        if item.commonKey == .commonKeyArtist {
            Artist = item.stringValue
        }
        if item.commonKey == .commonKeyArtwork {
            Artwork = UIImage(data: item.value as! Data) ?? UIImage()
        }
        if item.commonKey == .commonKeyAlbumName {
            AlbumName = item.stringValue
        }
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
