/* This file was generated by Ragel. Your edits will be lost.
 *
 * This is a state machine implementation of Array#pack.
 *
 * vim: filetype=cpp
 */

#include "vm/config.h"

#include "vm.hpp"
#include "object_utils.hpp"
#include "on_stack.hpp"

#include "builtin/array.hpp"
#include "builtin/exception.hpp"
#include "builtin/module.hpp"
#include "builtin/object.hpp"
#include "builtin/string.hpp"

namespace rubinius {
  namespace pack {
    static Object* integer(STATE, CallFrame* call_frame, Object* obj) {
      Array* args = Array::create(state, 1);
      args->set(state, 0, obj);

      return G(rubinius)->send(state, call_frame, state->symbol("pack_to_int"), args);
    }
  }

#define PACK_INT_ELEMENTS(mask)   PACK_ELEMENTS(Integer, pack::integer, INT, mask)

#define PACK_ELEMENTS(T, coerce, size, format)  \
  for(; index < stop; index++) {                \
    Object* item = self->get(state, index);     \
    T* value = try_as<T>(item);                 \
    if(!value) {                                \
      item = coerce(state, call_frame, item);   \
      if(!item) return 0;                       \
      value = as<T>(item);                      \
    }                                           \
    CONVERT_TO_ ## size(value);                 \
    format;                                     \
  }

#define CONVERT_TO_INT(n)                   \
  if((n)->fixnum_p()) {                     \
    int_value = (int)STRIP_FIXNUM_TAG(n);   \
  } else {                                  \
    int_value = as<Bignum>(n)->to_int();    \
  }

#define BYTE1(x)        ((x) & 0x000000ff)
#define BYTE2(x)        (((x) & 0x0000ff00) >> 8)
#define BYTE3(x)        (((x) & 0x00ff0000) >> 16)
#define BYTE4(x)        (((x) & 0xff000000) >> 24)

#ifdef RBX_LITTLE_ENDIAN
# define MASK_16BITS     LE_MASK_16BITS
# define MASK_32BITS     LE_MASK_32BITS
#else
# define MASK_16BITS     BE_MASK_16BITS
# define MASK_32BITS     BE_MASK_32BITS
#endif

#define LE_MASK_32BITS             \
  str.push_back(BYTE1(int_value)); \
  str.push_back(BYTE2(int_value)); \
  str.push_back(BYTE3(int_value)); \
  str.push_back(BYTE4(int_value)); \

#define BE_MASK_32BITS             \
  str.push_back(BYTE4(int_value)); \
  str.push_back(BYTE3(int_value)); \
  str.push_back(BYTE2(int_value)); \
  str.push_back(BYTE1(int_value)); \

#define LE_MASK_16BITS             \
  str.push_back(BYTE1(int_value)); \
  str.push_back(BYTE2(int_value)); \

#define BE_MASK_16BITS             \
  str.push_back(BYTE2(int_value)); \
  str.push_back(BYTE1(int_value)); \

#define MASK_BYTE    str.push_back(BYTE1(int_value))

  String* Array::pack(STATE, String* directives, CallFrame* call_frame) {
    // Ragel-specific variables
    std::string d(directives->c_str(), directives->size());
    const char *p  = d.c_str();
    const char *pe = p + d.size();
    const char *eof = pe;
    int cs;

    // pack-specific variables
    Array* self = this;
    OnStack<1> sv(state, self);

    size_t index = 0;
    size_t count = 0;
    size_t stop = 0;
    bool rest = false;
    bool platform = false;

    int int_value = 0;
    std::string str("");

%%{

  machine pack;

  include "pack.rl";

}%%

    if(pack_first_final && pack_error && pack_en_main) {
      // do nothing
    }

    return force_as<String>(Primitives::failure());
  }
}
