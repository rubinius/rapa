// vim: filetype=ragel

%%{

  machine unpack;

  include "unpack_actions.rl";

  count = digit >start_digit digit* @count;

  platform      = [_!];
  little_endian = '<';
  big_endian    = '>';

  count_modifier        = '*' %rest | count?;
  modifier              = count_modifier | [_!] @non_native_error;
  platform_le_modifier  = (platform little_endian) | (little_endian platform);
  platform_be_modifier  = (platform big_endian) | (big_endian platform);
  le_modifier           = little_endian | platform_le_modifier;
  be_modifier           = big_endian | platform_be_modifier;

  # Integers
  S   = ('S' platform? count_modifier) %short_width %set_stop %S %extra;
  Sl  = ('S' le_modifier count_modifier) %short_width %set_stop %Sl %extra;
  Sb  = ('S' be_modifier count_modifier) %short_width %set_stop %Sb %extra;

  s   = ('s' platform? count_modifier) %short_width %set_stop %s %extra;
  sl  = ('s' le_modifier count_modifier) %short_width %set_stop %sl %extra;
  sb  = ('s' be_modifier count_modifier) %short_width %set_stop %sb %extra;

  I   = ('I' platform? count_modifier) %int_width %set_stop %I %extra;
  Il  = ('I' le_modifier count_modifier) %int_width %set_stop %Il %extra;
  Ib  = ('I' be_modifier count_modifier) %int_width %set_stop %Ib %extra;

  i   = ('i' platform? count_modifier) %int_width %set_stop %i %extra;
  il  = ('i' le_modifier count_modifier) %int_width %set_stop %il %extra;
  ib  = ('i' be_modifier count_modifier) %int_width %set_stop %ib %extra;

  L   = ('L' count_modifier) %int_width %set_stop %L %extra;
  Lp  = ('L' platform count_modifier) %platform_width %set_stop %Lp %extra;
  Ll  = ('L' little_endian count_modifier) %int_width %set_stop %Ll %extra;
  Lb  = ('L' big_endian count_modifier) %int_width %set_stop %Lb %extra;
  Lpl = ('L' platform_le_modifier count_modifier) %platform_width %set_stop %Lpl %extra;
  Lpb = ('L' platform_be_modifier count_modifier) %platform_width %set_stop %Lpb %extra;

  l   = ('l' count_modifier) %int_width %set_stop %l %extra;
  lp  = ('l' platform count_modifier) %platform_width %set_stop %lp %extra;
  ll  = ('l' little_endian count_modifier) %int_width %set_stop %ll %extra;
  lb  = ('l' big_endian count_modifier) %int_width %set_stop %lb %extra;
  lpl = ('l' platform_le_modifier count_modifier) %platform_width %set_stop %lpl %extra;
  lpb = ('l' platform_be_modifier count_modifier) %platform_width %set_stop %lpb %extra;

  Q   = ('Q' modifier) %long_width %set_stop %Q %extra;
  Ql  = ('Q' little_endian modifier) %long_width %set_stop %Ql %extra;
  Qb  = ('Q' big_endian modifier) %long_width %set_stop %Qb %extra;

  q   = ('q' modifier) %long_width %set_stop %q %extra;
  ql  = ('q' little_endian modifier) %long_width %set_stop %ql %extra;
  qb  = ('q' big_endian modifier) %long_width %set_stop %qb %extra;

  C = ('C' modifier) %byte_width %set_stop %C %extra;
  c = ('c' modifier) %byte_width %set_stop %c %extra;
  N = ('N' modifier) %int_width %set_stop %N %extra;
  n = ('n' modifier) %short_width %set_stop %n %extra;
  V = ('V' modifier) %int_width %set_stop %V %extra;
  v = ('v' modifier) %short_width %set_stop %v %extra;

  # Floats
  D = (('D' | 'd') modifier) %long_width %set_stop %D %extra;
  E = ('E'         modifier) %long_width %set_stop %E %extra;
  e = ('e'         modifier) %int_width %set_stop %e %extra;
  F = (('F' | 'f') modifier) %int_width %set_stop %F %extra;
  G = ('G'         modifier) %long_width %set_stop %G %extra;
  g = ('g'         modifier) %int_width %set_stop %g %extra;

  # Moves
  X  = ('X' modifier) %X %check_bounds;
  x  = ('x' modifier) %x %check_bounds;
  at = ('@' >zero_count modifier) %at %check_bounds;

  # Strings
  A = ('A' modifier) %bytes %string_width %remainder %string_size %A;
  a = ('a' modifier) %bytes %string_width %remainder %string_size %a;
  Z = ('Z' modifier) %bytes %string_width %remainder %string_size %Z;

  # Others
  P = (('P' | 'p') modifier) %platform_width %set_stop %P %extra;

  # Encodings
  B = ('B' modifier) %bytes %bit_width %remainder %string_size %B %index_increment;
  b = ('b' modifier) %bytes %bit_width %remainder %string_size %b %index_increment;
  H = ('H' modifier) %bytes %hex_width %remainder %string_size %H %index_increment;
  h = ('h' modifier) %bytes %hex_width %remainder %string_size %h %index_increment;
  M = ('M' modifier) %bytes %bytes_end %remainder %M %index_increment;
  m = ('m' modifier) %bytes %bytes_end %remainder %m %index_increment;
  U = ('U' modifier) %bytes %bytes_end %remainder %rest_count %U;
  u = ('u' modifier) %bytes %bytes_end %remainder %u %index_increment;
  w = ('w' modifier) %bytes %bytes_end %remainder %rest_count %w;

  Ss = S | Sl | Sb;
  ss = s | sl | sb;
  Is = I | Il | Ib;
  is = i | il | ib;
  Ls = L | Lp | Ll | Lb | Lpl | Lpb;
  ls = l | lp | ll | lb | lpl | lpb;
  Qs = Q | Ql | Qb;
  qs = q | ql | qb;

  integers  = C | c | Ss | ss | Is | is | Ls | ls | N | n | V | v | Qs | qs;
  floats    = D | E | e | F | G | g;
  encodings = B | b | H | h | M | m | U | u | w;
  strings   = A | a | Z;
  moves     = X | x | at;
  others    = P;

  directives = integers | strings | encodings | moves | floats | others;

  main := (directives >start)* %done;

  write data nofinal noerror noprefix;
  write init;
  write exec;

}%%
