// vim: filetype=ragel

%%{

  machine unpack;

  include "unpack_actions.rl";

  ignored = (space | 0)*;

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;

  C = ('C' modifier) %byte_width %set_stop %C %extra;
  c = ('c' modifier) %byte_width %set_stop %c %extra;

  numerics = C | c;

  main := (numerics >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
