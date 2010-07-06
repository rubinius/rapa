/* This file was generated by Ragel. Your edits will be lost.
 *
 * This is a state machine implementation of Array#pack.
 *
 * vim: filetype=cpp
 */

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

#define PACK_ELEMENTS(T, coerce, format)      \
  for(; index < stop; index++) {              \
    Object* item = self->get(state, index);   \
    T* value = try_as<T>(item);               \
    if(!value) {                              \
      item = coerce(state, call_frame, item); \
      if(!item) return 0;                     \
      value = as<T>(item);                    \
    }                                         \
    str.push_back(format(value));             \
  }

#define MASK_BYTE(x) ((x)->to_native() & 0xff)

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
