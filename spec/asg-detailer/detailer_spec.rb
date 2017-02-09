require 'spec_helper'

describe AsgDetailer::Detailer do
  before :each do
    @test_vars = aws_test_vars
    @stub_vars = aws_stub_vars(@test_vars)
    setup_aws_stubs
    @det = Detailer.new(@test_vars[:asg_name])
  end

  it 'is an instance of AsgDetailer::Detailer' do
    expect(@det).to be_kind_of(AsgDetailer::Detailer)
  end

  it 'sets an asg name from args' do
    expect(@det.name).to eq(@test_vars[:asg_name])
  end

  it 'initializes data to nil' do
    expect(@det.data).to eq(nil)
  end

  context 'when asg is configured correctly' do
    it 'returns detail in json' do
      expect(@det.json).to eq(@test_vars[:asg_resp].to_json)
    end

    it 'prints asg detail' do
      expect { @det.print }.to output(@test_vars[:asg_output]).to_stdout
    end

    it '"pretty" prints detail in json' do
      expect { @det.json_pretty }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp])}\n").to_stdout
    end
  end

  context 'when there is no launch config' do
    it 'returns data without lc' do
      setup_aws_stubs_no_lc
      expect(@det.json).to eq(@test_vars[:asg_resp_no_lc].to_json)
    end

    it 'prints asg detail without lc ' do
      setup_aws_stubs_no_lc
      expect { @det.print }.to output(@test_vars[:asg_output_no_lc]).to_stdout
    end

    it '"pretty" prints detail in json without lc' do
      setup_aws_stubs_no_lc
      expect { @det.json_pretty }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp_no_lc])}\n").to_stdout
    end
  end

  context 'when there is no load balancer' do
    it 'returns instances without lb' do
      setup_aws_stubs_no_lb
      expect(@det.json).to eq(@test_vars[:asg_resp_no_lb].to_json)
    end

    it 'prints asg detail without lb ' do
      setup_aws_stubs_no_lb
      expect { @det.print }.to output(@test_vars[:asg_output_no_lb]).to_stdout
    end

    it '"pretty" prints detail in json without lb' do
      setup_aws_stubs_no_lb
      expect { @det.json_pretty }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp_no_lb])}\n").to_stdout
    end
  end

  context 'when there are no instances or load balancer' do
    it 'returns no instances or lb' do
      setup_aws_stubs_no_lb_or_inst
      expect(@det.json).to eq(@test_vars[:asg_resp_no_lb_or_inst].to_json)
    end

    it 'prints asg detail with no instances or lb' do
      setup_aws_stubs_no_lb_or_inst
      expect { @det.print }.to output(@test_vars[:asg_output_no_lb_or_inst]).to_stdout
    end

    it '"pretty" prints detail in json with no instances or lb' do
      setup_aws_stubs_no_lb_or_inst
      expect { @det.json_pretty }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp_no_lb_or_inst])}\n").to_stdout
    end
  end

  context 'when terminated instances' do
    context 'cause instance errors' do
      it 'prints asg detail correctly' do
        Aws.config[:ec2] = {
          stub_responses: {describe_instances: 'InvalidInstanceIDNotFound'}
        }
        expect { @det.print }.to_not output(@test_vars[:asg_output]).to_stdout
        expect { @det.print }.to output(@test_vars[:asg_output_short]).to_stdout
      end
    end

    context 'exist but private IP is nil' do
      it 'returns json correctly' do
        setup_aws_stubs_ip_missing
        expect(@det.json).to eq(@test_vars[:asg_resp_ip_missing].to_json)
      end

      it 'prints asg detail correctly' do
        setup_aws_stubs_ip_missing
        expect { @det.print }.to output(@test_vars[:asg_output_ip_missing]).to_stdout
      end

      it '"pretty" prints detail in json correctly' do
        setup_aws_stubs_ip_missing
        expect { @det.json_pretty }.to output("#{JSON.pretty_generate(@test_vars[:asg_resp_ip_missing])}\n").to_stdout
      end
    end
  end
end
