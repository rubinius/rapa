// vim: filetype=ragel

%%{

  machine pack;

  action start {
    count = 1;
    rest = false;
    platform = false;
  }

  action start_digit {
    count = fc - '0';
  }

  action count {
    count = count * 10 + (fc - '0');
  }

  action rest {
    rest = true;
  }

  action platform {
    platform = true;
  }

  action check_size {
    stop = rest ? size() : index + count;
    if(stop > size()) {
      Exception::argument_error(state, "too few arguments");
    }
  }

  action string_check_size {
    if(index >= size()) {
      Exception::argument_error(state, "too few arguments");
    }
  }

  # Integers

  action C {
    PACK_INT_ELEMENTS(MASK_BYTE);
  }

  action S {
    PACK_INT_ELEMENTS(MASK_16BITS);
  }

  action I {
    PACK_INT_ELEMENTS(MASK_32BITS);
  }

  action L {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      PACK_INT_ELEMENTS(MASK_32BITS);
#else
      PACK_LONG_ELEMENTS(MASK_64BITS);
#endif
    } else {
      PACK_INT_ELEMENTS(MASK_32BITS);
    }
  }

  action n {
    PACK_INT_ELEMENTS(BE_MASK_16BITS);
  }

  action N {
    PACK_INT_ELEMENTS(BE_MASK_32BITS);
  }

  action v {
    PACK_INT_ELEMENTS(LE_MASK_16BITS);
  }

  action V {
    PACK_INT_ELEMENTS(LE_MASK_32BITS);
  }

  action Q {
    PACK_LONG_ELEMENTS(MASK_64BITS);
  }

  # Moves

  action X {
#define INVALID_MOVE_ERROR_SIZE 48

    if(rest) count = 0;

    if(count > str.size()) {
      char invalid_move_msg[INVALID_MOVE_ERROR_SIZE];
      snprintf(invalid_move_msg, INVALID_MOVE_ERROR_SIZE,
               "X%d exceeds length of string", (int)count);
      Exception::argument_error(state, invalid_move_msg);
    }

    str.resize(str.size() - count);
  }

  action x {
    if(rest) count = 0;

    str.append(count, '\0');
  }

  action at {
    if(rest) count = 1;

    if(count > str.size()) {
      str.append(count - str.size(), '\0');
    } else {
      str.resize(count);
    }
  }

  # Strings

  action A {
    PACK_STRING_ELEMENT("to_str_or_nil");
    if(count > 0) str.append(count, ' ');
  }

  action a {
    PACK_STRING_ELEMENT("to_str_or_nil");
    if(count > 0) str.append(count, '\0');
  }

  action Z {
    PACK_STRING_ELEMENT("to_str_or_nil");
    if(rest) {
      if(count == 0) str.append(1, '\0');
    } else {
      if(count > 0) str.append(count, '\0');
    }
  }

  # Encodings

  action B {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str_or_nil");
    if(!s) return 0;

    size_t extra = pack::bit_extra(s, rest, count);

    pack::bit_high(s, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action b {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str_or_nil");
    if(!s) return 0;

    size_t extra = pack::bit_extra(s, rest, count);

    pack::bit_low(s, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action H {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str_or_nil");
    if(!s) return 0;

    size_t extra = pack::hex_extra(s, rest, count);

    pack::hex_high(s, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action h {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str_or_nil");
    if(!s) return 0;

    size_t extra = pack::hex_extra(s, rest, count);

    pack::hex_low(s, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action M {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_s");
    if(!s) return 0;

    if(rest || count < 2) count = 72;
    pack::quotable_printable(s, str, count);
  }

  action b64_uu_size {
    if(rest || count < 3) {
      count = 45;
    } else {
      count = count / 3 * 3;
    }
  }

  action m {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str");
    if(!s) return 0;

    pack::b64_uu_encode(s, str, count, pack::b64_table, '=', false);
  }

  action u {
    String* s = pack::encoding_string(state, call_frame,
                                      self->get(state, index++), "to_str");
    if(!s) return 0;

    pack::b64_uu_encode(s, str, count, pack::uu_table, '`', true);
  }

  # Floats

  action D {
    pack_double;
  }

  action E {
    pack_double_le;
  }

  action e {
    pack_float_le;
  }

  action F {
    pack_float;
  }

  action G {
    pack_double_be;
  }

  action g {
    pack_float_be;
  }

  # Errors

  action fail {
    return force_as<String>(Primitives::failure());
  }

  action non_native_error {
#define NON_NATIVE_ERROR_SIZE 36

    char non_native_msg[NON_NATIVE_ERROR_SIZE];
    snprintf(non_native_msg, NON_NATIVE_ERROR_SIZE,
             "'%c' allowed only after types sSiIlL", *p);
    Exception::argument_error(state, non_native_msg);
  }

  action done {
    String* result = String::create(state, str.c_str(), str.size());
    if(tainted) {
      result->taint(state);
      tainted = false;
    }
    return result;
  }
}%%
