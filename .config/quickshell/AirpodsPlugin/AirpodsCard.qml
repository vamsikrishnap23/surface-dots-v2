import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../lib" as Lib
import "AirpodsModel.js" as Model

Lib.Card {
    id: root
    Layout.fillWidth: true
    // This makes the card show up in the hub when true
    property bool active: pods.connected
    property bool expanded: false

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
        z: -1 // so it doesn't block slider/button clicks
    }

    AirpodsService { id: pods }
    
    // Theme Bindings
    readonly property color textPrimary: root.theme.textPrimary
    readonly property color textSecondary: root.theme.textSecondary
    readonly property color accent: root.theme.accent
    readonly property color bgItem: root.theme.bgItem
    readonly property color bgItemHover: root.theme.bgItemHover
    readonly property color urgent: root.theme.urgent || "#e06c75" // fallback

    property real contentHeight: mainLayout.implicitHeight + (root.pad * 2) + 12 

    implicitHeight: root.active ? contentHeight : 0
    Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    opacity: root.active ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    visible: implicitHeight > 1
    clip: true

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left; anchors.right: parent.right
        anchors.top: parent.top; anchors.margins: root.pad
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            AirPodsIcon {
                Layout.preferredWidth: 32; Layout.preferredHeight: 32
                color: root.textPrimary
                variant: pods.isHeadset ? "max" : (pods.isProSeries ? "pro" : "buds")
                opacity: pods.hasAirPods ? 1.0 : 0.5
            }
            
            ColumnLayout {
                spacing: 2
                Text {
                    text: pods.modelName !== "" ? pods.modelName : (pods.deviceName !== "" ? pods.deviceName : "AirPods")
                    font.family: root.theme.font; font.pixelSize: 14; font.weight: 600
                    color: root.textPrimary
                }
                Text {
                    text: pods.hasAirPods ? "Connected" : (pods.daemonReachable ? "Not connected" : "Daemon not running")
                    font.family: root.theme.font; font.pixelSize: 12
                    color: root.textSecondary
                }
            }
            
            // Spacer
            Item { Layout.fillWidth: true }
            
            // Expand Chevron
            Text {
                text: root.expanded ? "" : ""
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                color: root.textSecondary
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }

        // Battery Rows
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: pods.hasBattery

            Repeater {
                model: pods.isHeadset ? 1 : 3
                Item {
                    Layout.fillWidth: true
                    height: 20
                    property string label: pods.isHeadset ? "Headphones" : (index === 0 ? "Left" : (index === 1 ? "Right" : "Case"))
                    property var pod: pods.isHeadset ? pods.headsetBattery : (index === 0 ? pods.leftPod : (index === 1 ? pods.rightPod : pods.caseBattery))
                    
                    Text {
                        id: leftLabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 80
                        text: label
                        font.family: root.theme.font; font.pixelSize: 13
                        color: root.textSecondary
                    }

                    Rectangle {
                        anchors.left: leftLabel.right; anchors.leftMargin: 8
                        anchors.right: rightBox.left; anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        height: 6
                        radius: 3
                        color: root.bgItem
                        
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: 3
                            width: parent.width * Model.levelFraction(pod.level)
                            color: pod.level <= 20 ? root.urgent : root.accent
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }
                    }

                    RowLayout {
                        id: rightBox
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        spacing: 4
                        Item { Layout.fillWidth: true } // pushes to the right
                        Text {
                            visible: pod.charging || (pod.inEar === true)
                            text: pod.charging ? "" : "󰋎"
                            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                            color: root.theme.accent
                        }
                        Text {
                            text: Model.levelText(pod.level)
                            font.family: root.theme.font; font.pixelSize: 13; font.weight: 600
                            color: (pod.charging || (pod.inEar === true)) ? root.theme.accent : root.textPrimary
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
        
        // Error messages
        Text {
            Layout.fillWidth: true
            visible: pods.actionStatus !== "" || (pods.lastError !== "" && pods.daemonReachable)
            text: pods.actionStatus !== "" ? pods.actionStatus : pods.lastError
            color: root.urgent
            font.family: root.theme.font; font.pixelSize: 12
            wrapMode: Text.WordWrap
        }

        // Noise Modes
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.expanded && pods.hasAirPods && pods.availableModes().length > 0

            Text {
                text: "Listening Mode"
                font.family: root.theme.font; font.pixelSize: 11; font.weight: 700
                color: root.textSecondary
                Layout.topMargin: 4
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    model: pods.availableModes()
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 10
                        color: (pods.noiseMode === modelData) ? root.accent : root.bgItem
                        
                        Rectangle {
                            anchors.fill: parent; radius: 10
                            color: "black"
                            opacity: modeMouse.containsMouse ? (pods.noiseMode === modelData ? 0.1 : 0.05) : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Model.noiseModeName(modelData)
                            color: (pods.noiseMode === modelData) ? root.theme.bgMain : root.textPrimary
                            font.family: root.theme.font; font.pixelSize: 12; font.weight: 600
                        }
                        MouseArea {
                            id: modeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pods.setNoiseMode(modelData)
                        }
                    }
                }
            }
        }
        
        // Advanced Controls
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            visible: root.expanded && pods.hasAirPods && (pods.supportsConversationalAwareness || pods.supportsOneBudANC || pods.supportsAdaptive)

            Text {
                text: "Controls"
                font.family: root.theme.font; font.pixelSize: 11; font.weight: 700
                color: root.textSecondary
                Layout.topMargin: 4
            }

            // Adaptive Slider
            RowLayout {
                Layout.fillWidth: true
                visible: pods.supportsAdaptive && pods.noiseMode === Model.NOISE_ADAPTIVE
                Text {
                    text: "Adaptive Level"
                    font.family: root.theme.font; font.pixelSize: 13
                    color: root.textPrimary
                    Layout.fillWidth: true
                }
                Slider {
                    Layout.preferredWidth: 120
                    from: 0; to: 100; stepSize: 5
                    value: pods.adaptiveNoiseLevel
                    onMoved: pods.setAdaptiveNoiseLevel(value)
                }
            }

            // Toggles Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                // Conversation Awareness Button
                Rectangle {
                    visible: pods.supportsConversationalAwareness
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 10
                    color: pods.conversationalAwareness ? root.accent : root.bgItem
                    
                    Rectangle { anchors.fill: parent; radius: 10; color: "black"; opacity: caMouse.containsMouse ? 0.05 : 0 }

                    Text {
                        anchors.centerIn: parent
                        text: "Conv. Awareness"
                        color: pods.conversationalAwareness ? root.theme.bgMain : root.textPrimary
                        font.family: root.theme.font; font.pixelSize: 12; font.weight: 600
                    }
                    MouseArea {
                        id: caMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pods.setConversationalAwareness(!pods.conversationalAwareness)
                    }
                }

                // One-Bud ANC Button
                Rectangle {
                    visible: pods.supportsOneBudANC
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 10
                    color: pods.oneBudANC ? root.accent : root.bgItem
                    
                    Rectangle { anchors.fill: parent; radius: 10; color: "black"; opacity: obaMouse.containsMouse ? 0.05 : 0 }

                    Text {
                        anchors.centerIn: parent
                        text: "One-Bud ANC"
                        color: pods.oneBudANC ? root.theme.bgMain : root.textPrimary
                        font.family: root.theme.font; font.pixelSize: 12; font.weight: 600
                    }
                    MouseArea {
                        id: obaMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pods.setOneBudANC(!pods.oneBudANC)
                    }
                }

                // Ear Detection Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.columnSpan: (pods.supportsConversationalAwareness && !pods.supportsOneBudANC) ? 1 : 2
                    Layout.preferredHeight: 38
                    radius: 10
                    color: root.bgItem
                    
                    Rectangle { anchors.fill: parent; radius: 10; color: "black"; opacity: edMouse.containsMouse ? 0.05 : 0 }

                    Text {
                        anchors.centerIn: parent
                        text: Model.earDetectionName(pods.earDetectionBehavior)
                        color: root.textPrimary
                        font.family: root.theme.font; font.pixelSize: 12; font.weight: 600
                    }
                    MouseArea {
                        id: edMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pods.cycleEarDetection()
                    }
                }
            }
        }
    }
}
