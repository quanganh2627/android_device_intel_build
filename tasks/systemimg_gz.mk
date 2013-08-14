INSTALLED_SYSTEMIMG_GZ_TARGET := $(PRODUCT_OUT)/system.img.gz

$(INSTALLED_SYSTEMIMG_GZ_TARGET) : $(INSTALLED_SYSTEMIMAGE) | $(MINIGZIP)
	@echo "Generate system.img.gz"
	$(MINIGZIP) <$? >$@

.PHONY: systemimg_gz
systemimg_gz: $(INSTALLED_SYSTEMIMG_GZ_TARGET)

