cask "vnote2" do
  version "2.10"
  sha256 "9adc4d003bcfea3d3386a952b09ab5012fb6a4d22dc2ec1e313b6c3350f26059"

  url "https://github.com/vnotex/vnote/releases/download/v#{version}/VNote-#{version}-x64.dmg",
      verified: "github.com/vnotex/vnote/"
  name "VNote"
  desc "Note-taking application that knows programmers and Markdown better"
  homepage "https://vnotex.github.io/vnote/"

  livecheck do
    skip "Versioned app, end of life"
  end

  app "VNote.app"
end
