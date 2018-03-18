PACKAGE  = redis_proxy
GOPATH   = $(CURDIR)/.gopath
BASE     = $(GOPATH)/src/$(PACKAGE)

$(BASE):
    @mkdir -p $(dir $@)
    @ln -sf $(CURDIR) $@
