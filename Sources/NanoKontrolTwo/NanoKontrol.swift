import Foundation
import Combine
import CombineMIDI

public class NanoKontrol {

    public struct Kontrol {
        public enum KontrolType {
            case slider
            case knob
            case button
        }

        public let type: KontrolType
        public var name: String
        let midiIdentifier: Int

        public var value: Int = 0 {
            didSet {
                guard let updateHandler = updateHandler else { return }
                updateHandler(self)
            }
        }

        public var percentage: Float {
            return Float(value) / 127.0
        }

        public var isPressed: Bool {
            guard type == .button else { return false }
            return value == 127
        }

        public var isReleased: Bool {
            guard type == .button else { return false }
            return value == 0
        }

        public var updateHandler: ((Kontrol)->Void)?
    }

    public struct Track {
        public var slider: Kontrol
        public var knob: Kontrol
        public var soloButton: Kontrol
        public var muteButton: Kontrol
        public var recordButton: Kontrol

        public var allKontrols: [Kontrol] {
            return [slider, knob, soloButton, muteButton, recordButton]
        }

        public static func track(number: Int) -> Track {
            return Track(slider: Kontrol(type: .slider, name: "Slider \(number+1)", midiIdentifier: number),
                         knob: Kontrol(type: .knob, name: "Knob \(number+1)", midiIdentifier: number + 16),
                         soloButton: Kontrol(type: .button, name: "Solo Button \(number+1)", midiIdentifier: number + 32),
                         muteButton: Kontrol(type: .button, name: "Mute Button \(number+1)", midiIdentifier: number + 48),
                         recordButton: Kontrol(type: .button, name: "Record Button \(number+1)", midiIdentifier: number + 64))
        }
    }

    public struct Buttons {
        public var rewind = Kontrol(type: .button, name: "Rewind", midiIdentifier: 43)
        public var forward = Kontrol(type: .button, name: "Forward", midiIdentifier: 44)
        public var cycle = Kontrol(type: .button, name: "Cycle", midiIdentifier: 46)
        public var trackPrev = Kontrol(type: .button, name: "Previous Track", midiIdentifier: 58)
        public var trackNext = Kontrol(type: .button, name: "Next Track", midiIdentifier: 59)
        public var stop = Kontrol(type: .button, name: "Stop", midiIdentifier: 42)
        public var play = Kontrol(type: .button, name: "Play", midiIdentifier: 41)
        public var record = Kontrol(type: .button, name: "Record", midiIdentifier: 45)
        public var markerSet = Kontrol(type: .button, name: "Set Marker", midiIdentifier: 60)
        public var markerPrev = Kontrol(type: .button, name: "Previous Marker", midiIdentifier: 61)
        public var markerNext = Kontrol(type: .button, name: "Next Marker", midiIdentifier: 62)

        public var allButtons: [Kontrol] {
            return [rewind, forward, cycle, trackPrev,trackNext, stop, play, record, markerSet, markerPrev, markerNext]
        }
    }

    private lazy var midiIdentifierLookupTable = { () -> [Int:Kontrol] in
        var result: [Int:Kontrol] = [:]
        buttons.allButtons.forEach{ result[$0.midiIdentifier] = $0 }
        tracks.forEach{ $0.allKontrols.forEach{ result[$0.midiIdentifier] = $0 } }
        return result
    }()

    public var tracks: [Track] = [0,1,2,3,4,5,6,7].map{Track.track(number: $0)}
    public var buttons: Buttons = Buttons()
    private var midiClient: AnyCancellable?

    public init() {
        midiClient = MIDIClient(name: UUID().uuidString)
            .publisher()
            .filter { $0.status == .controlChange }
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.midiIdentifierLookupTable[Int(value.data1)]?.value = Int(value.data2)
            }
    }
}
