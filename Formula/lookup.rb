class Password < Formula
  desc "Bank Account Movements Lookup"
  homepage "https://github.com/joel/bam-lookup"
  version "0.1"

  url "https://github.com/joel/bam-lookup/archive/0.1.zip", :using => :curl

  def install
    bin.install "bin/lookup"
  end
end
