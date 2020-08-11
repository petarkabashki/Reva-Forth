ifeq ($(OS),Windows_NT)
EXE=.exe
else
EXE=
endif

REVA=bin/reva$(EXE)
BENCH=.

reva: $(REVA)

$(REVA): src/reva.f src/revacore.asm src/corewin.asm src/corelin.asm src/brieflz.asm \
	src/macros src/reva.res src/reva.ico
	@make -C src --no-print-directory

both:
	@make -C src --no-print-directory
	@make -C src --no-print-directory ../bin/reva.exe

bin/help.db: src/help.txt
	@echo Building help file
	@$(REVA) bin/genhelp.f

docs: $(REVA) bin/help.db 

clean:
	@rm -f bin/reva bin/reva.exe

realclean: clean
	@rm -f bin/revacore bin/revacore.exe
	@rm -f bin/help.db

test: $(REVA)
	@$(REVA) bin/test.f

all: docs test

dist: realclean both docs test
	@$(REVA) bin/dist.f

bench: $(REVA)
	@echo BENCH=$(BENCH)
	@(cd $(BENCH)/bench && ../$(REVA) bench.f)
	
