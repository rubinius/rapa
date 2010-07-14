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
    PACK_ELEMENTS(Integer, pack::integer, MASK_BYTE);
  }

  action I {
    PACK_ELEMENTS(Integer, pack::integer, MASK_32BITS);
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
