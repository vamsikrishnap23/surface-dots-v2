import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import "../lib" as Lib

PanelWindow {
    id: launcherWin
    
    // Anchor to the full screen for overlay positioning
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
    required property var theme
    property bool isOpen: false
    property bool hasLoadedApps: false
    
    visible: shell.activeHeight > 1
    
    onIsOpenChanged: {
        if (isOpen) {
            searchField.text = ""
            searchField.forceActiveFocus()
            if (!hasLoadedApps) {
                hasLoadedApps = true
                appLoader.running = true
            }
        }
    }
    
    function toggle() { isOpen = !isOpen }
    function close() { isOpen = false }
    
    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onClicked: launcherWin.close()
    }
    
    Item {
        id: shell
        width: 600
        height: 500
        anchors.centerIn: parent

        property real activeHeight: isOpen ? height : 0
        Behavior on activeHeight { NumberAnimation { duration: 360; easing.type: Easing.OutQuint } }

        opacity: isOpen ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }

        Item {
            id: shellShadow
            z: -1
            visible: shell.activeHeight > 0

            property int spread: 34

            anchors.centerIn: parent
            width: clipped.width + spread * 2
            height: clipped.height + spread * 2
            clip: true

            Item {
                anchors.centerIn: parent
                width: clipped.width
                height: clipped.height

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    radius: 26; samples: 31
                    color: "#70000000"
                    horizontalOffset: 0; verticalOffset: 6
                }
                Rectangle { anchors.fill: parent; radius: 16; color: "black" }
            }
        }

        Item {
            id: clipped
            width: parent.width
            height: parent.activeHeight
            anchors.centerIn: parent
            clip: true

            Rectangle {
                width: shell.width
                height: shell.height
                anchors.centerIn: parent
                color: launcherWin.theme.bgMain
                radius: Lib.ThemeEngine ? launcherWin.theme.radiusOuter || 16 : 16
                border.color: launcherWin.theme.border
                border.width: 1
                
                MouseArea { anchors.fill: parent } // Block clicks from falling through
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // Search Bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: launcherWin.theme.bgItem
                        radius: Lib.ThemeEngine ? launcherWin.theme.radiusInner || 8 : 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            
                            Text {
                                text: "" // Nerd font search icon
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: launcherWin.theme.textSecondary
                            }
                            
                            TextInput {
                                id: searchField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                color: launcherWin.theme.textPrimary
                                font.family: "Manrope"
                                font.pixelSize: 16
                                clip: true
                                
                                onTextChanged: filterApps()
                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) launcherWin.close()
                                    else if (event.key === Qt.Key_Return) launchFirst()
                                    else if (event.key === Qt.Key_Down) appView.forceActiveFocus()
                                }
                            }
                        }
                    }
                    
                    // App List (NO ICONS)
                    ListView {
                        id: appView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: filteredModel
                        spacing: 4
                        
                        delegate: Rectangle {
                            width: appView.width
                            height: 44
                            color: "transparent"
                            
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: launchApp(model.cmd, model.needsTerminal)
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: launcherWin.theme.bgItemHover
                                    radius: Lib.ThemeEngine ? launcherWin.theme.radiusInner || 8 : 8
                                    opacity: ma.containsMouse || appView.currentIndex === index ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                }
                                
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    verticalAlignment: Text.AlignVCenter
                                    text: model.name
                                    color: launcherWin.theme.textPrimary
                                    font.family: "Manrope"
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) launcherWin.close()
                            else if (event.key === Qt.Key_Return && currentIndex >= 0) {
                                launchApp(filteredModel.get(currentIndex).cmd, filteredModel.get(currentIndex).needsTerminal)
                            }
                            else if (event.key === Qt.Key_Up && currentIndex === 0) {
                                searchField.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }
    
    ListModel { id: fullModel }
    ListModel { id: filteredModel }
    
    function filterApps() {
        filteredModel.clear()
        var search = searchField.text.trim().toLowerCase()
        if (search === "") {
            for (var i = 0; i < fullModel.count; i++) {
                filteredModel.append(fullModel.get(i))
            }
            if (filteredModel.count > 0) appView.currentIndex = 0
            return
        }

        var results = []
        for (var i = 0; i < fullModel.count; i++) {
            var item = fullModel.get(i)
            var name = item.name.toLowerCase()
            var cmd = item.cmd.toLowerCase()
            var score = -1
            
            if (name === search) {
                score = 100
            } else if (name.startsWith(search)) {
                score = 90
            } else if (name.indexOf(search) !== -1) {
                score = 50
            } else if (cmd.indexOf(search) !== -1) {
                score = 30
            } else {
                var k = 0
                for (var j = 0; j < name.length && k < search.length; j++) {
                    if (name[j] === search[k]) k++
                }
                if (k === search.length) {
                    score = 10
                }
            }
            
            if (score > -1) {
                // We must clone the item object from the ListElement
                var obj = {}
                for (var key in item) { obj[key] = item[key] }
                results.push({item: obj, score: score, origIndex: i})
            }
        }
        
        results.sort(function(a, b) { 
            if (b.score !== a.score) return b.score - a.score
            return a.origIndex - b.origIndex 
        })
        
        for (var i = 0; i < results.length; i++) {
            filteredModel.append(results[i].item)
        }
        
        if (filteredModel.count > 0) appView.currentIndex = 0
    }
    
    function launchFirst() {
        if (filteredModel.count > 0) {
            launchApp(filteredModel.get(0).cmd, filteredModel.get(0).needsTerminal)
        }
    }
    
    function launchApp(command, needsTerminal) {
        launcherWin.close()
        Qt.callLater(() => {
            if (needsTerminal)
                Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"kitty -e " + command + "\")"])
            else
                Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exec_cmd(\"" + command + "\")"])
        })
    }
    
    function loadApps() {
        fullModel.clear()
        appLoader.running = false
        appLoader.running = true
    }

    function scheduleAppReload() {
        if (!hasLoadedApps) return
        appReloadTimer.restart()
    }

    Timer { id: appReloadTimer; interval: 600; onTriggered: launcherWin.loadApps() }

    component AppDirWatch: FolderListModel {
        showDirs: false
        showFiles: true
        nameFilters: ["*.desktop"]
        sortField: FolderListModel.Unsorted
        property bool primed: false
        onStatusChanged: if (status === FolderListModel.Ready) primed = true
        onCountChanged: if (primed) launcherWin.scheduleAppReload()
    }
    AppDirWatch { folder: "file://" + Quickshell.env("HOME") + "/.local/share/applications" }
    AppDirWatch { folder: "file:///usr/share/applications" }
    AppDirWatch { folder: "file:///var/lib/flatpak/exports/share/applications" }

    Process {
        id: appLoader
        running: false
        command: [Qt.resolvedUrl("applist.sh").toString().replace("file://", "")]
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n')
                for (const line of lines) {
                    if (line.trim().length === 0) continue
                    const parts = line.split('|')
                    if (parts.length >= 5) {
                        fullModel.append({
                            name: parts[0], icon: parts[1], cmd: parts[2],
                            needsTerminal: (parts[3] || "").trim() === "true",
                            filename: parts[4]
                        })
                    }
                }
                filterApps()
            }
        }
    }
}
