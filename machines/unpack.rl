// vim: filetype=ragel

%%{

  machine unpack;

  include "unpack_actions.rl";

  ignored = (space | 0)*;

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;
  platform_modifier = ([_!] %platform)? count_modifier;

  S = ('S' platform_modifier) %short_width %set_stop %S %extra;
  s = ('s' platform_modifier) %short_width %set_stop %s %extra;

  C = ('C' modifier) %byte_width %set_stop %C %extra;
  c = ('c' modifier) %byte_width %set_stop %c %extra;

  integers = C | c | S | s;

  directives = integers;

  main := (directives >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
