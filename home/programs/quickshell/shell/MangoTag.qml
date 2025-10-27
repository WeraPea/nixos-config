import QtQuick

QtObject {
  property int index
  property bool visible // TODO: improve the naming of visible and selected
  property int clients
  property bool selected // true when the current selected client is of this tag
  property bool urgent
}
