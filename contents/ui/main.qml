/*
 * macOS-Style 3D Carousel Slide Application Switcher (Fullscreen Frosted Glass)
 * KWin TabBox Plugin for KDE Plasma 6
 *
 * System: KDE Plasma 6 (kwin-wayland / kwin-x11), Qt 6, KF6
 * Pure neutral frosted glass, 3D carousel slides, fullscreen overlay
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects as Effects
import org.kde.plasma.core as PlasmaCore
import org.kde.kwin as KWin
import org.kde.kirigami as Kirigami

KWin.TabBoxSwitcher {
    id: tabBox

    // ClientModel alias for TabBox client model
    property alias clientModel: tabBox.model

    Instantiator {
        active: tabBox.visible
        delegate: PlasmaCore.Dialog {
            id: dialog
            location: PlasmaCore.Types.Floating
            visible: true
            flags: Qt.Popup | Qt.X11BypassWindowManagerHint
            backgroundHints: PlasmaCore.Types.NoBackground

            // Fullscreen coverage over active display geometry
            x: tabBox.screenGeometry.x
            y: tabBox.screenGeometry.y
            width: tabBox.screenGeometry.width
            height: tabBox.screenGeometry.height

            mainItem: FocusScope {
                id: dialogMainItem
                focus: true
                width: tabBox.screenGeometry.width
                height: tabBox.screenGeometry.height

                // Total open windows count
                readonly property int windowCount: cardsRepeater.count
                property string currentCaption: ""
                property var currentIcon: ""

                // Card Dimensions: Generously sized for high-fidelity live previews
                readonly property int cardWidth: Math.min(680, Math.max(460, Math.round(dialogMainItem.width * 0.44)))
                readonly property int cardHeight: Math.min(460, Math.max(300, Math.round(dialogMainItem.height * 0.52)))
                readonly property real centerX: Math.round((dialogMainItem.width - cardWidth) * 0.5)
                readonly property real centerY: Math.round((dialogMainItem.height - cardHeight) * 0.46)

                // Keyboard Navigation
                Keys.onPressed: function(event) {
                    if (windowCount <= 0) return;
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                        dialogMainItem.navigatePrev();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                        dialogMainItem.navigateNext();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (typeof tabBox.model !== "undefined" && typeof tabBox.model.activate === "function") {
                            tabBox.model.activate(tabBox.currentIndex);
                        }
                        event.accepted = true;
                    } else {
                        // Pass Alt, Tab, Shift+Tab, Escape directly to KWin C++
                        return;
                    }
                }

                function navigateNext() {
                    if (windowCount <= 0) return;
                    tabBox.currentIndex = (tabBox.currentIndex + 1) % windowCount;
                }

                function navigatePrev() {
                    if (windowCount <= 0) return;
                    tabBox.currentIndex = (tabBox.currentIndex - 1 + windowCount) % windowCount;
                }

                /* =========================================================================
                 * FULLSCREEN PURE FROSTED GLASS BACKGROUND (NO CYAN COLOR, BLOCKS BG TEXT)
                 * ========================================================================= */
                Rectangle {
                    id: fullscreenBackdrop
                    anchors.fill: parent
                    // High-opacity dark obsidian (#f00b0d14 ~ 94% opacity) completely blocks underlying code/text
                    color: "#f00b0d14"

                    // Subtle overhead specular frosted light
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: Math.round(parent.height * 0.45)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#16ffffff" }
                            GradientStop { position: 0.28; color: "#06ffffff" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    // Click outside cards to dismiss/activate current window
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof tabBox.model !== "undefined" && typeof tabBox.model.activate === "function") {
                                tabBox.model.activate(tabBox.currentIndex);
                            }
                        }
                    }
                }

                // Global Mouse Wheel Support to Glide across Carousel Slides
                WheelHandler {
                    onWheel: function(event) {
                        if (event.angleDelta.y < 0 || event.angleDelta.x > 0) {
                            dialogMainItem.navigateNext();
                        } else if (event.angleDelta.y > 0 || event.angleDelta.x < 0) {
                            dialogMainItem.navigatePrev();
                        }
                    }
                }

                /* =========================================================================
                 * 3D CAROUSEL SLIDES ASSEMBLY
                 * ========================================================================= */
                Item {
                    id: carouselContainer
                    anchors.fill: parent

                    Repeater {
                        id: cardsRepeater
                        model: tabBox.model

                        delegate: Item {
                            id: cardDelegate
                            width: dialogMainItem.cardWidth
                            height: dialogMainItem.cardHeight
                            y: dialogMainItem.centerY

                            readonly property bool isCurrent: index === tabBox.currentIndex
                            readonly property int offset: index - tabBox.currentIndex
                            readonly property string captionText: model.caption || "Application"
                            readonly property var winId: model.windowId
                            readonly property var appIcon: model.icon

                            Binding {
                                target: dialogMainItem
                                property: "currentCaption"
                                value: cardDelegate.captionText
                                when: cardDelegate.isCurrent
                            }
                            Binding {
                                target: dialogMainItem
                                property: "currentIcon"
                                value: cardDelegate.appIcon
                                when: cardDelegate.isCurrent
                            }

                            // Mathematical 3D Carousel Positioning
                            x: {
                                if (offset === 0) {
                                    return dialogMainItem.centerX;
                                } else if (offset > 0) {
                                    return dialogMainItem.centerX + (dialogMainItem.cardWidth * 0.52) + (offset - 1) * (dialogMainItem.cardWidth * 0.30);
                                } else {
                                    return dialogMainItem.centerX - (dialogMainItem.cardWidth * 0.52) + (offset + 1) * (dialogMainItem.cardWidth * 0.30);
                                }
                            }

                            scale: {
                                if (offset === 0) return 1.04;
                                var dist = Math.abs(offset);
                                return Math.max(0.68, 0.88 - (dist - 1) * 0.06);
                            }

                            opacity: {
                                if (offset === 0) return 1.0;
                                var dist = Math.abs(offset);
                                return Math.max(0.22, 0.72 - (dist - 1) * 0.15);
                            }

                            z: isCurrent ? 200 : (100 - Math.abs(offset))
                            visible: Math.abs(offset) <= 5

                            // Fluid Inertia Damping
                            Behavior on x {
                                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                            }
                            Behavior on scale {
                                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                            }

                            // 3D Carousel Y-Axis Angle Rotation (Angled towards center)
                            transform: Rotation {
                                origin.x: dialogMainItem.cardWidth * 0.5
                                origin.y: dialogMainItem.cardHeight * 0.5
                                axis { x: 0; y: 1; z: 0 }
                                angle: {
                                    if (cardDelegate.offset === 0) return 0;
                                    return cardDelegate.offset < 0 ? 24 : -24;
                                }
                                Behavior on angle {
                                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                                }
                            }

                            // Active Card Pure White / Silver Ambient Drop Glow
                            Effects.RectangularGlow {
                                anchors.fill: cardBody
                                glowRadius: cardDelegate.isCurrent ? 24 : 0
                                spread: 0.16
                                color: cardDelegate.isCurrent ? "#35ffffff" : "transparent"
                                cornerRadius: 18
                                visible: cardDelegate.isCurrent
                            }

                            // Frosted Glass Card Chassis (Pure Neutral Monochromatic Glass)
                            Rectangle {
                                id: cardBody
                                anchors.fill: parent
                                radius: 18
                                color: cardDelegate.isCurrent ? "#381c202a" : "#2212151e"
                                border.color: cardDelegate.isCurrent ? "#99ffffff" : "#28ffffff"
                                border.width: cardDelegate.isCurrent ? 2.0 : 1.0

                                // Specular Overhead Sheen on Card
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: Math.round(parent.height * 0.35)
                                    radius: 18
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: cardDelegate.isCurrent ? "#22ffffff" : "#0dffffff" }
                                        GradientStop { position: 1.0; color: "transparent" }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // Header: Application Icon + Real Application Name + Close Button
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 38

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 10

                                            // Native High-Res Application Icon
                                            Kirigami.Icon {
                                                Layout.preferredWidth: 30
                                                Layout.preferredHeight: 30
                                                Layout.alignment: Qt.AlignVCenter
                                                source: model.icon
                                            }

                                            // Window Title / Application Caption
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 1

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: cardDelegate.captionText
                                                    color: "#ffffff"
                                                    font.pixelSize: 13
                                                    font.bold: cardDelegate.isCurrent
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: model.desktopName ? model.desktopName : "Desktop 1"
                                                    color: "#80ffffff"
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                    visible: text.length > 0
                                                }
                                            }

                                            // Window Close Button (✕)
                                            Rectangle {
                                                Layout.preferredWidth: 24
                                                Layout.preferredHeight: 24
                                                Layout.alignment: Qt.AlignVCenter
                                                radius: 12
                                                color: closeMouseArea.containsMouse ? "#d32f2f" : (cardDelegate.isCurrent ? "#25ffffff" : "transparent")
                                                border.color: closeMouseArea.containsMouse ? "#ffffff" : "#40ffffff"
                                                border.width: 1
                                                visible: model.closeable !== false

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "✕"
                                                    color: "#ffffff"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: closeMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        tabBox.model.close(index);
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Large Live Application Window Thumbnail Preview
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true

                                        // Dark Preview Frame
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "#18000000"
                                            radius: 10
                                            border.color: cardDelegate.isCurrent ? "#40ffffff" : "#1a555555"
                                            border.width: 1
                                        }

                                        // Live Thumbnail Item (Bridges KWin.WindowThumbnail)
                                        ThumbnailItem {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            windowId: cardDelegate.winId
                                        }

                                        // Minimized State Badge
                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: minLabel.implicitWidth + 22
                                            height: 24
                                            radius: 6
                                            color: "#cc161616"
                                            border.color: "#80ffffff"
                                            border.width: 1
                                            visible: model.minimized === true

                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 6
                                                Kirigami.Icon {
                                                    source: "window-minimize"
                                                    implicitWidth: 14
                                                    implicitHeight: 14
                                                }
                                                Text {
                                                    id: minLabel
                                                    text: "MINIMIZED"
                                                    color: "#ffffff"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                    font.letterSpacing: 1.0
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Click on Card to Switch Window (No hover interference!)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    tabBox.model.activate(index);
                                }
                            }
                        }
                    }
                }

                /* =========================================================================
                 * BOTTOM MACOS-STYLE FLOATING TITLE & CAROUSEL PAGINATION DOCK
                 * ========================================================================= */
                ColumnLayout {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    // Active Application Name & Title Capsule (shows only when an application is active)
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 48
                        Layout.preferredWidth: Math.min(dialogMainItem.width * 0.70, titleRow.implicitWidth + 48)
                        radius: 24
                        color: "#40000000"
                        border.color: "#35ffffff"
                        border.width: 1
                        visible: dialogMainItem.currentCaption.length > 0

                        RowLayout {
                            id: titleRow
                            anchors.centerIn: parent
                            spacing: 12

                            Kirigami.Icon {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                Layout.alignment: Qt.AlignVCenter
                                source: dialogMainItem.currentIcon
                                visible: valid
                            }

                            Text {
                                Layout.maximumWidth: dialogMainItem.width * 0.55
                                text: dialogMainItem.currentCaption
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // macOS-Style Carousel Dots
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        visible: windowCount > 1

                        Repeater {
                            model: windowCount

                            delegate: Rectangle {
                                readonly property bool isActive: index === tabBox.currentIndex
                                width: isActive ? 22 : 7
                                height: 7
                                radius: 3.5
                                color: isActive ? "#ffffff" : "#40ffffff"

                                Behavior on width {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                }
                                Behavior on color {
                                    ColorAnimation { duration: 180 }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        tabBox.currentIndex = index;
                                    }
                                }
                            }
                        }
                    }

                    // Keyboard shortcuts guidance
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Tab / Arrow keys to cycle  •  Enter or Click to switch  •  Esc to cancel"
                        color: "#75ffffff"
                        font.pixelSize: 11
                    }
                }
            }

            onSceneGraphError: () => {
                // Safety guard against graphics resets
            }
        }
    }
}
