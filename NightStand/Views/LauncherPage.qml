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
    property int buttonWidth:60
    property int buttonHeight:60
    property int buttonRadius:60

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

                            width: launcherPageBase.buttonWidth
                            height: launcherPageBase.buttonHeight

                            required property string title
                            required property string pageIcon
                            required property string page
                            required property string fallback
                            required property int index

                            icon.source: UiStyle.iconPath(pageIcon)
                            icon.width: 32
                            icon.height: 32

                            background: Rectangle {
                                radius: launcherPageBase.buttonRadius
                                border.width: 1.0
                                border.color: UiStyle.headerColor
                                color: UiStyle.roundButtonColor
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
            title: qsTr("Clock")
            pageIcon: "clock"
            page: "ClockPage.qml"
            fallback: ""
        }
    }


}
