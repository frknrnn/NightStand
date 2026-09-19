import QtQuick
import QtQuick.Controls as QQC2
pragma ComponentBehavior: Bound
                          import "../Style"
import "../Views/Pages"
import "../Widgets/Buttons"

Rectangle{
    id:launcherPageBase
    anchors.fill : parent
    signal launched(string title, string page, string fallbackpage)
    color:UiStyle.baseColor

    Column{
        anchors.fill:parent
        spacing:0
        Rectangle {
            color:UiStyle.baseColor
            anchors.bottom : bottomMenu.top
            anchors.top:parent.top
            anchors.left : parent.left
            anchors.right : parent.right
            Dashboard {
                onOpenPage: (title, page) => launcherPageBase.launched(title, page, page)
            }
        }
        Rectangle{
            id:bottomMenu
            color:UiStyle.baseColor
            anchors.bottom :parent.bottom
            anchors.left : parent.left
            anchors.right : parent.right
            anchors.leftMargin : 24
            anchors.rightMargin: 24
            anchors.bottomMargin: 5
            height: parent.height * 0.15
            Rectangle{
                anchors.fill:parent
                anchors.topMargin : 5
                anchors.bottomMargin: 5
                radius: 16
                color: UiStyle.cardPanelColor
                Row {
                    id: launcherPage
                    anchors.centerIn :parent
                    spacing: 20
                    Repeater{
                        model: buttonModel
                        delegate: LauncherMenuButton {
                            required property string title
                            required property string pageIcon
                            required property string page
                            required property string fallback
                            required property int index

                            iconSource: UiStyle.iconPath(pageIcon)

                            onClicked: {
                                launcherPageBase.launched(title, Qt.resolvedUrl(page), Qt.resolvedUrl(fallback))
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id:buttonModel
        ListElement {
            title: qsTr("Clock")
            pageIcon: "clock"
            page: "ClockPage.qml"
            fallback: ""
        }
        
        ListElement {
            title: qsTr("To Do")
            pageIcon: "todo"
            page: "TodoPage.qml"
            fallback: ""
        }
        
        ListElement {
            title: qsTr("Album")
            pageIcon: "album"
            page: "AlbumPage.qml"
            fallback: ""
        }
        
        ListElement {
            title: qsTr("Robot")
            pageIcon: "robot"
            page: "RobotPage.qml"
            fallback: ""
        }

        ListElement {
            title: qsTr("Settings")
            pageIcon: "settings"
            page: "Settings.qml"
            fallback: ""
        }

    }


}
