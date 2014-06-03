# Find all ifwi selected through PRODUCT_PACKAGES
# Define capsule and dediprog target to be used by json file to generate
# blankphone and flashfiles.

INTERNAL_FIRMWARE_FILES := $(filter $(PRODUCT_OUT)/ifwi/%, \
       $(ALL_PREBUILT) \
       $(ALL_COPIED_HEADERS) \
       $(ALL_GENERATED_SOURCES) \
       $(ALL_DEFAULT_INSTALLED_MODULES))

# dediprogs are in $(PRODUCT_OUT)/ifwi/PACKAGE_NAME/dediprog/
INSTALLED_DEDIPROG_TARGET := $(strip $(foreach fw,$(INTERNAL_FIRMWARE_FILES),\
    $(if $(filter %/dediprog/,$(dir $(fw))),$(fw))))
INSTALLED_CAPSULE_TARGET := $(strip $(foreach fw,$(INTERNAL_FIRMWARE_FILES),\
    $(if $(filter %/capsule/,$(dir $(fw))),$(fw))))
INSTALLED_STAGE2_TARGET := $(strip $(foreach fw,$(INTERNAL_FIRMWARE_FILES),\
    $(if $(filter %/stage2/,$(dir $(fw))),$(fw))))
