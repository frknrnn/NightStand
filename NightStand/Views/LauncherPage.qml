import QtQuick
import QtQuick.Controls as QQC2
pragma ComponentBehavior: Bound
import "../Style"
import "../Views/Pages"

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
            Dashboard{

            }
        }
        Rectangle{
            id:bottomMenu
            color:UiStyle.baseColor
            anchors.bottom :parent.bottom
            anchors.left : parent.left
            anchors.right : parent.right
            anchors.leftMargin : 30
            anchors.rightMargin: 30
            anchors.bottomMargin: 5
            height: parent.height * 0.15
            Rectangle{
                anchors.fill:parent
                anchors.topMargin : 5
                anchors.bottomMargin: 5
                radius: 10
                color: UiStyle.cardPanelColor
                Row {
                    id: launcherPage
                    anchors.centerIn :parent
                    spacing: 15
                    Repeater{
                        model: buttonModel
                        delegate: QQC2.RoundButton {

                                width: bottomMenu.width / 8
                                height: bottomMenu.height * 0.5

                                required property string title
                                required property string pageIcon
                                required property string page
                                required property string fallback
                                required property int index

                                background: Rectangle {
                                    radius: parent.width / 10
                                    border.width: 1.0
                                    border.color: UiStyle.menuTextColor
                                    color: UiStyle.menuButtonBackground
                                }

                                contentItem: Column {
                                spacing: 4
                                anchors.centerIn: parent

                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: bottomMenu.height * 0.3
                                    height: bottomMenu.height * 0.3
                                    source: UiStyle.iconPath(pageIcon)
                                    fillMode: Image.PreserveAspectFit
                                }

                                QQC2.Label{
                                    text: title
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: UiStyle.basicTextColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                }

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
            title: qsTr("XYZ")
            pageIcon: "stage3d"
            page: "FirstStageControlPage.qml"
            fallback: ""
        }
    }


}
