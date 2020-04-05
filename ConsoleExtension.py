from UM.i18n import i18nCatalog
from UM.PluginRegistry import PluginRegistry
from UM.Signal import Signal, signalemitter
from cura.CuraApplication import CuraApplication
from UM.Extension import Extension
from UM.Scene.Selection import Selection
from UM.Math.Vector import Vector

i18n_catalog = i18nCatalog("test-plugin")

import os
from PyQt5.QtCore import pyqtSlot, QObject, pyqtSignal
from PyQt5.QtQml import qmlRegisterType
from random import randint


def resize(num):
    selected_nodes = Selection.getAllSelectedObjects()
    for node in selected_nodes:
        node.scale(Vector(num, num, num))


class Interface(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.extruders = CuraApplication.getInstance().getMachineManager().activeMachine.extruderList
        self.infill = self.extruders[0].getProperty("infill_sparse_density", "value")

    textResult = pyqtSignal(str, arguments=['textLabel'])
    valueChanged = Signal()

    def random(self):
        self.textResult.emit(str(randint(0, 1000)))

    def infillChanged(self, key: str, property_name: str) -> str:
        if property_name == "value":
            if key == "infill_sparse_density":
                self.valueChanged.emit()
                if self.infill > self.extruders[0].getProperty("infill_sparse_density", "value"):
                    resize(.5)
                    self.infill = self.extruders[0].getProperty("infill_sparse_density", "value")
                else:
                    resize(2)
                    self.infill = self.extruders[0].getProperty("infill_sparse_density", "value")
                return self.random()

    @pyqtSlot(result=str)
    def getInfillDensity(self) -> str:
        a = self.extruders[0].propertyChanged.connect(self.infillChanged)
        return str(self.extruders[0].getProperty("infill_sparse_density", "value"))

    @pyqtSlot(int, result=str)
    def setInfillDensity(self, num) -> str:
        for extruder in self.extruders:
            extruder.setProperty("infill_sparse_density", "value", num)
            # a = self.extruders[0].propertyChanged.emit("infill_sparse_density", "value")
        return str(extruder.getProperty("infill_sparse_density", "value"))


class ConsoleExtension(Extension):
    def __init__(self):
        super().__init__()
        self._console_window = None
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Open in New Window"), self._openConsoleDialog)
        self._preferenceOpenConsoleOnStartup = "open_console_on_startup"
        self._startup_script = ""

    def applicationInitialized(self):
        preferences = CuraApplication.getInstance().getPreferences()
        open_console = preferences.getValue(self._preferenceOpenConsoleOnStartup)

        if isinstance(open_console, bool):
            if open_console:
                self._openConsoleDialog()
        else:
            if open_console == 'dialog':
                self._openConsoleDialog()

    def _createQmlDialog(self, dialog_qml, vars=None):
        directory = PluginRegistry.getInstance().getPluginPath(self.getPluginId())

        mainApp = CuraApplication.getInstance()

        return mainApp.createQmlComponent(os.path.join(directory, "qml", dialog_qml), vars)

    def _openConsoleDialog(self):
        if not self._console_window:
            self._console_window = self._createQmlDialog(
                "ConsoleDialog.qml",
                {"startupScript": self._startup_script}
            )
        self._console_window.show()


def registerQmlTypes():
    directory = os.path.dirname(os.path.abspath(__file__))

    qmlRegisterType(Interface, "TestPlugin",1, 0,"Interface")
