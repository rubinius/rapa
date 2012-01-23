// vim: filetype=ragel

%%{

  machine pack;

  action start {
    count = 1;
    rest = false;
    platform = false;
    byte_order = 0;
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

  action big_endian {
    byte_order = 1;
  }

  action little_endian {
    byte_order = 2;
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
    switch (byte_order) {
    case 1:
      pack_short_be;
    case 2:
      pack_short_le;
    default:
      pack_short;
    }
  }

  action I {
    switch (byte_order) {
    case 1:
      pack_int_be;
    case 2:
      pack_int_le;
    default:
      pack_int;
    }
  }

  action L {
    if(platform) {
#if RBX_SIZEOF_LONG == 4
      switch (byte_order) {
      case 1:
        pack_int_be;
      case 2:
        pack_int_le;
      default:
        pack_int;
      }
#else
      switch (byte_order) {
      case 1:
        pack_long_be;
      case 2:
        pack_long_le;
      default:
        pack_long;
      }
#endif
    } else {
      switch (byte_order) {
      case 1:
        pack_int_be;
      case 2:
        pack_int_le;
      default:
        pack_int;
      }
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
      switch (byte_order) {
      case 1:
        pack_long_be;
      case 2:
        pack_long_le;
      default:
        pack_long;
      }
  }

  # Moves

  action X {
    if(rest) count = 0;

    if(count > (native_int)str.size()) {
      std::ostringstream msg;
      msg << "X" << count << " exceeds length of string";
      Exception::argument_error(state, msg.str().c_str());
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
    string_value = pack19::encoding_string(state, call_frame,
        self->get(state, index++), "to_str_or_nil");
    if(!string_value) return 0;
  }

  action to_str {
    string_value = pack19::encoding_string(state, call_frame,
        self->get(state, index++), "to_str");
    if(!string_value) return 0;
  }

  action to_s {
    string_value = pack19::encoding_string(state, call_frame,
        self->get(state, index++), "to_s");
    if(!string_value) return 0;
  }

  action string_append {
    if(CBOOL(string_value->tainted_p(state))) tainted = true;
    if(CBOOL(string_value->untrusted_p(state))) untrusted = true;
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
    string_encoding = true;
    if(count > 0) str.append(count, ' ');
  }

  action a {
    string_encoding = true;
    if(count > 0) str.append(count, '\0');
  }

  action Z {
    string_encoding = true;
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
    native_int extra = pack19::bit_extra(string_value, rest, count);

    pack19::bit_high(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action b {
    native_int extra = pack19::bit_extra(string_value, rest, count);

    pack19::bit_low(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action H {
    native_int extra = pack19::hex_extra(string_value, rest, count);

    pack19::hex_high(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action h {
    native_int extra = pack19::hex_extra(string_value, rest, count);

    pack19::hex_low(string_value, str, count);
    if(extra > 0) str.append(extra, '\0');
  }

  action M {
    ascii_encoding = true;
    if(rest || count < 2) count = 72;
    pack19::quotable_printable(string_value, str, count);
  }

  action b64_uu_size {
    count_flag = count;
    if(rest || count < 3) {
      count = 45;
    } else {
      count = count / 3 * 3;
    }
  }

  action m {
    ascii_encoding = true;
    pack19::b64_uu_encode(string_value, str, count, count_flag, pack19::b64_table, '=', false);
  }

  action U {
    utf8_encoding = true;
    pack_utf8
  }

  action u {
    ascii_encoding = true;
    pack19::b64_uu_encode(string_value, str, count, count_flag, pack19::uu_table, '`', true);
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
    std::ostringstream msg;
    msg << "'" << *p << "' allowed only after types sSiIlL";
    Exception::argument_error(state, msg.str().c_str());
  }

  action byte_order_error {
    std::ostringstream msg;
    msg << "'" << *p << "' allowed only after types sSiIlLqQ";
    Exception::argument_error(state, msg.str().c_str());
  }

  action done {
    String* result = String::create(state, str.c_str(), str.size());

    if(str.size() > 0) {
      if(utf8_encoding) {
        result->encoding(state, Encoding::utf8_encoding(state));
      } else if(string_encoding) {
        // TODO
      } else if(!ascii_encoding) {
        result->encoding(state, Encoding::ascii8bit_encoding(state));
      }
    }

    if(tainted) {
      result->taint(state);
      tainted = false;
    }

    if(untrusted) {
      result->untrust(state);
      untrusted = false;
    }

    return result;
  }
}%%
