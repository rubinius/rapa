// vim: filetype=ragel

%%{

  machine pack;

  include "pack_actions.rl";

  ignored = (space | 0)*;

  count = digit >start_digit digit* @count;

  count_modifier = '*' %rest | count?;
  modifier = count_modifier | [_!] @non_native_error;
  platform_modifier = ([_!] %platform)? count_modifier;

  S = (('S' | 's') platform_modifier) %check_size %S;
  I = (('I' | 'i') platform_modifier) %check_size %I;
  L = (('L' | 'l') platform_modifier) %check_size %L;

  C = (('C' | 'c') modifier) %check_size %C;
  n = ('n' modifier) %check_size %n;
  N = ('N' modifier) %check_size %N;
  v = ('v' modifier) %check_size %v;
  V = ('V' modifier) %check_size %V;
  Q = (('Q' | 'q') modifier) %check_size %Q;

  X = ('X' modifier) %X;
  at = ('@' modifier) %at;

  A = ('A' modifier) %string_check_size %A;
  a = ('a' modifier) %string_check_size %a;
  x = ('x' modifier) %x;
  Z = ('Z' modifier) %string_check_size %Z;

  integers = C | S | I | L | n | N | v | V | Q;
  strings = A | a | x | Z;
  moves = X | at;

  directives = integers | strings | moves;

  main := (directives >start ignored)+ %done;

  write data;
  write init;
  write exec;

}%%
