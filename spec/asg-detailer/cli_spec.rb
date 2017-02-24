require 'spec_helper'

describe AsgDetailer::CLI do
  before :each do
    @help = "Usage: asg-detailer [ option ... ]

Specific options:
    -a, --asg STRING                 The ASG name
    -j, --json                       Output data as JSON
    -p, --pretty-json                Output data as pretty_generated JSON\n"
    @test_vars = aws_test_vars
    setup_aws_stubs
  end

  it 'is an instance of AsgDetailer::CLI' do
    # we don't really need to see the output
    expect { @cli = AsgDetailer::CLI.new(['-a', @test_vars[:asg_name]]) }.to output(%r{.*}).to_stdout
    expect(@cli).to be_kind_of(AsgDetailer::CLI)
  end

  context 'when options are "-h" or "--help"' do
    it 'prints help and exits' do
      expect {
        expect { AsgDetailer::CLI.new(['-h']) }.to raise_error(SystemExit)
      }.to output(@help).to_stdout

      expect {
        expect { AsgDetailer::CLI.new(['--help']) }.to raise_error(SystemExit)
      }.to output(@help).to_stdout
    end
  end

  context 'on option parser fail' do
    it 'prints help and exits' do
      expect {
        expect { AsgDetailer::CLI.new([]) }.to raise_error(SystemExit)
      }.to output(@help).to_stdout
    end
  end

  it 'prints asg detail' do
    expect { AsgDetailer::CLI.new(['-a', @test_vars[:asg_name]])}.to output(@test_vars[:asg_output]).to_stdout
  end

  it 'prints detail in json' do
    expect { AsgDetailer::CLI.new(['-a', @test_vars[:asg_name], '-j']) }.to output("#{@test_vars[:asg_resp].to_json}\n").to_stdout
  end

  context '"pretty" prints option is selected' do
    it 'when options contain "-p"' do
      expect { AsgDetailer::CLI.new(['-a', @test_vars[:asg_name], '-p']) }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp])}\n").to_stdout
    end

    it 'when options contain "-p" and "-j"' do
      expect { AsgDetailer::CLI.new(['-a', @test_vars[:asg_name], '-p', '-j']) }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp])}\n").to_stdout
    end
  end
end
