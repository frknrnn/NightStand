import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../Style"
import "../Widgets/Clock"

Rectangle {
    id: clockpage
    anchors.fill: parent;
    color: UiStyle.baseColor

    enum PageType {
            Clock,
            Alarm,
            Stopwatch
        }

        QtObject {
            id: internal
            property int currentPage: ClockPage.PageType.Clock
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            SwipeView {
                id: swipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: internal.currentPage

                onCurrentIndexChanged: {
                    internal.currentPage = currentIndex
                }

                ClockView {}
                AlarmView {}
                StopWatchView {}
            }

            BottomNavigationBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                currentPage: internal.currentPage

                onPageClicked: function(pageIndex) {
                    swipeView.currentIndex = pageIndex
                }
            }
        }
}
