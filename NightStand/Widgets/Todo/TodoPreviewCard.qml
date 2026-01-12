import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../Style"

Item {
    id: root
    
    property int currentIndex: 0
    property int displayInterval: 10000 // 10 seconds
    
    // Get pending todo count from viewmodel
    readonly property int pendingCount: todoViewModel ? todoViewModel.getPendingTodoCount() : 0
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "📋 Pending Tasks"
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.subtextColor
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 50
                height: 24
                color: UiStyle.roundButtonColor
                radius: 12
                
                Text {
                    anchors.centerIn: parent
                    text: pendingCount.toString()
                    font.pixelSize: 12
                    font.bold: true
                    color: UiStyle.headerColor
                }
            }
        }
        
        Item { Layout.fillHeight: true }
        
        // Todo display area with animation
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            
            // Current todo text
            Text {
                id: todoText
                anchors.centerIn: parent
                width: parent.width
                
                text: {
                    if (pendingCount === 0) {
                        return "✨ All tasks completed!"
                    }
                    var title = todoViewModel ? todoViewModel.getPendingTodoTitle(currentIndex) : ""
                    return title || "No tasks"
                }
                
                font.pixelSize: pendingCount > 0 ? 24 : 20
                font.bold: true
                color: UiStyle.textColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                
                // Fade animation
                opacity: 1
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
        
        // Progress indicator (dots)
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            visible: pendingCount > 1
            
            Repeater {
                model: Math.min(pendingCount, 5) // Max 5 dots
                
                Rectangle {
                    width: index === (currentIndex % Math.min(pendingCount, 5)) ? 12 : 8
                    height: index === (currentIndex % Math.min(pendingCount, 5)) ? 12 : 8
                    radius: width / 2
                    color: index === (currentIndex % Math.min(pendingCount, 5)) 
                           ? UiStyle.headerColor 
                           : UiStyle.roundButtonColor
                    
                    Behavior on width {
                        NumberAnimation { duration: 200 }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
            
            // Show "..." if more than 5 todos
            Text {
                visible: pendingCount > 5
                text: "..."
                font.pixelSize: 12
                color: UiStyle.subtextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Footer info
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: pendingCount > 0 
                      ? (currentIndex + 1) + " / " + pendingCount 
                      : ""
                font.pixelSize: 14
                color: UiStyle.subtextColor
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "View All →"
                font.pixelSize: 14
                color: UiStyle.headerColor
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Navigate to todo page - can be connected later
                        console.log("Navigate to Todo page")
                    }
                }
            }
        }
    }
    
    // Timer for cycling through todos
    Timer {
        id: cycleTimer
        interval: displayInterval
        running: pendingCount > 1
        repeat: true
        
        onTriggered: {
            // Fade out
            todoText.opacity = 0
            
            // Change index after fade out
            fadeTimer.start()
        }
    }
    
    // Timer to change text after fade out
    Timer {
        id: fadeTimer
        interval: 500
        repeat: false
        
        onTriggered: {
            // Move to next todo
            if (pendingCount > 0) {
                currentIndex = (currentIndex + 1) % pendingCount
            }
            // Fade in
            todoText.opacity = 1
        }
    }
    
    // Reset index when pending count changes
    onPendingCountChanged: {
        if (currentIndex >= pendingCount && pendingCount > 0) {
            currentIndex = 0
        }
        todoText.opacity = 1
    }
    
    // Initial state
    Component.onCompleted: {
        currentIndex = 0
    }
}
