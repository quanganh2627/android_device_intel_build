MKPARTITIONFILE:= \
	$(TOP)/vendor/intel/support/partition.py \
	$(TOP)/vendor/intel/common/storage/default_partition.json \
	$(TOP)/vendor/intel/common/storage/default_mount.json \
	$(OVERRIDE_PARTITION_FILE) \
	"$(PRODUCT_OUT)" \
	"$(TARGET_DEVICE)"

partition_files:
	$(MKPARTITIONFILE)

.PHONY: partition_files
