# DisplaySleep - Caffeinate-style Menu Bar App for macOS
# Build automation following modern Swift & Apple Developer standards

APP_NAME = DisplaySleep
BUNDLE_DIR = build/$(APP_NAME).app
CONTENTS_DIR = $(BUNDLE_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

SWIFT_SOURCES = \
	Sources/Services/PowerService.swift \
	Sources/Services/ClamshellWatcher.swift \
	Sources/Models/DisplaySleepState.swift \
	Sources/Views/Components/GlassCard.swift \
	Sources/Views/Components/StatusBadge.swift \
	Sources/Views/HeaderView.swift \
	Sources/Views/HeroSleepButton.swift \
	Sources/Views/TimerPresetsView.swift \
	Sources/Views/ActiveTimerView.swift \
	Sources/Views/SettingsSectionView.swift \
	Sources/Views/ContentView.swift \
	Sources/App.swift

SWIFTC_FLAGS = -O -whole-module-optimization -parse-as-library

.PHONY: all build run stop install uninstall clean help

all: build

help:
	@echo "Comandos disponíveis:"
	@echo "  make build      - Compila o binário e gera o pacote DisplaySleep.app"
	@echo "  make run        - Executa o DisplaySleep na Menu Bar"
	@echo "  make stop       - Encerra qualquer instância em execução do DisplaySleep"
	@echo "  make install    - Instala DisplaySleep.app em ~/Applications"
	@echo "  make uninstall  - Remove DisplaySleep.app de ~/Applications"
	@echo "  make clean      - Limpa os artefatos de build"

build: $(BUNDLE_DIR)

$(BUNDLE_DIR): $(SWIFT_SOURCES) Info.plist Resources/AppIcon.icns
	@echo "🔨 Compilando $(APP_NAME) com swiftc..."
	@mkdir -p $(MACOS_DIR) $(RESOURCES_DIR)
	@swiftc $(SWIFTC_FLAGS) $(SWIFT_SOURCES) -o $(MACOS_DIR)/$(APP_NAME)
	@cp Info.plist $(CONTENTS_DIR)/Info.plist
	@cp Resources/AppIcon.icns $(RESOURCES_DIR)/AppIcon.icns
	@echo "✅ Pacote $(BUNDLE_DIR) construído com sucesso!"

run: build
	@echo "🚀 Iniciando $(APP_NAME)..."
	@-pkill -x $(APP_NAME) 2>/dev/null || true
	@open $(BUNDLE_DIR)
	@echo "✨ $(APP_NAME) está rodando na Menu Bar!"

stop:
	@echo "🛑 Encerrando $(APP_NAME)..."
	@-pkill -x $(APP_NAME) 2>/dev/null || true
	@echo "Concluído."

install: build
	@echo "📦 Instalando em ~/Applications..."
	@mkdir -p ~/Applications
	@rm -rf ~/Applications/$(APP_NAME).app
	@cp -R $(BUNDLE_DIR) ~/Applications/
	@echo "🎉 $(APP_NAME).app instalado em ~/Applications com sucesso!"

uninstall:
	@echo "🗑️ Desinstalando de ~/Applications..."
	@-pkill -x $(APP_NAME) 2>/dev/null || true
	@rm -rf ~/Applications/$(APP_NAME).app
	@echo "Concluído."

clean:
	@echo "🧹 Limpando diretório de build..."
	@rm -rf build
	@echo "Concluído."
