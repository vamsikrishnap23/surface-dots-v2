import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../lib" as Lib

PanelWindow {
    id: root
    required property var theme

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "clipboard-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    visible: shell.activeHeight > 1

    property bool isOpen: false
    property bool confirmClear: false

    onIsOpenChanged: {
        if (isOpen) {
            fullModel.clear()
            filteredModel.clear()
            searchField.text = ""
            root.confirmClear = false
            loaderProc.running = true
            searchField.forceActiveFocus()
        }
    }

    function toggle() { isOpen = !isOpen }
    function open() { isOpen = true }
    function close() { isOpen = false }

    Process {
        id: loaderProc
        running: false
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.split('\n')
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    if (line.length === 0) continue
                    var tabIdx = line.indexOf('\t')
                    if (tabIdx === -1) continue
                    
                    var clipId = line.substring(0, tabIdx)
                    var preview = line.substring(tabIdx + 1)
                    
                    var isImage = preview.startsWith("[[ binary data")
                    var disp = preview
                    if (isImage) {
                        disp = preview.replace("[[ binary data ", "  Image: ").replace(" ]]", "")
                    }
                    
                    fullModel.append({
                        "rawLine": line,
                        "clipId": clipId,
                        "previewText": disp,
                        "isImage": isImage
                    })
                }
                filterClips()
            }
        }
    }

    function filterClips() {
        filteredModel.clear()
        var search = searchField.text.trim().toLowerCase()
        if (search === "") {
            for (var i = 0; i < fullModel.count; i++) {
                filteredModel.append(fullModel.get(i))
            }
            if (filteredModel.count > 0) listView.currentIndex = 0
            return
        }

        for (var i = 0; i < fullModel.count; i++) {
            var item = fullModel.get(i)
            if (item.previewText.toLowerCase().indexOf(search) !== -1) {
                filteredModel.append(item)
            }
        }
        if (filteredModel.count > 0) listView.currentIndex = 0
    }

    function launchFirst() {
        if (filteredModel.count > 0) {
            var item = filteredModel.get(listView.currentIndex >= 0 ? listView.currentIndex : 0)
            Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/utils/cliphist_action.sh", "copy", item.clipId])
            root.close()
        }
    }

    ListModel { id: fullModel }
    ListModel { id: filteredModel }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Item {
        id: shell
        width: 550
        height: 600
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
                id: container
                width: shell.width
                height: shell.height
                anchors.centerIn: parent
                radius: 16
                color: root.theme.bgMain
                border.color: root.theme.border
                border.width: 1

                MouseArea { 
                    anchors.fill: parent
                    onClicked: { root.confirmClear = false } 
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Search Bar + Wipe Action
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: root.theme.bgItem
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 8
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 12
                            
                            Text {
                                text: ""
                                font.family: root.theme.iconFont
                                font.pixelSize: 16
                                color: root.theme.textSecondary
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            TextInput {
                                id: searchField
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumWidth: 0
                                verticalAlignment: TextInput.AlignVCenter
                                color: root.theme.textPrimary
                                font.family: root.theme.textFont
                                font.pixelSize: 16
                                clip: true
                                
                                Text {
                                    text: "Search clipboard"
                                    color: root.theme.textSecondary
                                    font.family: root.theme.textFont
                                    font.pixelSize: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    visible: !searchField.text && !searchField.activeFocus
                                }
                                
                                onTextChanged: filterClips()
                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        root.close()
                                        event.accepted = true
                                    }
                                    else if (event.key === Qt.Key_Return) {
                                        launchFirst()
                                        event.accepted = true
                                    }
                                    else if (event.key === Qt.Key_Down) {
                                        listView.forceActiveFocus()
                                        event.accepted = true
                                    }
                                }
                                onActiveFocusChanged: if (activeFocus) root.confirmClear = false
                            }
                            
                            Rectangle {
                                id: wipeBtn
                                property real animWidth: root.confirmClear ? 110 : 32
                                Behavior on animWidth { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                
                                Layout.preferredWidth: animWidth
                                Layout.minimumWidth: animWidth
                                Layout.maximumWidth: animWidth
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                radius: 8
                                color: wipeMouse.containsMouse ? root.theme.accentRed : (root.confirmClear ? root.theme.accentRed : "transparent")
                                Behavior on color { ColorAnimation { duration: 150 } }
                                clip: true
                                
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: root.confirmClear ? "" : ""
                                        font.family: root.theme.iconFont
                                        font.pixelSize: 14
                                        color: wipeMouse.containsMouse || root.confirmClear ? "white" : root.theme.textSecondary
                                    }
                                    Text {
                                        visible: root.confirmClear
                                        text: "Clear All"
                                        font.family: root.theme.textFont
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        color: "white"
                                    }
                                }
                                
                                MouseArea {
                                    id: wipeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!root.confirmClear) {
                                            root.confirmClear = true
                                        } else {
                                            Quickshell.execDetached(["cliphist", "wipe"])
                                            fullModel.clear()
                                            filteredModel.clear()
                                            root.confirmClear = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Clipboard List
                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: filteredModel
                        spacing: 4
                        
                        delegate: Rectangle {
                            width: listView.width
                            height: 48
                            color: "transparent"
                            
                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: { 
                                    listView.currentIndex = index
                                    root.confirmClear = false
                                }
                                onClicked: {
                                    Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/quickshell/utils/cliphist_action.sh", "copy", model.clipId])
                                    root.close()
                                }
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: root.theme.bgItemHover
                                    radius: 8
                                    opacity: itemMouse.containsMouse || listView.currentIndex === index ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12
                                    
                                    Text {
                                        text: model.clipId
                                        font.family: "Monospace"
                                        font.pixelSize: 12
                                        color: root.theme.textSecondary
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: 30
                                    }
                                    
                                    Text {
                                        text: model.previewText
                                        font.family: root.theme.textFont
                                        font.pixelSize: 15
                                        color: root.theme.textPrimary
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                root.close()
                                event.accepted = true
                            }
                            else if (event.key === Qt.Key_Return) {
                                launchFirst()
                                event.accepted = true
                            }
                            else if (event.key === Qt.Key_Up) {
                                if (listView.currentIndex > 0) listView.currentIndex--
                                else searchField.forceActiveFocus()
                                event.accepted = true
                            }
                            else if (event.key === Qt.Key_Down) {
                                if (listView.currentIndex < filteredModel.count - 1) listView.currentIndex++
                                event.accepted = true
                            }
                        }
                    }
                }
            }
        }
    }
}
