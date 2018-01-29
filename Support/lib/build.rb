require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/save_current_document"
require "shellwords"
require "json"
require 'cgi'
require 'pathname'


def show_output(io, str)
  io.puts("#{str}")
end

def run_cargo(cmd, use_extra_args = false)
  additional_flags = []
  default_dir = "src"
  current_file_name = ENV['TM_FILEPATH'] || ""
  current_file_name_without_extension = File.basename(current_file_name, ".rs")
  current_file_dir = File.dirname(current_file_name)
  current_file_dirname = File.basename(current_file_dir)
  if current_file_dirname == "examples"
    default_dir = "examples"
    additional_flags = ["--example", current_file_name_without_extension] if use_extra_args
  elsif current_file_dirname == "bin"
    default_dir = "src/bin"
    additional_flags = ["--bin", current_file_name_without_extension] if use_extra_args
  end

  TextMate.save_if_untitled('rs')
  TextMate::Executor.make_project_master_current_document
  TextMate::HTMLOutput.show(:title => "Cargo Build", :sub_title => "Results") do |io|
    show_output(io, "<pre>")
    cd_args = ["cd", ENV['TM_PROJECT_DIRECTORY']]
    show_output(io, cd_args.join(" "))
    TextMate::Process.run(cd_args)
    cargo_home = ENV['CARGO_HOME']
    cargo_name = ENV['TM_CARGO_NAME'] || "cargo"
    cargo_params = (ENV['TM_CARGO_PARAMS'] || "").split(" ")
    unless cargo_home
      cargo_home = File.join(ENV['HOME'], ".cargo")
    end
    path_to_cargo = File.join(cargo_home, "bin", cargo_name)
    unless File.exist? path_to_cargo
      show_output(io, "Error: Cannot find cargo at #{path_to_cargo}. Check that cargo is \
  installed and that the CARGO_HOME environmental variable is either unset or points \
  to the right location.")
      next
    end
    errors = []
    args = [path_to_cargo, cargo_params, cmd, additional_flags]
    show_output(io, args.join(" "))
    TextMate::Process.run(args, :env => {"PWD" => ENV['TM_PROJECT_DIRECTORY']}) do |str, type|
      if str =~ /--> (.*):(\d+):(\d+)/
        file_ref = Pathname.new($1)
        unless file_ref.absolute?
          if file_ref.dirname == Pathname.new(".")
            file_ref = File.join(ENV['TM_PROJECT_DIRECTORY'], default_dir, file_ref)
          else
            file_ref = File.join(ENV['TM_PROJECT_DIRECTORY'], file_ref)
          end
        end
        show_output(io, "<a href=\"txmt://open/?url=file://#{file_ref}&line=#{$2}&column=#{$3}\">#{str}</a>")
      elsif str =~ /error\[E(\d\d\d\d)\]/
        show_output(io, "<a href=\"https://doc.rust-lang.org/error-index.html\#E#{$1}\" target=\"_blank\">#{str}</a>")
      else
        show_output(io, str);
      end
    end
    show_output(io, "</pre>")
  end
end
