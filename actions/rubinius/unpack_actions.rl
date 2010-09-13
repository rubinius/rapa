// vim: filetype=ragel

%%{

  machine unpack;

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
    count = 0;
    rest = true;
  }

  action zero_count {
    count = 0;
  }

  action platform {
    platform = true;
  }

  action byte_width {
    width = 1;
  }

  action short_width {
    width = 2;
  }

  action int_width {
    width = 4;
  }

  action long_width {
    width = 8;
  }

  action platform_width {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      width = 4;
#else
      width = 8;
#endif
    } else {
      width = 4;
    }
  }

  action set_stop {
    stop = rest ? bytes_size + 1 : index + width * count;
    if(stop > bytes_size) {
      stop = index + ((bytes_size - index) / width) * width;
    }
  }

  action extra {
    for(; count > 0; count--) {
      array->append(state, Qnil);
    }
  }

  # Integers

  action C {
    UNPACK_ELEMENTS(FIXNUM, UBYTE);
  }

  action c {
    UNPACK_ELEMENTS(FIXNUM, SBYTE);
  }

  action S {
    UNPACK_ELEMENTS(FIXNUM, U16BITS);
  }

  action s {
    UNPACK_ELEMENTS(FIXNUM, S16BITS);
  }

  action I {
    UNPACK_ELEMENTS(INTEGER, U32BITS);
  }

  action i {
    UNPACK_ELEMENTS(INTEGER, S32BITS);
  }

  action L {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      UNPACK_ELEMENTS(INTEGER, U32BITS);
#else
      UNPACK_ELEMENTS(INTEGER, U64BITS);
#endif
    } else {
      UNPACK_ELEMENTS(INTEGER, U32BITS);
    }
  }

  action l {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      UNPACK_ELEMENTS(INTEGER, S32BITS);
#else
      UNPACK_ELEMENTS(INTEGER, S64BITS);
#endif
    } else {
      UNPACK_ELEMENTS(INTEGER, S32BITS);
    }
  }

  action N {
    UNPACK_ELEMENTS(INTEGER, BE_U32BITS);
  }

  action n {
    UNPACK_ELEMENTS(FIXNUM, BE_U16BITS);
  }

  action V {
    UNPACK_ELEMENTS(INTEGER, LE_U32BITS);
  }

  action v {
    UNPACK_ELEMENTS(FIXNUM, LE_U16BITS);
  }

  action Q {
    UNPACK_ELEMENTS(INTEGER, U64BITS);
  }

  action q {
    UNPACK_ELEMENTS(INTEGER, S64BITS);
  }

  # Floats

  action D {
    unpack_double;
  }

  action E {
    unpack_double_le;
  }

  action e {
    unpack_float_le;
  }

  action F {
    unpack_float;
  }

  action G {
    unpack_double_be;
  }

  action g {
    unpack_float_be;
  }

  # Moves

  action X {
    if(rest) count = bytes_size - index;
    index -= count;
  }

  action x {
    if(rest) {
      index = bytes_size;
    } else {
      index += count;
    }
  }

  action at {
    if(!rest) {
      index = count;
    }
  }

  action check_bounds {
#define OOB_ERROR_SIZE 20

    if(index < 0 || index > bytes_size) {
      char oob_error_msg[OOB_ERROR_SIZE];
      snprintf(oob_error_msg, OOB_ERROR_SIZE,
               "%c outside of string", *p);
      Exception::argument_error(state, oob_error_msg);
    }
  }

  # String / Encoding helpers

  action byte_address {
    bytes = (const char*)self->byte_address() + index;
  }

  action string_width {
    width = 1;
  }

  action bit_width {
    width = 8;
  }

  action hex_width {
    width = 2;
  }

  action remainder {
    remainder = bytes_size - index;
  }

  action string_size {
    if(rest || count > remainder * width) {
      count = remainder * width;
    }
  }

  # Strings

  action A {
    String* string;

    if(count > 0) {
      size_t i;
      for(i = count; i > 0; i--) {
        uint8_t c = bytes[i-1];
        if(c != ' ' && c != '\0')
          break;
      }
      string = String::create(state, bytes, i);
    } else {
      string = String::create(state, "");
    }

    array->append(state, string);
    unpack::increment(index, count, bytes_size);
  }

  action a {
    array->append(state, String::create(state, bytes, count));

    unpack::increment(index, count, bytes_size);
  }

  action Z {
    size_t c;
    for(c = 0; c < count; c++) {
      if(bytes[c] == '\0') break;
    }
    array->append(state, String::create(state, bytes, c));

    if(rest) {
      unpack::increment(index, c < count ? c + 1 : count, bytes_size);
    } else {
      unpack::increment(index, count, bytes_size);
    }
  }

  # Encodings

  action index_increment {
    unpack::increment(index,
                      bytes - ((const char*)self->byte_address() + index),
                      bytes_size);
  }

  action B {
    array->append(state, unpack::bit_high(state, bytes, count));
  }

  action b {
    array->append(state, unpack::bit_low(state, bytes, count));
  }

  action H {
    array->append(state, unpack::hex_high(state, bytes, count));
  }

  action h {
    array->append(state, unpack::hex_low(state, bytes, count));
  }

  action M {
    array->append(state, unpack::quotable_printable(state, bytes, remainder));
  }

  action m {
    array->append(state, unpack::base64_decode(state, bytes, remainder));
  }

  action u {
    array->append(state, unpack::uu_decode(state, bytes, remainder));
  }

  action non_native_error {
#define NON_NATIVE_ERROR_SIZE 36

    char non_native_msg[NON_NATIVE_ERROR_SIZE];
    snprintf(non_native_msg, NON_NATIVE_ERROR_SIZE,
             "'%c' allowed only after types sSiIlL", *p);
    Exception::argument_error(state, non_native_msg);
  }

  action done {
    return array;
  }
}%%
