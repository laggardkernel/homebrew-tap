# typed: true
# frozen_string_literal: true

require "formula"
require "keg"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def switch_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `switch` <formula> <version>

        Symlink all of the specified <version> of <formula>'s installation into Homebrew's prefix.
      EOS

      named_args number: 2
      hide_from_man_page!
    end
  end

  def switch
    args = switch_args.parse

    name = args.named.first
    rack = Formulary.to_rack(name)

    odie "#{name} not found in the Cellar." unless rack.directory?

    # odeprecated "`brew switch`", "`brew link` @-versioned formulae"

    versions = rack.subdirs
                   .map { |d| Keg.new(d).version }
                   .sort
                   .join(", ")
    version = args.named.second

    odie <<~EOS unless (rack/version).directory?
      #{name} does not have a version \"#{version}\" in the Cellar.
      #{name}'s installed versions: #{versions}
    EOS

    # Unlink all existing versions
    rack.subdirs.each do |v|
      keg = Keg.new(v)
      puts "Cleaning #{keg}"
      keg.unlink
    end

    keg = Keg.new(rack/version)

    # Link new version, if not keg-only
    if Formulary.keg_only?(rack)
      keg.optlink(verbose: args.verbose?)
      puts "Opt link created for #{keg}"
    else
      puts "#{keg.link} links created for #{keg}"
    end
  end
end

# https://github.com/Homebrew/discussions/discussions/339#discussioncomment-246650
# https://github.com/Homebrew/brew/pull/9209
#
# https://github.com/Homebrew/brew/commit/d1f3e39 Update commands to generate usage banner
# https://github.com/Homebrew/brew/commit/3323724 cmd: indicate multiple named args in usage banner
# https://github.com/Homebrew/brew/commit/74fb058 More deprecations for Homebrew 2.7.0.
# https://github.com/Homebrew/brew/commit/5be4c9b Upgrade `typed` sigils.
# https://github.com/Homebrew/brew/commit/d496f5c Deprecations for Homebrew 2.6.0
