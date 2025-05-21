#include "provedorimagem.h"

#include <QImageWriter>
#include <QDebug>
#include <QDir>
#include <QGuiApplication>

provedorImagem::provedorImagem() : QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage provedorImagem::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if(imagem.isNull())
    {
        qDebug() << "Erro ao prover a imagem";
        return QImage();
    }
    qDebug() << "request Image emit id= (" + this->capturedCounter;
    emit CapturedImageSignal(&this->imagem,this->capturedCounter);
    //increase caturedCounter
    this->capturedCounter++;
    return imagem;
}

void provedorImagem::carregaImagem(QImage imagemRecebida)
{
    imagem = imagemRecebida;
}
