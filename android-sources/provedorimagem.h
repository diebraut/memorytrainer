#ifndef PROVEDORIMAGEM_H
#define PROVEDORIMAGEM_H

#include <QObject>
#include <QImage>
#include <QQuickImageProvider>

class provedorImagem : public QQuickImageProvider
{
    Q_OBJECT

public:
    provedorImagem();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

public slots:
    void carregaImagem(QImage imagemRecebida);

private:
    QImage imagem;
    int capturedCounter=0;

signals:
    void CapturedImageSignal(QImage*,int);
};

#endif // PROVEDORIMAGEM_H
