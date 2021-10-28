# frozen_string_literal: true

RSpec.describe Dependabot::CLI, type: :cli do
  it "executes `dependabot help scan` command successfully" do
    output = `./exe/dependabot help scan`
    expect(output).to eq(fixture_file_content("help-scan.expected"))
  end
end
