// Делает Ghostty программой по умолчанию для запуска скриптов и исполняемых
// файлов (.command, .sh, unix-executable) — то, что раньше открывал Terminal.app.
// Запуск: swift macos/set-default-terminal.swift
import Foundation
import CoreServices

let bundleID = "com.mitchellh.ghostty" as CFString
let utis = ["public.unix-executable", "com.apple.terminal.shell-script", "public.shell-script"]

var failed = false
for uti in utis {
    let shell = LSSetDefaultRoleHandlerForContentType(uti as CFString, LSRolesMask.shell, bundleID)
    let viewer = LSSetDefaultRoleHandlerForContentType(uti as CFString, LSRolesMask.viewer, bundleID)
    let current = LSCopyDefaultRoleHandlerForContentType(uti as CFString, LSRolesMask.shell)?
        .takeRetainedValue() as String? ?? "-"
    print("  \(uti): \(current)")
    if shell != noErr || viewer != noErr { failed = true }
}
exit(failed ? 1 : 0)
