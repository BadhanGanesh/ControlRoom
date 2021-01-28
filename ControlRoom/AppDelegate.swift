//
//  AppDelegate.swift
//  ControlRoom
//
//  Created by Paul Hudson on 12/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import Cocoa
import KeyboardShortcuts
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var mainWindow: MainWindowController = MainWindowController()

    var menuBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindow.showWindow(self)

        if mainWindow.preferences.wantsMenuBarIcon {
            addMenuBarItem()
        }

        KeyboardShortcuts.onKeyUp(for: .resendLastPushNotification) { [weak self] in
            self?.resendLastPushNotification()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    @IBAction func orderFrontStandardAboutPanel(_ sender: Any?) {
        let authors = Bundle.main.authors

        if authors.isNotEmpty {
            let content = NSViewController()
            content.title = "Control Room"
            let view = NSHostingView(rootView: AboutView(authors: authors))
            view.frame.size = view.fittingSize
            content.view = view
            let panel = NSPanel(contentViewController: content)
            panel.styleMask = [.closable, .titled]
            panel.orderFront(sender)
            panel.makeKey()
        } else {
            NSApp.orderFrontStandardAboutPanel(sender)
        }
    }

    func addMenuBarItem() {
        menuBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menuBarItem.button?.image = NSImage(named: NSImage.smartBadgeTemplateName)
        menuBarItem.menu = NSMenu()

        let resend = NSMenuItem(title: "Resend last push notification", action: #selector(resendLastPushNotification), keyEquivalent: "")
        resend.setShortcut(for: .resendLastPushNotification)
        menuBarItem.menu?.addItem(resend)
    }

    func removeMenuBarItem() {
        guard menuBarItem != nil else { return }
        NSStatusBar.system.removeStatusItem(menuBarItem)
    }

    @objc func resendLastPushNotification() {
        SimCtl.sendPushNotification(mainWindow.preferences.lastSimulatorUDID, appID: mainWindow.preferences.lastBundleID, jsonPayload: mainWindow.preferences.pushPayload)
    }
}
