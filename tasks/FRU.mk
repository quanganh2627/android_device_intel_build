AOBS_JSON := $(call get-specific-config-file ,scale/aobs.json)
CONFIGS_JSON := $(call get-specific-config-file ,scale/configs.json)
FRU_CONFIGS := $(PRODUCT_OUT)/fru_configs.xml

build_fru:
	$(TOP)/vendor/intel/support/generate_fru.py \
	$(AOBS_JSON) \
	$(CONFIGS_JSON) \
	$(FRU_CONFIGS)

