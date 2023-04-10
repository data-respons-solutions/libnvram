BUILD ?= build
CFLAGS += -Wall -Wextra -Werror -std=gnu11 -pedantic
ifeq ($(LIBNVRAM_USE_SANITIZER), 1)
	CFLAGS += -fsanitize=address -fsanitize=undefined
	LDFLAGS += -fsanitize=address -fsanitize=undefined
endif
CLANG_TIDY_CHECKS_LIST = -*
CLANG_TIDY_CHECKS_LIST += clang-analyzer-*
CLANG_TIDY_CHECKS_LIST += bugprone-*
CLANG_TIDY_CHECKS_LIST += cppcoreguidelines-*
CLANG_TIDY_CHECKS_LIST += portability-*
CLANG_TIDY_CHECKS_LIST += readability-*
CLANG_TIDY_CHECKS_LIST += -readability-braces-around-statements
#CLANG_TIDY_CHECKS_LIST += -readability-function-cognitive-complexity
#CLANG_TIDY_CHECKS_LIST += -cppcoreguidelines-avoid-non-const-global-variables
CLANG_TIDY_CHECKS_LIST += -clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling
CLANG_TIDY_CHECKS_LIST += -cppcoreguidelines-avoid-magic-numbers,-readability-magic-numbers
space := $() $()
comma := ,
CLANG_TIDY_CHECKS ?= $(subst $(space),$(comma),$(CLANG_TIDY_CHECKS_LIST))

ifeq ($(abspath $(BUILD)),$(shell pwd)) 
$(error "ERROR: Build dir can't be equal to source dir")
endif

all: libnvram

.PHONY: libnvram
libnvram: $(BUILD)/libnvram.a

$(BUILD)/libnvram.a: $(addprefix $(BUILD)/, crc32.o libnvram.o)
	$(AR) rcs $@ $^

$(BUILD)/test-core: $(addprefix $(BUILD)/, test-core.o libnvram.a test-common.o)
	$(CC) -o $@ $^ $(LDFLAGS)
	
$(BUILD)/test-libnvram-list: $(addprefix $(BUILD)/, test-libnvram-list.o libnvram.a test-common.o)
	$(CC) -o $@ $^ $(LDFLAGS)
	
$(BUILD)/test-transactional: $(addprefix $(BUILD)/, test-transactional.o libnvram.a test-common.o)
	$(CC) -o $@ $^ $(LDFLAGS)
	
$(BUILD)/test-crc32: $(addprefix $(BUILD)/, test-crc32.o crc32.o test-common.o)
	$(CC) -o $@ $^ $(LDFLAGS)
   
$(BUILD)/%.o: %.c 
ifeq ($(LIBNVRAM_CLANG_TIDY), 1)
	clang-tidy $< -header-filter=.* \
		-checks=$(CLANG_TIDY_CHECKS) -- $<
endif
	mkdir -p $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: test
test: $(addprefix $(BUILD)/, test-core test-libnvram-list test-transactional test-crc32)
	for test in $^; do \
		echo "Running: $${test}"; \
		if ! ./$${test}; then \
			exit 1; \
		fi \
	done

.PHONY: clean
clean:
	rm -rf $(BUILD)