import QtQuick 2.9

Item {
    id: box
    property string borderColor: "green"
    property int borderWidth: 5
    property double textWidthFactor: 1.0


    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = canvas.getContext('2d')

            ctx.strokeStyle = box.borderColor
            ctx.lineWidth = box.borderWidth
            ctx.beginPath()
            ctx.moveTo(width*textWidthFactor, 0)
            ctx.lineTo(0, 0)
            ctx.lineTo(0, height)
            ctx.lineTo(width, height)
            ctx.lineTo(width, 0)
            ctx.lineTo(width - width * textWidthFactor, 0)
            ctx.stroke()
        }
    }
}
