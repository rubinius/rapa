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
  S = (('S' | 's') platform_modifier) %check_size %S;
  I = (('I' | 'i') platform_modifier) %check_size %I;
  n = ('n' modifier) %check_size %n;
  N = ('N' modifier) %check_size %N;
  v = ('v' modifier) %check_size %v;
  V = ('V' modifier) %check_size %V;

  numerics = C | S | I | n | N | v | V;

  main := (numerics >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
