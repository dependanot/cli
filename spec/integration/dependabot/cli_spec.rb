# frozen_string_literal: true

RSpec.describe Dependabot::CLI, type: :cli do
  it { expect(`./exe/dependabot help scan`).to eq(fixture_file_content("help-scan.expected")) }
  it { expect(`./exe/dependabot help`).to eq(fixture_file_content("help.expected")) }

  describe Dependabot::CLI::Scan do
    subject!(:dependabot) { File.join(Dir.pwd, "exe/dependabot") }

    context "when scanning a bundler v1 project" do
      specify do
        within_tmp_dir do |path|
          system "git clone --quiet https://github.com/dependanot/dependalot ."
          system "#{dependabot} scan #{path}/src/bundler/v1/"
          expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to be > 35
        end
      end
    end

    context "when scanning a bundler v2 project" do
      specify do
        within_tmp_dir do |path|
          system "git clone --quiet https://github.com/dependanot/dependalot ."
          system "#{dependabot} scan #{path}/src/bundler/v2/"
          expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to be > 40
        end
      end
    end

    context "when scanning an npm project" do
      specify do
        within_tmp_dir do |path|
          system "git clone --quiet https://github.com/dependanot/dependalot ."
          system "#{dependabot} scan #{path}/src/npm/"
          expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to eq(1)
        end
      end
    end
  end
end
