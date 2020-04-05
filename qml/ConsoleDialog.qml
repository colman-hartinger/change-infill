import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import Cura 1.0 as Cura

import UM 1.2 as UM

import TestPlugin 1.0 as TestPlugin

Window {
    id: consoleDialog
    title: "Test Plugin"

    color: "#DBDADA"

    TestPlugin.Interface {
        id: shell
    }

    modality: Qt.NonModal;
    flags: Qt.Window;

    width: Math.floor(screenScaleFactor * 180)
    height: Math.floor(screenScaleFactor * 200)

    minimumWidth: Math.floor(screenScaleFactor * 120)
    minimumHeight: Math.floor(screenScaleFactor * 180)

    ColumnLayout {
        UM.I18nCatalog{id: catalog; name: "test-plugin"}
        anchors.fill: parent
        anchors.margins: UM.Theme.getSize("default_margin").width

        spacing: UM.Theme.getSize("default_margin").height

        // Here we take the result of text processing
        Connections {
            target: shell

            // Signal Handler
            onTextResult: {
                // textLabel - was given through arguments=['textLabel']
                textResult.text = textLabel
            }
        }

        Column {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Binding
            {
                target: infillRowTitle
                property: "source"
                value:
                {
                    var density = parseInt(infillDensity.properties.value)
                    if (parseInt(infillSteps.properties.value) != 0)
                    {
                        return UM.Theme.getIcon("gradual")
                    }
                    if (density <= 0)
                    {
                        return UM.Theme.getIcon("hollow")
                    }
                    if (density < 40)
                    {
                        return UM.Theme.getIcon("sparse")
                    }
                    if (density < 90)
                    {
                        return UM.Theme.getIcon("dense")
                    }
                    return UM.Theme.getIcon("solid")
                }
            }
            Cura.IconWithText
            {
                id: infillRowTitle
                Layout.alignment: Qt.AlignCenter
                source: UM.Theme.getIcon("category_infill")
                text: catalog.i18nc("@label", "Infill") + " (%)"
                font: UM.Theme.getFont("medium")
                width: labelColumnWidth
            }

             Text {
                Layout.alignment: Qt.AlignCenter
                font: UM.Theme.getFont("default")
                color: "#000000"
                text: "Enter Number Between  \n0 and 100 to change infill"
            }
            TextField {
                Layout.alignment: Qt.AlignCenter
                id: login
                objectName: "login"
                placeholderText: qsTr(shell.getInfillDensity())
                focus: true
//                Layout.fillWidth: true
                onAccepted: {
                    btnSubmit.clicked()
                }
            }

            Text {
                id: textResult
                Layout.alignment: Qt.AlignCenter
                text: textResult.text
            }

            Button {
                Layout.alignment: Qt.AlignCenter
                id: btnSubmit
                objectName: "btnSubmit"
                text: qsTr("Resize Mesh")
//                Layout.fillWidth: true
                onClicked: {
                    var a = shell.setInfillDensity(login.text)
                    login.placeholderText = a
                }
            }
        }
    }
    UM.SettingPropertyProvider
    {
        id: infillDensity
        containerStackId: Cura.MachineManager.activeStackId
        key: "infill_sparse_density"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }
    UM.SettingPropertyProvider
    {
        id: infillSteps
        containerStackId: Cura.MachineManager.activeStackId
        key: "gradual_infill_steps"
        watchedProperties: ["value", "enabled"]
        storeIndex: 0
    }
}

