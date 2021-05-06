# Copied from and modified on dev-cmd/cat.rb. Removes hardcoded path to bat.
# typed: false
# frozen_string_literal: true

require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def bat_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Display the source of a <formula> or <cask>.
        A `brew cat` alternative without hardcoding path to `bat`.
      EOS

      switch "--formula", "--formulae",
             description: "Treat all named arguments as formulae."
      switch "--cask", "--casks",
             description: "Treat all named arguments as casks."

      conflicts "--formula", "--cask"

      named_args [:formula, :cask], number: 1
    end
  end

  def bat
    args = bat_args.parse

    cd HOMEBREW_REPOSITORY
    # pager = if Homebrew::EnvConfig.bat?
    pager = if true
      # TODO: better fix for TERM problem on xterm-kitty
      ENV["TERM"] = "xterm-256color" if ENV["TERM"] == "xterm-kitty"
      ENV["BAT_CONFIG_PATH"] = Homebrew::EnvConfig.bat_config_path
      "bat"
    else
      "cat"
    end

    safe_system pager, args.named.to_paths.first
  end
end
