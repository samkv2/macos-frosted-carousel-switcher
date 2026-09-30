import QtQuick
import org.kde.kwin as KWin

KWin.WindowThumbnail {
    id: thumbnailRoot
    property var windowId: undefined
    onWindowIdChanged: {
        if (windowId !== undefined && windowId !== null) {
            wId = windowId;
        }
    }
}
