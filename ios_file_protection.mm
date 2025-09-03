#include "ios_file_protection.h"
#include <QDir>
#include <QFileInfo>

#ifdef Q_OS_IOS
#import <Foundation/Foundation.h>
static void setNoProtectionAtPath(const QString &path) {
    @autoreleasepool {
        NSString *p = [NSString stringWithUTF8String:path.toUtf8().constData()];
        NSDictionary *attrs = @{ NSFileProtectionKey: NSFileProtectionNone };
        [[NSFileManager defaultManager] setAttributes:attrs ofItemAtPath:p error:nil];
    }
}
#endif

void iosSetNoProtection(const QString &path) {
#ifdef Q_OS_IOS
    setNoProtectionAtPath(path);
#else
    Q_UNUSED(path);
#endif
}

void iosSetNoProtectionTree(const QString &rootPath) {
#ifdef Q_OS_IOS
    QDir root(rootPath);
    if (!root.exists()) return;

    // Root selbst
    setNoProtectionAtPath(root.absolutePath());

    // rekursiv
    QList<QDir> stack{root};
    while (!stack.isEmpty()) {
        QDir dir = stack.takeLast();
        const auto entries = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
        for (const QFileInfo &fi : entries) {
            setNoProtectionAtPath(fi.absoluteFilePath());
            if (fi.isDir())
                stack.append(QDir(fi.absoluteFilePath()));
        }
    }
#else
    Q_UNUSED(rootPath);
#endif
}
