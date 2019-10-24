#ifndef _LIBNVRAM_H_
#define _LIBNVRAM_H_

#include <stdint.h>
#include <inttypes.h>
#include "crc32.h"

/*
 * Serialized data is stored on nvram in two separate sections where section format is:
 *
 * counter|len|crc32|serialized_data
 *
 * uint32_t counter = Counter iterated for each write
 * uint32_t len = Length of serialized data
 * uint32_t crc32 = crc32 for serialized data
 * uint8_t[] data = serialized data
 */

// Parsed nvram data stored as linked nodes
struct nvram_node {
	char* key;
	char* value;
	struct nvram_node* next;
};

#define NVRAM_LIST_INITIALIZER {NULL}

struct nvram_list {
	struct nvram_node* entry;
};

/*
 * Set value for key in list
 *
 * @params
 *   list: list containing entries
 *   key: key of entry
 *   value: value of entry
 *
 * @returns
 *   0 for success
 *   negative errno for error
 */

int nvram_list_set(struct nvram_list* list, const char* key, const char* value);

/*
 * Get value with key from list
 *
 * @params
 *   list: list containing entries
 *   key: key of entry
 *
 * @returns
 *   Pointer to char string in list
 *   NULL if not found
 */
char* nvram_list_get(const struct nvram_list* list, const char* key);

/*
 * Remove value with key from list
 *
 * @params
 * 	list: list containing entries
 *  key: key of entry
 *
 * @returns
 * 1 if removed, 0 if not found
 */

int nvram_list_remove(struct nvram_list* list, const char* key);

/*
 * Destroy nvram list
 *
 * @params
 *   list: list to destroy
 */
void destroy_nvram_list(struct nvram_list* list);

/*
 * Verify buffer contains valid nvram section
 *
 * @params
 *   data: data buffer
 *   max_len: Length of buffer
 *   data_len: returns length of serialized data
 *   counter: returns nvram section header counter
 *
 * @returns
 *   0 for invalid, 1 for valid
 */
int is_valid_nvram_section(const uint8_t* data, uint32_t len, uint32_t* data_len, uint32_t* counter);

/*
 * Create nodes from serialized data buffer.
 * This function expects nvram section is valid.
 *
 * @params
 *  list: returns list with entries (Resource should be released with destroy_nvram_node() by caller)
 *  data: data buffer
 *  len:  data buffer length
 *
 * @returns
 *  0 for success
 *  Negative errno for error
 */
int nvram_section_deserialize(struct nvram_list* list, const uint8_t* data, uint32_t len);

/*
 * Create serialized data buffer from nodes
 *
 * @params
 *  list: list with entries
 *  counter: Value of counter to insert into section header
 *  data: Returned data buffer
 *  len:  Returned data buffer length
 *
 * @returns
 *  0 for success
 *  Negative errno for error
 */
int nvram_section_serialize(const struct nvram_list* list, uint32_t counter, uint8_t** data, uint32_t* len);

#endif // _LIBNVRAM_H_
