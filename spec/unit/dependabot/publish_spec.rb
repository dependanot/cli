# frozen_string_literal: true

RSpec.describe ::Dependabot::Publish do
  describe "#update!" do
    subject { described_class.new(dependency, git: git) }

    let(:dependency) do
      instance_double(
        Spandx::Core::Dependency,
        name: "net-hippie",
        version: "0.1.0",
        package_manager: :rubygems,
        path: dir.join("Gemfile.lock"),
        licenses: [],
        meta: {}
      )
    end
    let(:dir) { Pathname.new(Dir.mktmpdir) }
    let(:git) { Dependabot::Git.new(dir) }
    let(:nwo) { "dependanot/examples" }

    before do
      Dir.chdir(dir) do
        system "git init --quiet #{dir}"
        system "git config user.email you@example.com"
        system "git config user.name example"
        FileUtils.cp(fixture_file("bundler/net-hippie/0.1.0/Gemfile"), dir)
        FileUtils.cp(fixture_file("bundler/net-hippie/0.1.0/Gemfile.lock"), dir)
        system "git add Gemfile*"
        system "git remote add origin https://github.com/#{nwo}.git"
        system "git commit --quiet --no-gpg-sign -m 'initial commit'"
      end
    end

    after do
      FileUtils.remove_entry dir
    end

    context "when a project has a dependency that can be updated" do
      before do
        stub_request(:post, "https://api.github.com/repos/#{nwo}/pulls").to_return(status: 200)
      end

      it "does not publish a pull request" do
        subject.update!(push: false)

        expect(WebMock).not_to have_requested(:post, "https://api.github.com/repos/#{nwo}/pulls")
      end

      it "publishes a pull request" do
        allow(git).to receive(:push).and_return(nil)

        subject.update!(push: true)

        expect(WebMock).to have_requested(:post, "https://api.github.com/repos/#{nwo}/pulls")
      end
    end
  end
end
