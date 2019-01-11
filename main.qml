import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3

/**
  * A QML Application that opens up a Canvas for drawing with a mouse
  * and saves the Canvas as an image file on local disc and loads file back up
  *
  * @author Shraddha Sainath
  */

Window {
    //set Window properties for toolbar and Canvas
    id: root
    visible: true
    width: 500
    height: 500
    title: qsTr("Canvas")

    //path URL where Canvas is saved/loaded as an image file (currently set for Windows10 OS)
    property string saveUrl: "/C:/Users/ssainath/Documents/CanvasDrawing/images/testsave.png"
    property string loadUrl: "file:///C:/Users/ssainath/Documents/CanvasDrawing/images/testsave.png"

    Row {
        //set properties for toolbar with Menu-Buttons and Dialog Boxes
        id: tools
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: clear
            text: "Clear"
            onClicked: {
                canvas.clear();
            }
        }

        Button {
            id: save
            text: "Save"
            onClicked: {
                if(canvas.save(saveUrl)) { //push to stack
                    msg.title = "Save Dialog Box"
                    msg.text = "Canvas Saved Successfully"
                    msg.visible = true
                }
                else {
                    msg.title = "Save"
                    msg.text = "Failed to Save. Modify saveURL/loadURL path"
                    msg.visible = true
                }
            }
        }

        Button {
            id: load
            text: "Load Image"
            onClicked: {
                img.visible = true
                img.source
            }
        }

        Button {
            id: exit
            text: "Exit"
            onClicked: {
                Qt.quit();
            }
        }

        MessageDialog {
            id: msg
            onAccepted: visible = false
        }
    }

    Canvas {
        //set properties for Canvas
        //Qt Documentation: Canvas QML Type
        id: canvas
        anchors.top: tools.bottom
        width: 500
        height: 500

        //tracks the position of the mouse cursor
        property int prevX: 0
        property int prevY: 0

        //function to clear the canvas
        function clear() {
            img.visible = false
            var ctx = getContext("2d")
            ctx.reset()
            canvas.requestPaint()
        }

        onPaint: {
            //Provides 2D context for shapes on a Canvas item
            //Qt Documentation: Context2d QML Type
            var ctx = canvas.getContext("2d")
            ctx.lineWidth = 5
            ctx.strokeStyle = "red"

            //resets current path to a new path
            ctx.beginPath()

            //move to the last known position of MouseArea
            //starts at (0,0) by default
            ctx.moveTo(prevX, prevY)

            //set prevX and prevY
            prevX = area.mouseX
            prevY = area.mouseY
            ctx.lineTo(prevX, prevY)

            //put brush/mouse to canvas and roll the paint
            ctx.stroke()

        }

        MouseArea {
            //Tracks the mouse cursor
            //Qt Documentation: MouseArea QML Type
            id: area
            anchors.fill: parent

            //code commented below is for drawing by hovering mouse on Canvas instead of clicking
            /*hoverEnabled: true
            onEntered: {
                canvas.prevX = mouseX
                canvas.prevY = mouseY
            }*/

            //drawing on Canvas only when mouse is clicked
            onPressed: {
                //set the poistion of the cursor
                canvas.prevX = mouseX
                canvas.prevY = mouseY
            }

            onPositionChanged: {
                //determines if anything changed on canvas area when mouse moves
                //requestpaint function is called every time mouse moves over canvas and nothing's changed
                //requests that Canvas is repainted
                canvas.requestPaint()
            }
        }

        Image {
            //Qt Documentation: Image QML Type
            id: img
            visible: false
            cache: false

            Timer {
                //Set a timer to refresh/reload the saved image file in real-time every 1 second
                //so that it always loads the most recently saved Canvas
                //Qt Documentation: Timer QML Type
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    img.source = ""
                    img.source = loadUrl
                }
            }
        }
    }
}
