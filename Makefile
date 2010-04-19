SCRIPT=plugin/Join.vim
DOC=doc/Join.txt
PLUGIN=changes

.PHONY : test


all: $(PLUGIN)

clean:
	rm -rf *.vba */*.orig *.~* .VimballRecord test/{result,expected}

dist-clean: clean

install:
	vim -u NONE -N -c':so' -c':q!' ${PLUGIN}.vba

uninstall:
	vim -u NONE -N -c':RmVimball ${PLUGIN}.vba'

undo:
	for i in */*.orig; do mv -f "$$i" "$${i%.*}"; done

test:
	( cd test; ./test.sh )

changes:
	perl -i.orig -pne 'if (/Version:/) {s/\.(\d)*/sprintf(".%d", 1+$$1)/e}' ${SCRIPT}
	perl -i -pne 'if (/GetLatestVimScripts:/) {s/(\d+)\s+:AutoInstall:/sprintf("%d :AutoInstall:", 1+$$1)/e}' ${SCRIPT}
	perl -i -pne 'if (/Last Change:/) {s/(:\s+).*$$/sprintf(": %s", `date -R`)/e}' ${SCRIPT}
	perl -i.orig -pne 'if (/Version:/) {s/\.(\d)+.*\n/sprintf(".%d %s", 1+$$1, `date -R`)/e}' ${DOC}
	vim -N -c 'ru! vimballPlugin.vim' -c ':call append("0", ["autoload/changes.vim", "doc/changesPlugin.txt", "plugin/changesPlugin.vim"])' -c '$$d' -c ':%MkVimball ${PLUGIN}' -c':q!'
