# Define publish target for windows tools
PUBLISH_PATH:= $(TOP)/pub
PUBLISH_TOOLS_PATH := $(abspath $(PUBLISH_PATH)/tools/)
PUBLISH_WINDOWS_TOOLS_deps := \
	$(HOST_OUT_EXECUTABLES)/adb.exe \
	$(HOST_OUT_EXECUTABLES)/AdbWinUsbApi.dll \
	$(HOST_OUT_EXECUTABLES)/AdbWinApi.dll \
	$(HOST_OUT_EXECUTABLES)/fastboot.exe
publish_windows_tools: $(PUBLISH_WINDOWS_TOOLS_deps)
	@ echo "Publish windows tools"
	@ mkdir -p $(PUBLISH_TOOLS_PATH)
	(cd out/host/ && cp --parents windows-x86/bin/adb.exe $(PUBLISH_TOOLS_PATH))
	(cd out/host/ && cp --parents windows-x86/bin/AdbWinUsbApi.dll $(PUBLISH_TOOLS_PATH))
	(cd out/host/ && cp --parents windows-x86/bin/AdbWinApi.dll $(PUBLISH_TOOLS_PATH))
	(cd out/host/ && cp --parents windows-x86/bin/fastboot.exe $(PUBLISH_TOOLS_PATH))
