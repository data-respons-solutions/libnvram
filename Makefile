
PREFIX ?= /usr/local

CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Werror
CFLAGS += -std=gnu11
CFLAGS += -pedantic

all: libnvram.a

libnvram.a: crc32.o libnvram.o 
	$(AR) rcs $@ $^

test-core: test-core.o libnvram.a test-common.o
	$(CC) -o $@ $^ $(LDFLAGS)
	
test-nvram-list: test-nvram-list.o libnvram.a test-common.o
	$(CC) -o $@ $^ $(LDFLAGS)
	
test-transactional: test-transactional.o libnvram.a test-common.o
	$(CC) -o $@ $^ $(LDFLAGS)
	
test-crc32: test-crc32.o crc32.o test-common.o
	$(CC) -o $@ $^ $(LDFLAGS)
   
.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: test
test: test-core test-nvram-list test-transactional test-crc32
	for test in $^; do \
		echo "Running: $${test}"; \
		if ! ./$${test}; then \
			exit 1; \
		fi \
	done

.PHONY: clean
clean:
	rm -f crc32.o
	rm -f libnvram.o
	rm -f libnvram.a
	rm -f test-core test-core.o
	rm -f test-nvram-list test-nvram-list.o
	rm -f test-transactional test-transactional.o
	rm -f test-crc32 test-crc32.o
