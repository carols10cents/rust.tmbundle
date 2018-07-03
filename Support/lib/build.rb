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

def run_cargo(cmd, use_extra_args = false)
  default_dir = 'src'
  additional_flags = []

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

    path_to_cargo = File.join(cargo_home, 'bin', cargo_name)

    unless File.exist? path_to_cargo
      io.puts "Error: Cannot find cargo at #{path_to_cargo}. Check that cargo is \
  installed and that the CARGO_HOME environmental variable is either unset or points \
  to the right location."
      next
    end

    cargo_toml = find_cargo_toml

    if cargo_toml.nil?
      io.puts "No Cargo.toml found."
      next
    end

    args = [path_to_cargo, *cargo_params, cmd, *additional_flags, "--manifest-path", cargo_toml]

    io.puts args.join(' ')

    TextMate::Process.run(args, :chdir => File.dirname(cargo_toml)) do |str, type|
      if str =~ /--> (.*):(\d+):(\d+)/
        file_ref = Pathname.new($1)
        unless file_ref.absolute?
          if file_ref.dirname == Pathname.new('.')
            file_ref = File.join(File.dirname(cargo_toml), default_dir, file_ref)
          else
            file_ref = File.join(File.dirname(cargo_toml), file_ref)
          end
        end
        io.puts "<a href=\"txmt://open/?url=file://#{file_ref}&line=#{$2}&column=#{$3}\">#{str}</a>"
      elsif str =~ /error\[(E\d\d\d\d)\]/
        io.puts "<a href=\"https://doc.rust-lang.org/error-index.html\##{$1}\" target=\"_blank\">#{str}</a>"
      else
        io.puts str
      end
    end

    io.puts '</pre>'
  end
end
