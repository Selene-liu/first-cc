import Cocoa
import WebKit

let W: CGFloat = 320
let H: CGFloat = 420

// ====== WKWebView subclass that accepts first responder ======
class FocusWebView: WKWebView {
    override var acceptsFirstResponder: Bool { true }
    override func becomeFirstResponder() -> Bool { true }
}

// ====== Drag Handle (top area for moving the window) ======
class DragHandle: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "退出护眼助手", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}

// ====== App Delegate ======
class AppDelegate: NSObject, NSApplicationDelegate {
    var webView: FocusWebView!
    weak var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let frame = NSRect(x: screen.maxX - W - 24, y: screen.minY + 36, width: W, height: H)

        // Borderless floating window
        let win = NSWindow(
            contentRect: frame,
            styleMask: [.borderless, .fullSizeContentView, .titled],
            backing: .buffered, defer: false
        )
        win.isOpaque = false
        win.backgroundColor = .clear
        win.level = .floating
        win.titlebarAppearsTransparent = true
        win.collectionBehavior = [.canJoinAllSpaces, .stationary]
        win.isReleasedWhenClosed = false
        win.hasShadow = true
        win.isMovableByWindowBackground = false
        self.window = win

        // Content view
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: W, height: H))
        win.contentView = contentView

        // WKWebView with focus support
        let config = WKWebViewConfiguration()
        webView = FocusWebView(frame: contentView.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.wantsLayer = true
        webView.layer?.cornerRadius = 18
        webView.layer?.masksToBounds = true
        contentView.addSubview(webView)

        // Drag handle (top 28px — positioned above webView, only intercepts top area)
        let drag = DragHandle(frame: NSRect(x: 0, y: H - 28, width: W, height: 28))
        drag.autoresizingMask = [.width, .minYMargin]
        contentView.addSubview(drag, positioned: .above, relativeTo: webView)

        // Load the widget HTML
        if let path = Bundle.main.path(forResource: "widget", ofType: "html"),
           let html = try? String(contentsOfFile: path, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: nil)
        }

        // Show window and give focus to webView
        win.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak self] in
            self?.webView.window?.makeFirstResponder(self?.webView)
        }

        NSApp.activate(ignoringOtherApps: true)
    }
}

// ====== Launch ======
let app = NSApplication.shared
app.setActivationPolicy(.accessory) // no dock icon
let delegate = AppDelegate()
app.delegate = delegate
app.run()
