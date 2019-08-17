DIST = dist
OBJDIR = .obj
GENERATED = src/generated
ENTRYPOINT = $(OBJDIR)/entrypoint.o
C_ENTRYPOINT = src/native/entrypoint.c
JS_ENTRYPOINT = $(GENERATED)/js-entrypoint.c
NATIVE_BINDINGS = $(wildcard src/native/binding/*.c)
BIN = $(DIST)/app

.PHONY: all
all: clean prod

.PHONY: clean
clean:
	-@$(RM) -rf $(DIST) $(OBJDIR) $(GENERATED)

.PHONY: prod
prod: dev
	cp -R dev/gawain.app $(DIST)/gawain.app
	@mkdir -p $(DIST)/gawain.app/Contents/MacOS
	cp $(BIN) $(DIST)/gawain.app/Contents/MacOS/app

.PHONY: dev
dev: $(BIN)

$(BIN): $(ENTRYPOINT) $(patsubst src/native/binding/%.c, $(OBJDIR)/%.o, $(NATIVE_BINDINGS))
	@mkdir -p $(DIST)
	$(CC) `sdl2-config --static-libs` -L/usr/local/lib/quickjs -lquickjs -o $@ $^

$(ENTRYPOINT): $(JS_ENTRYPOINT) $(C_ENTRYPOINT)
	@mkdir -p $(OBJDIR)
	$(CC) `sdl2-config --cflags` -I/usr/local/include/quickjs -c -o $@ $(C_ENTRYPOINT)

$(OBJDIR)/%.o: src/native/binding/%.c
	@mkdir -p $(OBJDIR)
	$(CC) `sdl2-config --cflags` -I/usr/local/include/quickjs -c -o $@ $<

$(JS_ENTRYPOINT): src/entrypoint.js
	@mkdir -p $(GENERATED)
	qjsc -c -m -M sdl.so,sdl -o $@ src/entrypoint.js
