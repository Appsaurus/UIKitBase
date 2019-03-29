
import UIFontIcons

public enum AuthIcons: String, FontIconEnum{
    case Phone = "\u{e900}"
    case Mail = "\u{e901}"
    case LinkedIn = "\u{e904}"
    case Facebook = "\u{e905}"
    case Google = "\u{e906}"
    case Twitter = "\u{e921}"

    public static func name() -> String{
        return "AuthIcons"
    }
}
