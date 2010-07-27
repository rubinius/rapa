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

  action X {
#define INVALID_MOVE_ERROR_SIZE 48

    if(rest) count = 0;

    if(count > str.size()) {
      char invalid_move_msg[INVALID_MOVE_ERROR_SIZE];
      snprintf(invalid_move_msg, INVALID_MOVE_ERROR_SIZE,
               "X%d exceeds length of string", (int)count);
      Exception::argument_error(state, invalid_move_msg);
    }

    str = str.substr(0, str.size() - count);
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
      str = str.substr(0, count);
    }
  }

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
    return String::create(state, str.c_str(), str.size());
  }
}%%
