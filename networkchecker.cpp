#include "networkchecker.h"

NetworkChecker::NetworkChecker(QObject *parent) : QObject(parent)
{
    // Connect the finished signal to check the reply
    connect(&m_networkManager, &QNetworkAccessManager::finished, this, &NetworkChecker::onNetworkReply);
}

void NetworkChecker::checkInternetConnection()
{
    // Perform a simple network request to a reliable URL
    QNetworkRequest request(QUrl("https://www.google.com"));
    m_networkManager.get(request);
}

void NetworkChecker::onNetworkReply(QNetworkReply *reply)
{
    // Check if the request was successful
    bool isOnline = (reply->error() == QNetworkReply::NoError);
    emit networkStatusChanged(isOnline);
    reply->deleteLater();
}
