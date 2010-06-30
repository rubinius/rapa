// vim: filetype=ragel

%%{

  machine pack;

  include "pack_actions.rl";

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;

  C = (('C' | 'c') modifier) %check_size %C;

  main := (C >start space*)+ %done;

  write data;
  write init;
  write exec;

}%%
