import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../../Style"

Item {
    id: root

    // 1.0 = full ring (just started), 0.0 = empty (expired)
    property real progress: 0.0
    property string timeText: "00:00"
    property string captionText: ""
    property bool showsHours: false
    property color trackColor: UiStyle.roundButtonColor
    property color progressColor: UiStyle.headerColor
    property bool dimmed: false
    property bool pulsing: false

    readonly property real diameter: Math.max(0, Math.min(width, height) - 8)
    readonly property int strokeW: 22
    readonly property real ringRadius: Math.max(1, diameter / 2 - strokeW / 2 - 2)

    Shape {
        id: ringShape

        anchors.centerIn: parent
        width: root.diameter
        height: root.diameter

        // Qt 6.6+ GPU curve rasteriser: analytic AA on the arc without
        // layer.enabled/layer.samples MSAA, which would resolve an FBO every
        // frame for a shape that changes 20 times a second.
        preferredRendererType: Shape.CurveRenderer

        opacity: root.dimmed ? 0.45 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        // Track - full circle
        ShapePath {
            strokeColor: root.trackColor
            strokeWidth: root.strokeW
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            Behavior on strokeColor {
                ColorAnimation { duration: 250 }
            }

            PathAngleArc {
                centerX: ringShape.width / 2
                centerY: ringShape.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90      // 0 deg = 3 o'clock, so -90 = 12 o'clock
                sweepAngle: 360      // positive sweep = clockwise in y-down coords
                moveToStart: true
            }
        }

        // Progress - depletes clockwise from 12 o'clock
        ShapePath {
            // A zero-length round-capped subpath renders as a dot, so hide it
            strokeColor: root.progress > 0.0005 ? root.progressColor : "transparent"
            strokeWidth: root.strokeW
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            Behavior on strokeColor {
                ColorAnimation { duration: 250 }
            }

            PathAngleArc {
                centerX: ringShape.width / 2
                centerY: ringShape.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90
                // No Behavior here: the source already updates at 20 Hz and
                // animating it would retriangulate the arc every frame.
                sweepAngle: Math.max(0, Math.min(360, root.progress * 360))
                moveToStart: true
            }
        }
    }

    ColumnLayout {
        id: centerColumn

        anchors.centerIn: parent
        spacing: 4

        // Plain value, not a binding, so animating it destroys nothing
        opacity: 1.0

        SequentialAnimation on opacity {
            running: root.pulsing
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 450; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 450; easing.type: Easing.InOutQuad }
            onRunningChanged: if (!running) centerColumn.opacity = 1.0
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.timeText
            font.family: "Consolas, Menlo, Monaco, monospace"
            font.pixelSize: Math.round(root.diameter * (root.showsHours ? 0.15 : 0.23))
            font.bold: true
            color: UiStyle.textColor
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: root.captionText.length > 0
            text: root.captionText
            font.pixelSize: 18
            color: UiStyle.subtextColor
        }
    }
}
