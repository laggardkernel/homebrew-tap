# Adapted from and modified on dev-cmd/cat.rb. Removes hardcoded path to bat.
require "abstract_command"
require "fileutils"

module Homebrew
  module DevCmd
    class Bat < AbstractCommand
      include FileUtils

      cmd_args do
        description <<~EOS
          Display the source of a <formula> or <cask>.
        EOS

        switch "--formula", "--formulae",
               description: "Treat all named arguments as formulae."
        switch "--cask", "--casks",
               description: "Treat all named arguments as casks."

        conflicts "--formula", "--cask"

        named_args [:formula, :cask], min: 1, without_api: true
      end

      sig { override.void }
      def run
        cd HOMEBREW_REPOSITORY do
          # TODO: better fix for TERM problem on xterm-kitty
          ENV["TERM"] = "xterm-256color" if ENV["TERM"] == "xterm-kitty"
          ENV["BAT_CONFIG_PATH"] = Homebrew::EnvConfig.bat_config_path
          ENV["BAT_THEME"] = Homebrew::EnvConfig.bat_theme
          pager = "bat"

          args.named.to_paths.each do |path|
            next path if path.exist?

            path = path.basename(".rb") if args.cask?

            ofail "#{path}'s source doesn't exist on disk."
          end

          if Homebrew.failed?
            $stderr.puts "The name may be wrong, or the tap hasn't been tapped. Instead try:"
            treat_as = "--cask " if args.cask?
            treat_as = "--formula " if args.formula?
            $stderr.puts "  brew info --github #{treat_as}#{args.named.join(" ")}"
            return
          end

          safe_system pager, *args.named.to_paths
        end
      end
    end
  end
end
