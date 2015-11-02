BUILD_NAME=MapMaker

# List of files to compile. End filenames
# with a backslash to escape line breaks
FILES=\
	main.lua\
	button.lua\
	textbox.lua\
	settingsdialog.lua\
	tooltip.lua\
	toast.lua\
	clickhandler.lua\
	mapeditor.lua\
	pathchecker.lua\
	mapexporter.lua\
	icon.png\

BUILD_DIR=/home/$(USER)/LoveReleases

all:
	love-release -L -r $(BUILD_DIR) $(FILES)

clean:
	rm -rf $(BUILD_DIR)/$(BUILD_NAME).love
