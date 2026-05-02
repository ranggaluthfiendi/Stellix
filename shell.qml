import Quickshell
import QtQuick
import qs.screens
import qs.services
import qs.components.widgets.systemtray
import qs.modules.bar

ShellRoot {
  Bar{}
  Screen {}
  SysTrayFocusHandler {}
  SysTrayGlobalOverlay {}
}
