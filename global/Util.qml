import QtQuick 2.0

Item {
    id:utilID

    function ifMobile () {
        if (Qt.platform.os == "android") {
            console.log("android");
            return true;
        }
        if (Qt.platform.os == "ios") {
             return true;
        }
        return false;
    }
}
