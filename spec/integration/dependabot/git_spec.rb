# frozen_string_literal: true

RSpec.describe ::Dependabot::Git do
  describe "#commit" do
    context "when a tracked file is changed" do
      def setup_git_repo(path)
        system "git init --quiet #{path}"
        system "git config user.email you@example.com"
        system "git config user.name example"
        system "echo 'hello' > README.md"
        system "git add README.md"
        system "git commit --quiet -m 'initial commit'"
        system "echo 'change' > README.md"
      end

      def within_dir
        Dir.mktmpdir("dependabot") do |path|
          Dir.chdir(path) do
            setup_git_repo(path)
            subject = described_class.new(path)
            subject.checkout(branch: "example")
            subject.commit(all: true, message: "The message")
            yield
          end
        end
      end

      it { within_dir { expect(`git log --oneline | wc -l`.chomp).to eq("2") } }
      it { within_dir { expect(`git log --oneline`).to match("The message") } }
    end
  end
end
