.EXPORT_ALL_VARIABLES:
NAME = claude-island
BUILD_DIR = build
ARCHIVE_PATH = $(BUILD_DIR)/ClaudeIsland.xcarchive
EXPORT_PATH = $(BUILD_DIR)/export

.PHONY: build
## Build claude island
build:
	@echo "Building Claude Island... 🐙"
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild -scheme ClaudeIsland -configuration Release build

.PHONY: run
## Build and run the app
run: build
	@echo "Launching Claude Island..."
	@open ~/Library/Developer/Xcode/DerivedData/ClaudeIsland-*/Build/Products/Release/Claude\ Island.app

.PHONY: show
## Show location of built app
show:
	@echo "Built app location:"
	@find ~/Library/Developer/Xcode/DerivedData/ClaudeIsland-*/Build/Products/Release -name "Claude Island.app" -type d -maxdepth 1 2>/dev/null || echo "App not built yet. Run 'make build' first."

.PHONY: archive
## Create exportable app bundle in build/export/
archive:
	@echo "Creating archive for release... 📦"
	@rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild archive \
		-scheme ClaudeIsland \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		-destination "generic/platform=macOS" \
		ENABLE_HARDENED_RUNTIME=YES \
		CODE_SIGN_STYLE=Automatic
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $(BUILD_DIR)/ExportOptions.plist
	@echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "<plist version=\"1.0\">" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "<dict>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<key>method</key>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<string>developer-id</string>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<key>destination</key>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<string>export</string>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<key>signingStyle</key>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<string>automatic</string>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "</dict>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "</plist>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "Exporting archive..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist $(BUILD_DIR)/ExportOptions.plist
	@echo ""
	@echo "✅ Archive complete!"
	@echo "📍 App location: $(EXPORT_PATH)/Claude Island.app"
	@echo ""
	@echo "Next: Run './scripts/create-release.sh' to notarize and create DMG"

.PHONY: local-archive
## Create local exportable app (no Developer ID required)
local-archive:
	@echo "Creating local archive... 📦"
	@rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)
	@xcodebuild -resolvePackageDependencies -scheme ClaudeIsland 2>/dev/null || true
	@xcodebuild archive \
		-scheme ClaudeIsland \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH) \
		-destination "generic/platform=macOS"
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $(BUILD_DIR)/ExportOptions.plist
	@echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "<plist version=\"1.0\">" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "<dict>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<key>method</key>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<string>mac-application</string>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<key>signingStyle</key>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "	<string>automatic</string>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "</dict>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "</plist>" >> $(BUILD_DIR)/ExportOptions.plist
	@echo "Exporting archive..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist $(BUILD_DIR)/ExportOptions.plist
	@echo ""
	@echo "✅ Local archive complete!"
	@echo "📍 App location: $(EXPORT_PATH)/Claude Island.app"

.PHONY: clean
## Remove build files and caches
clean:
	@echo "Cleaning Xcode build artifacts..."
	@xcodebuild clean -scheme ClaudeIsland -configuration Release 2>/dev/null || true
	@rm -rf ~/Library/Developer/Xcode/DerivedData/ClaudeIsland-* 2>/dev/null || true
	@rm -rf $(BUILD_DIR) 2>/dev/null || true
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
