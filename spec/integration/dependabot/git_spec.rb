# frozen_string_literal: true

RSpec.describe ::Dependabot::Git do
  def setup_git_repo(path)
    system "git init --quiet #{path}"
    system "git config user.email you@example.com"
    system "git config user.name example"
    system "echo 'hello' > README.md"
    system "git add README.md"
    system "git commit --quiet --no-gpg-sign -m 'initial commit'"
    system "echo 'change' > README.md"
  end

  describe "#checkout" do
    context "when the branch does not exist" do
      let(:branch_name) { "example" }

      it "creates a new branch" do
        within_tmp_dir do |path|
          setup_git_repo(path)
          subject = described_class.new(path)
          subject.checkout(branch: branch_name)

          expect(`git branch`).to include(branch_name)
        end
      end

      it "switches to the new branch" do
        within_tmp_dir do |path|
          setup_git_repo(path)
          subject = described_class.new(path)
          subject.checkout(branch: branch_name)

          expect(File.read(".git/HEAD").chomp).to eql("ref: refs/heads/#{branch_name}")
        end
      end
    end
  end

  describe "#commit" do
    context "when a tracked file is changed" do
      def within_dir
        within_tmp_dir do |path|
          setup_git_repo(path)
          subject = described_class.new(path)
          subject.checkout(branch: "example")
          subject.commit(all: true, message: "The message")
          yield
        end
      end

      it { within_dir { expect(`git log --oneline | wc -l`.strip).to eq("2") } }
      it { within_dir { expect(`git log --oneline`).to match("The message") } }
    end
  end
end
