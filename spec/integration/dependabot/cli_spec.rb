# frozen_string_literal: true

RSpec.describe Dependabot::CLI, type: :cli do
  it "executes `dependabot help scan` command successfully" do
    expect(`./exe/dependabot help scan`).to eq(fixture_file_content("help-scan.expected"))
  end

  describe Dependabot::CLI::Scan do
    subject!(:dependabot) { File.join(Dir.pwd, "exe/dependabot") }

    context "when scanning a bundler v1 project" do
      it "publishes a pull request for each package" do
        within_tmp_dir do |path|
          system "git clone https://github.com/dependanot/dependalot ."
          system "gem install 'bundler:~>1.0'"
          system "#{dependabot} scan #{path}/src/bundler/v1/"
          expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to be > 35
        end
      end
    end

    context "when scanning a bundler v2 project" do
      it "publishes a pull request for each package" do
        within_tmp_dir do |path|
          system "git clone https://github.com/dependanot/dependalot ."
          system "#{dependabot} scan #{path}/src/bundler/v2/"
          expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to be > 40
        end
      end
    end
  end
end
