SITE=gear2d.com
SOURCES=$(sort $(wildcard src/*.mmd))
ASSETSOURCES=$(wildcard assets/*)
PAGES=$(patsubst src/%.mmd, $(SITE)/%.html, $(SOURCES))
ASSETS=$(patsubst assets/%, $(SITE)/%, $(ASSETSOURCES))

$(SITE): setup openindex $(PAGES) $(ASSETS) closeindex
	sed -i -e '/__PAGE_INDEX_PLACEHOLDER__/r .temp/pageidx.html' -e 's/__PAGE_INDEX_PLACEHOLDER__//g' $(wildcard $(SITE)/*.html)
	rm -rf .temp

$(SITE)/%.html: src/%.mmd
	mkdir -p gear2d.com
	multimarkdown $< > $@.in
	sed -e '/__CONTENT_PLACEHOLDER__/r $@.in' -e 's/__CONTENT_PLACEHOLDER__//g' src/page.html.in > $(SITE)/$(shell echo $@ | sed -e 's/$(SITE)\/.*-//g')
	echo '  <li><a href="$(shell echo $(subst $(SITE)/,,$@) | sed -e 's/.*-//g')">$(strip $(shell head -1 $<))</a></li>' >> .temp/pageidx.html
	rm -f $@.in
	echo

$(SITE)/%: assets/%
	cp -r $< $@

setup:
	rm -rf .temp
	mkdir -p .temp

openindex:
	echo '<ul>' >> .temp/pageidx.html

closeindex:
	echo '</ul>' >> .temp/pageidx.html

deploy: $(SITE)
	rsync -avP --delete --exclude=api/ -e  ssh gear2d.com/ lgfreitas@web.sourceforge.net:/home/project-web/gear2d/htdocs/


.PHONY: gear2d.com deploy openindex

