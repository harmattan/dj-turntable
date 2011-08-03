QT += core gui declarative opengl

TEMPLATE = app
TARGET = turntable
VERSION = 1.3.1

SOURCES += \
    main.cpp \
    DrumMachine.cpp \
    mainwindow.cpp \
    TurnTable.cpp \
    ga_src/GEAudioBuffer.cpp \
    ga_src/GEInterfaces.cpp \
    ga_src/GEAudioOut.cpp

OTHER_FILES += \
    qml/*.qml \
    qml/DrumMachine/*.qml \
    qml/HelpScreen/*.qml \
    qml/SampleSelector/*.qml

RESOURCES += turntable.qrc

HEADERS += \
    DrumMachine.h \
    mainwindow.h \
    TurnTable.h \
    ga_src/GEAudioOut.h \
    ga_src/GEInterfaces.h \
    ga_src/GEAudioBuffer.h


win32:!maemo5 {
    TARGET = DjTurntable
    QT += multimedia
    RC_FILE = turntable.rc
}


# Maemo 5 and Harmattan
unix:!symbian {
    # Common
    BINDIR    = /opt/usr/bin
    DATADIR   = /usr/share

    DEFINES  += DATADIR=\\\"$$DATADIR\\\" \
                PKGDATADIR=\\\"$$PKGDATADIR\\\"

    target.path = $$BINDIR

    iconxpm.path = $$DATADIR/pixmap
    iconxpm.files += icons/xpm/turntable.xpm

    icon26.path = $$DATADIR/icons/hicolor/26x26/apps
    icon26.files += icons/26x26/turntable.png

    icon40.path = $$DATADIR/icons/hicolor/40x40/apps
    icon40.files += icons/40x40/turntable.png

    icon64.path = $$DATADIR/icons/hicolor/64x64/apps
    icon64.files += icons/64x64/turntable.png

    maemo5 {
        # Maemo 5 specific
        QT        += multimedia
        CONFIG    += mobility
        MOBILITY  += sensors systeminfo

        HEADERS   += accelerometerfilter.h
        OTHER_FILES += qtc_packaging/debian_fremantle/*

        desktop.path = $$DATADIR/applications/hildon
        desktop.files += qtc_packaging/debian_fremantle/$${TARGET}.desktop
    }
    else {
        # Harmattan specific
        DEFINES += Q_WS_MAEMO_6

        CONFIG += mobility
        MOBILITY += sensors systeminfo multimedia

        HEADERS += accelerometerfilter.h
        OTHER_FILES += qtc_packaging/debian_harmattan/*

        desktop.path = $$DATADIR/applications
        desktop.files += qtc_packaging/debian_harmattan/$${TARGET}.desktop

        gameclassify.path = /usr/share/policy/etc/syspart.conf.d
        gameclassify.files += qtc_packaging/debian_harmattan/$${TARGET}.conf

        INSTALLS += gameclassify
    }

    INSTALLS += target \
                desktop \
                iconxpm \
                icon26 \
                icon40 \
                icon64
}


symbian {
    QT += multimedia

    TARGET = DjTurntable
    CONFIG += mobility
    MOBILITY += sensors systeminfo

    HEADERS += accelerometerfilter.h

    !contains(SYMBIAN_VERSION, Symbian3) {
        message(Symbian^1)

        DEFINES += Q_OS_SYMBIAN_1

        # In Symbian^1 we don't have OpenGL available
        QT -= opengl
        DEFINES += QT_NO_OPENGL
    }
    else {
        message(Symbian^3)

        # Enable the volume hack
        DEFINES += ENABLE_VOLUME_HACK

        # To handle volume up / down keys on Symbian
        LIBS += -lremconcoreapi
        LIBS += -lremconinterfacebase
    }

    contains(DEFINES, ENABLE_VOLUME_HACK) {
        # For the very ugly hack to make the master volume control possible
        INCLUDEPATH += /epoc32/include/mmf/common
        INCLUDEPATH += /epoc32/include/mmf/server
        LIBS += -lmmfdevsound
    }

    # For the icon
    ICON = icons/turntable.svg

    # To lock the application to landscape orientation
    LIBS += -lcone -leikcore -lavkon

    TARGET.EPOCHEAPSIZE = 0x100000 0x2000000
    TARGET.EPOCSTACKSIZE = 0x14000
}
