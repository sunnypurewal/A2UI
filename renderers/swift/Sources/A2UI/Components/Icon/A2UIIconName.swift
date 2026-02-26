import Foundation

/// Supported Google Font / Material icon names.
enum A2UIIconName: String, CaseIterable {
    case accountCircle
    case add
    case arrowBack
    case arrowForward
    case attachFile
    case calendarToday
    case call
    case camera
    case check
    case close
    case delete
    case download
    case edit
    case event
    case error
    case fastForward
    case favorite
    case favoriteOff
    case folder
    case help
    case home
    case info
    case locationOn
    case lock
    case lockOpen
    case mail
    case menu
    case moreVert
    case moreHoriz
    case notificationsOff
    case notifications
    case pause
    case payment
    case person
    case phone
    case photo
    case play
    case print
    case refresh
    case rewind
    case search
    case send
    case settings
    case share
    case shoppingCart
    case skipNext
    case skipPrevious
    case star
    case starHalf
    case starOff
    case stop
    case upload
    case visibility
    case visibilityOff
    case volumeDown
    case volumeMute
    case volumeOff
    case volumeUp
    case warning

    /// The SF Symbol equivalent for this Material icon name.
    var sfSymbolName: String {
        switch self {
        case .accountCircle: return "person.circle"
        case .add: return "plus"
        case .arrowBack: return "arrow.left"
        case .arrowForward: return "arrow.right"
        case .attachFile: return "paperclip"
        case .calendarToday: return "calendar"
        case .call: return "phone"
        case .camera: return "camera"
        case .check: return "checkmark"
        case .close: return "xmark"
        case .delete: return "trash"
        case .download: return "square.and.arrow.down"
        case .edit: return "pencil"
        case .event: return "calendar"
        case .error: return "exclamationmark.circle"
        case .fastForward: return "forward.fill"
        case .favorite: return "heart.fill"
        case .favoriteOff: return "heart"
        case .folder: return "folder"
        case .help: return "questionmark.circle"
        case .home: return "house"
        case .info: return "info.circle"
        case .locationOn: return "mappin.and.ellipse"
        case .lock: return "lock"
        case .lockOpen: return "lock.open"
        case .mail: return "envelope"
        case .menu: return "line.3.horizontal"
        case .moreVert: return "ellipsis.vertical"
        case .moreHoriz: return "ellipsis"
        case .notificationsOff: return "bell.slash"
        case .notifications: return "bell"
        case .pause: return "pause"
        case .payment: return "creditcard"
        case .person: return "person"
        case .phone: return "phone"
        case .photo: return "photo"
        case .play: return "play"
        case .print: return "printer"
        case .refresh: return "arrow.clockwise"
        case .rewind: return "backward.fill"
        case .search: return "magnifyingglass"
        case .send: return "paperplane"
        case .settings: return "gear"
        case .share: return "square.and.arrow.up"
        case .shoppingCart: return "cart"
        case .skipNext: return "forward.end"
        case .skipPrevious: return "backward.end"
        case .star: return "star"
        case .starHalf: return "star.leadinghalf.filled"
        case .starOff: return "star.slash"
        case .stop: return "stop"
        case .upload: return "square.and.arrow.up"
        case .visibility: return "eye"
        case .visibilityOff: return "eye.slash"
        case .volumeDown: return "speaker.wave.1"
        case .volumeMute: return "speaker.slash"
        case .volumeOff: return "speaker.slash"
        case .volumeUp: return "speaker.wave.3"
        case .warning: return "exclamationmark.triangle"
        }
    }
}
