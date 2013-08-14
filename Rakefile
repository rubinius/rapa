DIR       = File.expand_path "../", __FILE__
if dir = ENV["DIR"]
  OUT_DIR = File.expand_path ENV["DIR"]
else
  OUT_DIR = File.expand_path "../", __FILE__
end

def machines(version)
  DIR + "/machines/#{version}"
end

def rubinius(version)
  DIR + "/actions/rubinius/#{version}"
end

def rubinius_ragel(version)
  "ragel -C -F0 -I #{machines(version)} -I #{rubinius(version)}"
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
    task :pack do
      ["18", "21"].each do |version|
        input  = "#{rubinius(version)}/pack_code.rl"
        output = "#{OUT_DIR}/vm/modes/#{version}/pack.cpp"

        sh "#{rubinius_ragel(version)} -o #{output} #{input}"
        remove_line_references output, "vm/modes/#{version}/pack.cpp"
      end
    end

    task :unpack do
      ["18", "21"].each do |version|
        input  = "#{rubinius(version)}/unpack_code.rl"
        output = "#{OUT_DIR}/vm/modes/#{version}/unpack.cpp"

        sh "#{rubinius_ragel(version)} -o #{output} #{input}"
        remove_line_references output, "vm/modes/#{version}/unpack.cpp"
      end
    end
  end
end
