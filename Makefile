SOURCES=$(wildcard src/*.mmd)
ASSETSOURCES=$(wildcard assets/*)
PAGES=$(patsubst src/%.mmd, gear2d.com/%.html, $(SOURCES))
ASSETS=$(patsubst assets/%, gear2d.com/%, $(ASSETSOURCES))


gear2d.com: $(PAGES) $(ASSETS)
	@rm -f .temp

gear2d.com/%.html: src/%.mmd
	@mkdir -p gear2d.com
	multimarkdown $< > $@.in
	sed -e '/__CONTENT_PLACEHOLDER__/r $@.in' -e 's/__CONTENT_PLACEHOLDER__//g' src/page.html.in > $@
	rm -f $@.in
	@echo

gear2d.com/%: assets/%
	cp -r $< $@

deploy: gear2d.com
	rsync -avP --delete --exclude=api/ -e  ssh gear2d.com/ lgfreitas@web.sourceforge.net:/home/project-web/gear2d/htdocs/


.PHONY: gear2d.com deploy

