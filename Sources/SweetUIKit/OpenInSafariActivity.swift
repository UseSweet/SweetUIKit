import UIKit

public class OpenInSafariActivity: UIActivity {
    fileprivate var url: URL?

    public override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(String(describing: classForCoder))
    }

    public override var activityTitle: String? {
        let defaultTitle = Bundle(for: classForCoder).localizedString(forKey: "Open in Safari", value: "Open in Safari Default", table: "OpenInSafariActivity")
        let title = Bundle.main.localizedString(forKey: "Open in Safari", value: defaultTitle, table: nil)

        return title
    }

    public override var activityImage: UIImage? {
        return UIImage(named: "Safari", in: Bundle(for: classForCoder), compatibleWith: nil)
    }

    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let item = item as? URL {
                return UIApplication.shared.canOpenURL(item)
            }
        }

        return false
    }

    public override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let item = item as? URL {
                url = item
                break
            }
        }
    }

    public override func perform() {
        if let url = self.url {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { completed in
                    self.activityDidFinish(completed)
                }
            } else {
                let completed = UIApplication.shared.openURL(url)
                activityDidFinish(completed)
            }
        } else {
            activityDidFinish(false)
        }
    }
}
