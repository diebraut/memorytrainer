#ifndef ENVIRONMENT_H
#define ENVIRONMENT_H

#define DEFAULT_PACK_DIR "/excercisedata/"
#define DEFAULT_LEARNLIST_DIR "__LearnListDir"
#define DEFAULT_LEARNLIST_FILE "LearnListFile.txt"
#define DEFAULT_MIXED_PACKAGE_DIR ""  //first not in extra directory


#include <QString>

class Environment
{
public:
    Environment();
    QString    getWritableDirectionForOS();
};

#endif // ENVIRONMENT_H
