DIR       = File.expand_path "../", __FILE__
if dir = ENV["DIR"]
  OUT_DIR = File.expand_path ENV["DIR"]
else
  OUT_DIR = File.expand_path "../", __FILE__
end

def rubinius_ragel
  "ragel -C -F0 -I #{DIR}/machines -I #{DIR}/actions/rubinius"
end

# The Ragel generated line info is a mess. This just strips the
# info so that any compile errors are reported directly from the
# generated code. This may be confusing. Other solutions welcome.
# BTW, the -L option just puts the #line directives into comments,
# which just clutters the generated code needlessly.
def remove_line_references(name, file)
  source = IO.readlines name
  source.reject! { |line| line =~ /^#line\s(\d+)\s"[^"]+"/ }
  File.open(name, "w") { |f| f.puts source }
end

namespace :build do
  desc "Generate Array#pack, String#unpack primitives for Rubinius"
  task :rbx => ["rbx:pack", "rbx:unpack"]

  namespace :rbx do
    desc "Generate Array#pack primitives for Rubinius"
    task :pack do
      input  = "#{DIR}/actions/rubinius/pack_code.rl"
      output = "#{OUT_DIR}/machine/builtin/pack.cpp"

      sh "#{rubinius_ragel} -o #{output} #{input}"
      remove_line_references output, "machine/builtin/pack.cpp"
    end

    desc "Generate String#unpack primitives for Rubinius"
    task :unpack do
      input  = "#{DIR}/actions/rubinius/unpack_code.rl"
      output = "#{OUT_DIR}/machine/builtin/unpack.cpp"

      sh "#{rubinius_ragel} -o #{output} #{input}"
      remove_line_references output, "machine/builtin/unpack.cpp"
    end
  end
end
