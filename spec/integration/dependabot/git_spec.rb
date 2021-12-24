# frozen_string_literal: true

RSpec.describe ::Dependabot::Git do
  def within_git_repo
    within_tmp_dir do |path|
      system "git init --quiet #{path}"
      system "git config user.email you@example.com"
      system "git config user.name example"
      system "echo 'hello' > README.md"
      system "git add README.md"
      system "git commit --quiet --no-gpg-sign -m 'initial commit'"
      system "echo 'change' > README.md"
      yield described_class.new(path)
    end
  end

  describe "#checkout" do
    context "when the branch does not exist" do
      let(:branch_name) { SecureRandom.uuid }

      it "creates a new branch" do
        within_git_repo do |subject|
          subject.checkout(branch: branch_name)

          expect(`git branch`).to include(branch_name)
        end
      end

      it "switches to the new branch" do
        within_git_repo do |subject|
          subject.checkout(branch: branch_name)

          expect(File.read(".git/HEAD").chomp).to eql("ref: refs/heads/#{branch_name}")
        end
      end
    end

    context "when the branch already exists" do
      let(:branch_name) { SecureRandom.uuid }

      it "switches to that branch" do
        within_git_repo do |subject|
          system "git branch #{branch_name}"

          subject.checkout(branch: branch_name)

          expect(File.read(".git/HEAD").chomp).to eql("ref: refs/heads/#{branch_name}")
        end
      end
    end
  end

  describe "#commit" do
    context "when a tracked file is changed" do
      def within_dir
        within_git_repo do |subject|
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
