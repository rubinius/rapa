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

  action platform {
    platform = true;
  }

  action byte_width {
    width = 1;
  }

  action short_width {
    width = 2;
  }

  action set_stop {
    stop = rest ? size() + 1 : index + width * count;
    if(stop > size()) {
      stop = index + ((size() - index) / width) * width;
    }
  }

  action extra {
    while(count > 0) {
      array->append(state, Qnil);
      count--;
    }
  }

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
