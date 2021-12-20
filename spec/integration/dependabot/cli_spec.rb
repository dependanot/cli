# frozen_string_literal: true

RSpec.describe Dependabot::CLI, type: :cli do
  it "executes `dependabot help scan` command successfully" do
    output = `./exe/dependabot help scan`
    expect(output).to eq(fixture_file_content("help-scan.expected"))
  end

  describe Dependabot::CLI::Scan do
    context "when scanning a bundler v1 project" do
      it "publishes a pull request for each package" do
        root_dir = Dir.pwd
        Dir.mktmpdir do |path|
          Dir.chdir(path) do
            system "git clone https://github.com/dependanot/dependalot ."
            system "gem install 'bundler:~>1.0'"
            system "#{root_dir}/exe/dependabot scan #{path}/src/bundler/v1/"
            expect(`git branch | grep dependanot | wc -l`.chomp.to_i).to be > 35
          end
        end
      end
    end
  end
end
