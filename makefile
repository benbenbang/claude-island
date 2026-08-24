.EXPORT_ALL_VARIABLES:
NAME = claude-island
OUTPUT_DIR = export
ARCHIVE_PATH = $(OUTPUT_DIR)/ClaudeIsland.xcarchive
EXPORT_PATH = $(OUTPUT_DIR)/export
OUTPUT_DIR = export
APP_NAME = Claude Island.app

# Sparkle auto-update is OFF by default (the feed still points at upstream
# ClaudeIsland). Build with SPARKLE=1 to compile it in, e.g. `make build SPARKLE=1`.
SPARKLE ?= 0
ifeq ($(SPARKLE),1)
SPARKLE_FLAGS = SWIFT_ACTIVE_COMPILATION_CONDITIONS='$$(inherited) SPARKLE_ENABLED'
else
SPARKLE_FLAGS =
endif

.PHONY: build
## Build claude island (output copied to export/)
build:
	@echo "Building Claude Island... 🐙"
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild -scheme ClaudeIsland -configuration Release build $(SPARKLE_FLAGS)
	@echo "Copying app to $(OUTPUT_DIR)/ ..."
	@mkdir -p "$(OUTPUT_DIR)"
	@rm -rf "$(OUTPUT_DIR)/$(APP_NAME)"
	@cp -R "$$(find ~/Library/Developer/Xcode/DerivedData/ClaudeIsland-*/Build/Products/Release -name "$(APP_NAME)" -type d -maxdepth 1 | head -1)" "$(OUTPUT_DIR)/"
	@echo "✅ Build output: $(OUTPUT_DIR)/$(APP_NAME)"

.PHONY: run
## Build and run the app
run: build
	@echo "Launching Claude Island..."
	@open "$(OUTPUT_DIR)/$(APP_NAME)"

.PHONY: show
## Show location of built app
show:
	@echo "Built app location:"
	@if [ -d "$(OUTPUT_DIR)/$(APP_NAME)" ]; then \
		echo "$(OUTPUT_DIR)/$(APP_NAME)"; \
	else \
		echo "App not built yet. Run 'make build' first."; \
	fi

.PHONY: archive
## Create exportable app bundle in build/export/
archive:
	@echo "Creating archive for release... 📦"
	@rm -rf $(OUTPUT_DIR)
	@mkdir -p $(OUTPUT_DIR)
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild archive \
		-scheme ClaudeIsland \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		-destination "generic/platform=macOS" \
		ENABLE_HARDENED_RUNTIME=YES \
		CODE_SIGN_STYLE=Automatic $(SPARKLE_FLAGS)
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<plist version=\"1.0\">" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<dict>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<key>method</key>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<string>developer-id</string>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<key>destination</key>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<string>export</string>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<key>signingStyle</key>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<string>automatic</string>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "</dict>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "</plist>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "Exporting archive..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist $(OUTPUT_DIR)/ExportOptions.plist
	@echo ""
	@echo "✅ Archive complete!"
	@echo "📍 App location: $(EXPORT_PATH)/Claude Island.app"
	@echo ""
	@echo "Next: Run './scripts/create-release.sh' to notarize and create DMG"

.PHONY: local-archive
## Create local exportable app (no Developer ID required)
local-archive:
	@echo "Creating local archive... 📦"
	@rm -rf $(OUTPUT_DIR)
	@mkdir -p $(OUTPUT_DIR)
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild archive \
		-scheme ClaudeIsland \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		-destination "generic/platform=macOS" $(SPARKLE_FLAGS)
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<plist version=\"1.0\">" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "<dict>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<key>method</key>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<string>mac-application</string>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<key>signingStyle</key>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "	<string>automatic</string>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "</dict>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "</plist>" >> $(OUTPUT_DIR)/ExportOptions.plist
	@echo "Exporting archive..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist $(OUTPUT_DIR)/ExportOptions.plist
	@echo ""
	@echo "✅ Local archive complete!"
	@echo "📍 App location: $(EXPORT_PATH)/Claude Island.app"

.PHONY: clean
## Remove build files and caches
clean:
	@echo "Cleaning Xcode build artifacts..."
	@xcodebuild clean -scheme ClaudeIsland -configuration Release 2>/dev/null || true
	@rm -rf ~/Library/Developer/Xcode/DerivedData/ClaudeIsland-* 2>/dev/null || true
	@rm -rf $(OUTPUT_DIR) 2>/dev/null || true
	@echo "Cleaned build artifacts and caches"

.DEFAULT_GOAL := help

help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
