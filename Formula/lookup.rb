class Lookup < Formula
  desc "Bank Account Movements Lookup"
  homepage "https://github.com/joel/homebrew-bam-lookup"
  version "0.5"

  url "https://github.com/joel/homebrew-bam-lookup/archive/0.5.zip", :using => :curl

  def install
    bin.install "bin/lookup"
  end
end
