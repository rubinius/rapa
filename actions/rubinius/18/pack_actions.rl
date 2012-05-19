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
    stop = rest ? array_size : index + count;
    if(stop > array_size) {
      Exception::argument_error(state, "too few arguments");
    }
  }

  action string_check_size {
    if(index >= array_size) {
      Exception::argument_error(state, "too few arguments");
    }
  }

  # Integers

  action C {
    pack_byte;
  }

  action S {
    pack_short;
  }

  action I {
    pack_int;
  }

  action L {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      pack_int;
#else
      pack_long;
#endif
    } else {
      pack_int;
    }
  }

  action n {
    pack_short_be;
  }

  action N {
    pack_int_be;
  }

  action v {
    pack_short_le;
  }

  action V {
    pack_int_le;
  }

  action Q {
    pack_long;
  }

  # Moves

  action X {
    if(rest) count = 0;

    if(count > (native_int)str.size()) {
      pack18::exceeds_length_of_string(state, count);
    }

    str.resize(str.size() - count);
  }

  action x {
    if(rest) count = 0;

    str.append(count, '\0');
  }

  action at {
    if(rest) count = 1;

    if(count > (native_int)str.size()) {
      str.append(count - str.size(), '\0');
    } else {
      str.resize(count);
    }
  }

  # Strings

  action to_str_nil {
    string_value = pack18::encoding_string(state, call_frame,
        self->get(state, index++), "to_str_or_nil");
    if(!string_value) return 0;
  }

  action to_str {
    string_value = pack18::encoding_string(state, call_frame,
        self->get(state, index++), "to_str");
    if(!string_value) return 0;
  }

  action to_s {
    string_value = pack18::encoding_string(state, call_frame,
        self->get(state, index++), "to_s");
    if(!string_value) return 0;
  }

  action string_append {
    if(CBOOL(string_value->tainted_p(state))) tainted = true;
    native_int size = string_value->byte_size();
    if(rest) count = size;
    if(count <= size) {
      str.append((const char*)string_value->byte_address(), count);
      count = 0;
    } else {
      str.append((const char*)string_value->byte_address(), size);
      count = count - size;
    }
  }

  action A {
    if(count > 0) str.append(count, ' ');
  }

  action a {
    if(count > 0) str.append(count, '\0');
  }

  action Z {
    if(rest) {
      if(count == 0) str.append(1, '\0');
    } else {
      if(count > 0) str.append(count, '\0');
    }
  }

  # Others

  action P {
#if RBX_SIZEOF_LONG == 4
    str.append("\0\0\0\0", 4);
#else
    str.append("\0\0\0\0\0\0\0\0", 8);
#endif
  }

  # Encodings

  action B {
    native_int extra = pack18::bit_extra(string_value, rest, count);

    pack18::bit_high(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action b {
    native_int extra = pack18::bit_extra(string_value, rest, count);

    pack18::bit_low(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action H {
    native_int extra = pack18::hex_extra(string_value, rest, count);

    pack18::hex_high(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action h {
    native_int extra = pack18::hex_extra(string_value, rest, count);

    pack18::hex_low(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action M {
    if(rest || count < 2) count = 72;
    pack18::quotable_printable(string_value, str, count);
  }

  action b64_uu_size {
    if(rest || count < 3) {
      count = 45;
    } else {
      count = count / 3 * 3;
    }
  }

  action m {
    pack18::b64_uu_encode(string_value, str, count, pack18::b64_table, '=', false);
  }

  action U {
    pack_utf8
  }

  action u {
    pack18::b64_uu_encode(string_value, str, count, pack18::uu_table, '`', true);
  }

  action w {
    pack_ber
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
    pack18::non_native_error(state, *p);
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
