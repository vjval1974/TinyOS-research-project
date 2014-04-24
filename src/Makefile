COMPONENT=TestC
PFLAGS += -I/opt/tinyos-2.1.2/tos/lib/net/tymo -I/opt/tinyos-2.1.2/tos/lib/net/tymo/dymo -I/opt/tinyos-2.1.2/tos/lib/net/tymo/mh
DOCDIR=~/tymo/web/html-doc/
BUILD_EXTRA_DEPS+=TymoTestMsg.class
include $(MAKERULES)
TymoTestMsg.class: TymoTestMsg.java
	javac TymoTestMsg.java

TymoTestMsg.java: 
	mig java -target=null -java-classname=TymoTestMsg rssimessage.h RssiMsg -o $@

CLEAN_EXTRA=*.class TymoTestMsg.java
