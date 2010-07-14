// vim: filetype=ragel

%%{

  machine pack;

  include "pack_actions.rl";

  ignored = (space | 0)*;

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;
  platform_modifier = [_!]? %platform count_modifier;

  C = (('C' | 'c') modifier) %check_size %C;
  I = (('I' | 'i') platform_modifier) %check_size %I;

  numerics = C | I;

  main := (numerics >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
