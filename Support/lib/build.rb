require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/save_current_document"
require 'shellwords'
require 'json'
require 'cgi'
require 'pathname'

def find_cargo_toml
  candidates = [File.join(ENV['TM_PROJECT_DIRECTORY'], 'Cargo.toml')]

  dir = ENV['TM_DIRECTORY']
  while dir && dir != ENV['TM_PROJECT_DIRECTORY'] && dir != '/'
    candidates << File.join(dir, 'Cargo.toml')
    dir = File.dirname(dir)
  end

  candidates.find { |path| path && File.file?(path) }
end

def cargo_home
  ENV.fetch('CARGO_HOME', File.join(ENV['HOME'], '.cargo'))
end

def cargo_name
  ENV.fetch('TM_CARGO_NAME', 'cargo')
end

def cargo_params
  ENV.key?('TM_CARGO_PARAMS') ? ENV['TM_CARGO_PARAMS'].split(' ') : []
end

def get_cargo_bin
  paths_to_cargo = [
    ENV['TM_CARGO'].to_s,
    File.join(cargo_home, 'bin', 'cargo'),
    `which cargo`.chomp
  ].reject(&:empty?)

  path_to_cargo = paths_to_cargo.find {|path| File.exists?(path) }

  if path_to_cargo.nil?
    paths_to_sentence =
      case paths_to_cargo.size
      when 0
        ""
      when 1
        paths_to_cargo[0]
      else
        paths_to_cargo[0..-2].join(", ") + " or " + paths_to_cargo[-1]
      end
      1
    puts "Error: Cannot find cargo at #{paths_to_sentence}. Check that cargo is \
    installed and in your PATH or that TM_CARGO points to the right location or that \
    CARGO_HOME is set and points to the right location."
    exit
  end

  path_to_cargo
end

# Try to use cargo metadata to find the workspace
# root for resolving relative paths in error messages.
# Fall back to TM_PROJECT_DIRECTORY if that attempt
# fails for any reason.
def get_workspace_root(path_to_cargo, cargo_home)
  workspace_root = nil
  begin
    metadata_json = nil
    IO.popen([path_to_cargo, "metadata", "--no-deps", "--format-version", "1", :err => [:child, :out]]) { |ls_io|
      metadata_json = ls_io.read
    }
    metadata = JSON.parse(metadata_json)
    workspace_root = metadata["workspace_root"]
  rescue
    workspace_root = ENV['TM_PROJECT_DIRECTORY']
  end
  workspace_root
end

def run_cargo(cmd, use_extra_args = false, use_nightly = false)
  default_dir = 'src'
  additional_flags = []
  path_to_cargo = get_cargo_bin

  if current_file = ENV['TM_FILEPATH']
    case File.basename(File.dirname(current_file))
    when 'examples'
      default_dir = 'examples'
      additional_flags = ['--example', File.basename(current_file, '.rs')] if use_extra_args
    when 'bin'
      default_dir = 'src/bin'
      additional_flags = ['--bin', File.basename(current_file, '.rs')] if use_extra_args
    else
    end
  end

  TextMate.save_if_untitled('rs')
  TextMate::Executor.make_project_master_current_document
  TextMate::HTMLOutput.show(:title => "Cargo #{cmd.capitalize}") do |io|
    io.puts '<pre>'

    workspace_root = get_workspace_root(path_to_cargo, cargo_home)

    cargo_toml = find_cargo_toml

    if cargo_toml.nil?
      io.puts "No Cargo.toml found."
      next
    end

    cargo_args = cargo_params
    if use_nightly
      cargo_args.insert(0, "+nightly")
    end

    args = [path_to_cargo, *cargo_args, cmd, *additional_flags, "--manifest-path", cargo_toml]

    io.puts args.join(' ')

    patch_warning_emitted = false

    TextMate::Process.run(args, :chdir => File.dirname(cargo_toml)) do |str, type|
      if str =~ /--> (.*):(\d+):(\d+)/
        file_ref = Pathname.new($1)
        unless file_ref.absolute?
          if file_ref.dirname == Pathname.new('.')
            file_ref = File.join(workspace_root, default_dir, file_ref)
          else
            file_ref = File.join(workspace_root, file_ref)
          end
        end
        io.puts "<a href=\"txmt://open/?url=file://#{file_ref}&line=#{$2}&column=#{$3}\">#{str}</a>"
      elsif str =~ /error\[(E\d\d\d\d)\]/
        io.puts "<a href=\"https://doc.rust-lang.org/error-index.html\##{$1}\" target=\"_blank\">#{str}</a>"
      elsif str =~ /was not used in the crate graph/
        unless patch_warning_emitted
          io.puts "[Individual patch warnings suppressed]"
          patch_warning_emitted = true
        end
      else
        io.puts str
      end
    end

    io.puts '</pre>'
  end
end

def run_cargo_fmt()
  path_to_cargo = get_cargo_bin
  workspace_root = get_workspace_root(path_to_cargo, cargo_home)

  cargo_toml = find_cargo_toml

  if cargo_toml.nil?
    puts "No Cargo.toml found."
    exit 1
  end

  Dir.chdir(workspace_root) do
    system(path_to_cargo, "fmt")
  end
end
