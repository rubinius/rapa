// vim: filetype=ragel

%%{

  machine pack;

  include "pack_actions.rl";

  ignored = (space | 0)*;

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;

  C = (('C' | 'c') modifier) %check_size %C;

  main := (C >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
